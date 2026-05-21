import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../api/notifications_service.dart';
import '../models/models.dart';

// ---------------------------------------------------------------------------
// Constantes del WorkManager
// ---------------------------------------------------------------------------
const String taskName = 'check_air_quality_changes';
const String uniqueTaskName =
    'com.example.air_quality_flutter.background_check';

/// Intervalo mínimo de WorkManager en Android. El SO puede diferirlo,
/// pero 15 min es el mínimo aceptado.
const Duration kWorkManagerInterval = Duration(minutes: 15);

/// Tiempo mínimo entre alertas intrusivas para la misma ubicación.
const Duration kMinTimeBetweenAlerts = Duration(hours: 2);

/// Clave de SharedPreferences para guardar la última vez que se envió
/// una alerta intrusiva por ubicación.
const String kLastAlertTimestampsKey = 'lastAlertTimestamps';

// ---------------------------------------------------------------------------
// Dispatcher del WorkManager — debe ser top-level + @pragma
// ---------------------------------------------------------------------------
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      if (task == taskName) {
        await _runBackgroundCheck();
      }
      return true;
    } catch (e) {
      debugPrint('[WorkManager] Error en tarea: $e');
      return false;
    }
  });
}

// ---------------------------------------------------------------------------
// Lógica principal del background check
// ---------------------------------------------------------------------------
Future<void> _runBackgroundCheck() async {
  // Asegurar la inicialización de bindings para llamadas a canales de plataforma (Geolocator)
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Cargar variables de entorno
  try {
    await dotenv.load(fileName: 'assets/.env');
  } catch (e) {
    debugPrint('[WorkManager] Error cargando .env: $e');
  }

  final prefs = await SharedPreferences.getInstance();
  final String backendUrl =
      dotenv.env['API_URL'] ?? 'http://127.0.0.1:5000/api';

  // 2. Cargar configuración de notificaciones
  bool monitorCurrentLocation = true;
  final String? settingsString = prefs.getString('notificationSettings');
  if (settingsString != null) {
    final settings = json.decode(settingsString) as Map<String, dynamic>;
    monitorCurrentLocation = settings['miUbicacion'] ?? true;
  }

  // 3. Cargar idioma de usuario persistido (por defecto 'es')
  final String userLang = prefs.getString('currentLanguageCode') ?? 'es';

  // 4. Intentar obtener ubicación fresca en segundo plano mediante Geolocator
  Position? devicePosition;
  if (monitorCurrentLocation) {
    try {
      final Position freshPos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 10),
      );
      devicePosition = freshPos;
      final freshPosMap = {
        'lat': freshPos.latitude,
        'lon': freshPos.longitude,
        'timestamp': DateTime.now().toIso8601String(),
      };
      await prefs.setString('lastKnownDevicePosition', json.encode(freshPosMap));
      debugPrint('[WorkManager] Ubicación de fondo actualizada con GPS: '
          '${freshPos.latitude}, ${freshPos.longitude}');
    } catch (e) {
      debugPrint('[WorkManager] No se pudo obtener ubicación fresca GPS: $e. Usando caché...');
    }
  }

  // 5. Cargar ubicaciones de alerta configuradas y activas
  final String? alertsString = prefs.getString('alertLocations');
  final Map<String, dynamic> alertsJson =
      alertsString != null ? json.decode(alertsString) : {};
  final List<AlertLocation> locations = alertsJson.values
      .map((e) => AlertLocation.fromJson(e))
      .where((l) => l.enabled && l.isConfigured)
      .toList();

  // 5b. Si no se obtuvo posición GPS en background, intentar fallback a caché de SharedPreferences
  if (monitorCurrentLocation && devicePosition == null) {
    final String? lastPosString = prefs.getString('lastKnownDevicePosition');
    if (lastPosString != null) {
      try {
        final lastPosJson = json.decode(lastPosString);
        final lat = (lastPosJson['lat'] as num).toDouble();
        final lon = (lastPosJson['lon'] as num).toDouble();
        final timestamp = DateTime.parse(lastPosJson['timestamp'] as String);
        // Validar si tiene menos de 2 horas
        if (DateTime.now().difference(timestamp) <= const Duration(hours: 2)) {
          devicePosition = Position(
            latitude: lat,
            longitude: lon,
            timestamp: timestamp,
            accuracy: 0.0,
            altitude: 0.0,
            altitudeAccuracy: 0.0,
            heading: 0.0,
            headingAccuracy: 0.0,
            speed: 0.0,
            speedAccuracy: 0.0,
          );
        }
      } catch (e) {
        debugPrint('[WorkManager] Error leyendo lastKnownDevicePosition de caché: $e');
      }
    }
  }

  // 5c. Insertar 'Mi Ubicación' al principio si está habilitada y tenemos ubicación
  if (monitorCurrentLocation && devicePosition != null) {
    locations.insert(
      0,
      AlertLocation(
        id: 'current_device',
        name: 'Mi Ubicación',
        latitude: devicePosition.latitude,
        longitude: devicePosition.longitude,
        displayName: 'Ubicación Actual',
        enabled: true,
      ),
    );
  }

  if (locations.isEmpty) {
    debugPrint('[WorkManager] No hay ubicaciones activas.');
    return;
  }

  // 6. Cargar estado conocido (AQI/clima de la última ejecución)
  final String? lastStateString = prefs.getString('lastKnownState');
  Map<String, dynamic> lastState =
      lastStateString != null ? json.decode(lastStateString) : {};

  // 7. Cargar timestamps de la última alerta intrusiva enviada
  final String? lastAlertsString = prefs.getString(kLastAlertTimestampsKey);
  Map<String, dynamic> lastAlertTimes =
      lastAlertsString != null ? json.decode(lastAlertsString) : {};

  // 8. Inicializar plugin de notificaciones en este isolate
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@drawable/ic_notification');
  await flutterLocalNotificationsPlugin.initialize(
    const InitializationSettings(android: androidSettings),
  );

  // Crear canales en Android (idempotente)
  final androidPlugin = flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
  
  await androidPlugin?.createNotificationChannel(
    const AndroidNotificationChannel(
      'weather_status',
      'Estado del Clima',
      description: 'Muestra el clima y calidad del aire actuales en la barra de estado.',
      importance: Importance.low,
      playSound: false,
      enableVibration: false,
      showBadge: false,
    ),
  );
  await androidPlugin?.createNotificationChannel(
    const AndroidNotificationChannel(
      'air_quality_alerts',
      'Alertas de Calidad del Aire',
      description: 'Notificaciones urgentes cuando la calidad del aire es mala o peligrosa.',
      importance: Importance.high,
    ),
  );
  await androidPlugin?.createNotificationChannel(
    const AndroidNotificationChannel(
      'air_quality_forecast',
      'Pronóstico de Calidad del Aire',
      description: 'Alertas predictivas sobre la calidad del aire del día siguiente.',
      importance: Importance.defaultImportance,
    ),
  );
  await androidPlugin?.createNotificationChannel(
    const AndroidNotificationChannel(
      'air_quality_geofence',
      'Alertas de Proximidad (Geofencing)',
      description: 'Notificaciones en tiempo real al ingresar a zonas guardadas con mala calidad del aire.',
      importance: Importance.high,
    ),
  );

  // 9. Instanciar servicio de notificaciones
  final notifService = NotificationService();

  bool stateChanged = false;

  // 10. Procesar cada ubicación
  for (final location in locations) {
    try {
      debugPrint('[WorkManager] Verificando: ${location.displayName ?? location.name}');

      // Fetch paralelo: AQI + clima (utilizando el idioma preferido del usuario)
      final results = await Future.wait([
        http.get(Uri.parse(
            '$backendUrl/air_quality?lat=${location.latitude}&lon=${location.longitude}')),
        http.get(Uri.parse(
            '$backendUrl/weather?lat=${location.latitude}&lon=${location.longitude}&lang=$userLang')),
      ]);

      final airResponse = results[0];
      final weatherResponse = results[1];

      if (airResponse.statusCode != 200 || weatherResponse.statusCode != 200) {
        debugPrint('[WorkManager] Error en API para ${location.name}: '
            'AQI=${airResponse.statusCode} Weather=${weatherResponse.statusCode}');
        continue;
      }

      final AirQualityData airData =
          AirQualityData.fromJson(json.decode(airResponse.body));
      final weatherJson = json.decode(weatherResponse.body);
      final WeatherData weatherData =
          WeatherData.fromJson(weatherJson['current']);

      // Parsear la lista de forecast pronosticados
      List<ForecastItem> forecastList = [];
      if (weatherJson['forecast'] != null) {
        try {
          final List<dynamic> forecastJson = weatherJson['forecast'];
          forecastList = forecastJson
              .map((f) => ForecastItem.fromJson(f as Map<String, dynamic>))
              .toList();
        } catch (e) {
          debugPrint('[WorkManager] Error al parsear forecast: $e');
        }
      }

      final String displayName = location.displayName ?? location.name;

      // -----------------------------------------------------------------
      // SIEMPRE: Actualizar notificación de estado (ID=42) y Home Widget
      // Solo se procesa para la ubicación principal (la primera activa)
      // -----------------------------------------------------------------
      if (location == locations.first) {
        await NotificationService.showStatusNotificationStatic(
          locationName: displayName,
          weatherCondition: weatherData.condition,
          temp: weatherData.temp,
          aqi: airData.aqi,
        );
        debugPrint('[WorkManager] Notificación y Widget de estado actualizados para $displayName');
      }

      // -----------------------------------------------------------------
      // CONDICIONAL: Alerta intrusiva si el AQI actual es malo (AQI >= 4)
      // -----------------------------------------------------------------
      if (airData.aqi >= 4) {
        final bool shouldAlert = _shouldSendAlert(
          locationId: location.id,
          lastAlertTimes: lastAlertTimes,
        );

        if (shouldAlert) {
          await notifService.showAqiAlertNotification(
            locationName: displayName,
            aqi: airData.aqi,
            weatherCondition: weatherData.condition,
            temp: weatherData.temp,
            languageCode: userLang,
          );

          // Registrar timestamp de esta alerta
          lastAlertTimes[location.id] = DateTime.now().toIso8601String();
          debugPrint('[WorkManager] Alerta de AQI actual enviada para $displayName (AQI: ${airData.aqi})');
        } else {
          debugPrint('[WorkManager] AQI alto en $displayName pero aún no se cumple el throttle.');
        }
      }

      // -----------------------------------------------------------------
      // CONDICIONAL: Alerta predictiva del pronóstico para mañana (AQI >= 4)
      // -----------------------------------------------------------------
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final String tomorrowStr =
          "${tomorrow.year}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}";
      
      ForecastItem? tomorrowForecast;
      for (final item in forecastList) {
        if (item.date == tomorrowStr) {
          tomorrowForecast = item;
          break;
        }
      }

      if (tomorrowForecast != null && tomorrowForecast.aqi != null && tomorrowForecast.aqi! >= 4) {
        final String? lastPredictiveString = prefs.getString('lastPredictiveAlertTimestamps');
        Map<String, dynamic> lastPredictiveTimes =
            lastPredictiveString != null ? json.decode(lastPredictiveString) : {};

        final bool shouldPredictive = _shouldSendPredictiveAlert(
          locationId: location.id,
          lastPredictiveTimes: lastPredictiveTimes,
        );

        if (shouldPredictive) {
          await notifService.showPredictiveForecastNotification(
            locationName: displayName,
            aqi: tomorrowForecast.aqi!,
            languageCode: userLang,
          );

          // Registrar timestamp (Throttle de 24 horas)
          lastPredictiveTimes[location.id] = DateTime.now().toIso8601String();
          await prefs.setString('lastPredictiveAlertTimestamps', json.encode(lastPredictiveTimes));
          debugPrint('[WorkManager] Alerta de pronóstico predictivo enviada para $displayName '
              '(AQI proyectado para mañana: ${tomorrowForecast.aqi})');
        }
      }

      // -----------------------------------------------------------------
      // GEOFENCING EN DART: Evaluar proximidad con histéresis si no es 'current_device'
      // -----------------------------------------------------------------
      if (devicePosition != null &&
          location.id != 'current_device' &&
          location.latitude != null &&
          location.longitude != null) {
        final double distance = Geolocator.distanceBetween(
          devicePosition.latitude,
          devicePosition.longitude,
          location.latitude!,
          location.longitude!,
        );

        final List<String> insideGeofences = prefs.getStringList('insideGeofences') ?? [];
        final bool isAlreadyInside = insideGeofences.contains(location.id);
        const double kGeofenceRadius = 1000.0;     // Entra al geofence en 1 km
        const double kGeofenceExitRadius = 1200.0; // Sale en 1.2 km para amortiguar ruido

        if (distance < kGeofenceRadius && !isAlreadyInside) {
          insideGeofences.add(location.id);
          await prefs.setStringList('insideGeofences', insideGeofences);
          debugPrint('[WorkManager] Geofence ENTRY detectado para ${location.name} a ${distance.round()}m');

          // Alerta al ingresar a una zona configurada con AQI nocivo
          if (airData.aqi >= 4) {
            await notifService.showGeofenceAlertNotification(
              locationName: displayName,
              aqi: airData.aqi,
              languageCode: userLang,
            );
          }
        } else if (distance > kGeofenceExitRadius && isAlreadyInside) {
          insideGeofences.remove(location.id);
          await prefs.setStringList('insideGeofences', insideGeofences);
          debugPrint('[WorkManager] Geofence EXIT detectado para ${location.name} a ${distance.round()}m');
        }
      }

      // -----------------------------------------------------------------
      // Actualizar estado histórico conocido para optimización
      // -----------------------------------------------------------------
      final newState = {
        'aqi': airData.aqi,
        'condition': weatherData.condition,
        'temp': weatherData.temp,
        'timestamp': DateTime.now().toIso8601String(),
      };

      if (lastState[location.id] != newState) {
        lastState[location.id] = newState;
        stateChanged = true;
      }
    } catch (e) {
      debugPrint('[WorkManager] Error procesando la ubicación ${location.name}: $e');
    }
  }

  // 11. Persistir estados finales
  if (stateChanged) {
    await prefs.setString('lastKnownState', json.encode(lastState));
  }
  await prefs.setString(kLastAlertTimestampsKey, json.encode(lastAlertTimes));
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Devuelve true si debe enviarse una alerta intrusiva para la ubicación dada.
/// Respeta el intervalo mínimo [kMinTimeBetweenAlerts].
bool _shouldSendAlert({
  required String locationId,
  required Map<String, dynamic> lastAlertTimes,
}) {
  if (!lastAlertTimes.containsKey(locationId)) {
    return true; // Primera vez → alertar
  }
  final lastAlert = DateTime.tryParse(lastAlertTimes[locationId]);
  if (lastAlert == null) return true;
  return DateTime.now().difference(lastAlert) >= kMinTimeBetweenAlerts;
}

/// Devuelve true si debe enviarse una alerta predictiva.
/// Respeta el throttle estricto de 24 horas.
bool _shouldSendPredictiveAlert({
  required String locationId,
  required Map<String, dynamic> lastPredictiveTimes,
}) {
  if (!lastPredictiveTimes.containsKey(locationId)) {
    return true; // Primera vez → alertar
  }
  final lastAlert = DateTime.tryParse(lastPredictiveTimes[locationId]);
  if (lastAlert == null) return true;
  return DateTime.now().difference(lastAlert) >= const Duration(hours: 24);
}
