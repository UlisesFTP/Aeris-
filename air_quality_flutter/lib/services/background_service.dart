import 'dart:convert';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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
/// pero 15 min es el mínimo aceptado (igual que Google Weather en background).
const Duration kWorkManagerInterval = Duration(minutes: 15);

/// Tiempo mínimo entre alertas intrusivas para la misma ubicación.
/// Evita bombardear al usuario si el AQI se mantiene alto.
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
  // 1. Cargar variables de entorno
  try {
    await dotenv.load(fileName: 'assets/.env');
  } catch (e) {
    debugPrint('[WorkManager] Error cargando .env: $e');
  }

  final prefs = await SharedPreferences.getInstance();
  final String backendUrl =
      dotenv.env['API_URL'] ?? 'http://127.0.0.1:5000/api';

  // 2. Cargar ubicaciones de alerta configuradas y activas
  final String? alertsString = prefs.getString('alertLocations');
  if (alertsString == null) {
    debugPrint('[WorkManager] No hay ubicaciones de alerta configuradas.');
    return;
  }

  final Map<String, dynamic> alertsJson = json.decode(alertsString);
  final List<AlertLocation> locations = alertsJson.values
      .map((e) => AlertLocation.fromJson(e))
      .where((l) => l.enabled && l.isConfigured)
      .toList();

  if (locations.isEmpty) {
    debugPrint('[WorkManager] No hay ubicaciones activas.');
    return;
  }

  // 3. Cargar estado conocido (AQI/clima de la última ejecución)
  final String? lastStateString = prefs.getString('lastKnownState');
  Map<String, dynamic> lastState =
      lastStateString != null ? json.decode(lastStateString) : {};

  // 4. Cargar timestamps de la última alerta intrusiva enviada
  final String? lastAlertsString = prefs.getString(kLastAlertTimestampsKey);
  Map<String, dynamic> lastAlertTimes =
      lastAlertsString != null ? json.decode(lastAlertsString) : {};

  // 5. Inicializar plugin de notificaciones en este isolate
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@drawable/ic_notification');
  await flutterLocalNotificationsPlugin.initialize(
    const InitializationSettings(android: androidSettings),
  );

  // Crear canales (idempotente)
  final androidPlugin = flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
  await androidPlugin?.createNotificationChannel(
    const AndroidNotificationChannel(
      'weather_status',
      'Estado del Clima',
      description:
          'Muestra el clima y calidad del aire actuales en la barra de estado.',
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
      description:
          'Notificaciones urgentes cuando la calidad del aire es mala o peligrosa.',
      importance: Importance.high,
    ),
  );

  // 6. Instanciar servicio de notificaciones
  final notifService = NotificationService();

  bool stateChanged = false;

  // 7. Procesar cada ubicación
  for (final location in locations) {
    try {
      debugPrint('[WorkManager] Verificando: ${location.displayName ?? location.name}');

      // Fetch paralelo: AQI + clima
      final results = await Future.wait([
        http.get(Uri.parse(
            '$backendUrl/air_quality?lat=${location.latitude}&lon=${location.longitude}')),
        http.get(Uri.parse(
            '$backendUrl/weather?lat=${location.latitude}&lon=${location.longitude}&lang=es')),
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

      final String displayName = location.displayName ?? location.name;

      // -----------------------------------------------------------------
      // SIEMPRE: Actualizar notificación persistente de estado (ID fijo=42)
      // Esto replica el comportamiento de Google Weather: la barra de estado
      // siempre tiene el dato más reciente, sin ruido ni vibración.
      // Solo se muestra para la primera ubicación activa (la principal).
      // -----------------------------------------------------------------
      if (location == locations.first) {
        await NotificationService.showStatusNotificationStatic(
          locationName: displayName,
          weatherCondition: weatherData.condition,
          temp: weatherData.temp,
          aqi: airData.aqi,
        );
        debugPrint('[WorkManager] Notificación de estado actualizada para $displayName');
      }

      // -----------------------------------------------------------------
      // CONDICIONAL: Alerta intrusiva solo si:
      //   1. AQI >= 4 (Mala calidad del aire)
      //   2. Han pasado al menos kMinTimeBetweenAlerts desde la última alerta
      //      para esta ubicación (evita spam)
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
          );

          // Registrar timestamp de esta alerta
          lastAlertTimes[location.id] = DateTime.now().toIso8601String();
          debugPrint('[WorkManager] Alerta de AQI enviada para $displayName (AQI: ${airData.aqi})');
        } else {
          debugPrint('[WorkManager] AQI alto en $displayName pero aún no es tiempo de re-alertar.');
        }
      }

      // -----------------------------------------------------------------
      // Actualizar estado conocido
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
      debugPrint('[WorkManager] Error procesando ${location.name}: $e');
    }
  }

  // 8. Persistir estado actualizado
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
