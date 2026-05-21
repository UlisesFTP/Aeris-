import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:injectable/injectable.dart';
import '../services/widget_data_service.dart';

// ---------------------------------------------------------------------------
// IDs fijos para las notificaciones
// ---------------------------------------------------------------------------
/// ID fijo para la notificación de ESTADO (siempre visible, siempre la misma).
/// Usar el mismo ID hace que Android la sobreescriba silenciosamente, igual que
/// Google Weather.
const int kWeatherStatusNotificationId = 42;

/// Prefijo para el ID de las alertas. Las alertas de calidad del aire sí generan
/// IDs únicos para que el usuario pueda verlas todas.
const int kAqiAlertBaseId = 1000;

// ---------------------------------------------------------------------------
// Canales de Android
// ---------------------------------------------------------------------------

/// Canal de ESTADO: baja importancia, no interrumpe. Siempre visible en la
/// barra de estado. Equivalente al canal que usa Google Weather para mostrar
/// temperatura y condición.
const AndroidNotificationChannel _weatherStatusChannel =
    AndroidNotificationChannel(
  'weather_status',        // channelId
  'Estado del Clima',      // channelName
  description:
      'Muestra el clima y calidad del aire actuales en la barra de estado. '
      'No emite sonido ni vibración.',
  importance: Importance.low,
  playSound: false,
  enableVibration: false,
  showBadge: false,
);

/// Canal de ALERTAS: alta importancia, interrumpe al usuario. Solo se usa
/// cuando la calidad del aire es Mala (AQI ≥ 4) o peor.
const AndroidNotificationChannel _aqiAlertsChannel = AndroidNotificationChannel(
  'air_quality_alerts',        // channelId
  'Alertas de Calidad del Aire', // channelName
  description:
      'Notificaciones urgentes cuando la calidad del aire es mala o peligrosa.',
  importance: Importance.high,
  playSound: true,
  enableVibration: true,
  showBadge: true,
);

/// Canal de PRONÓSTICO: importancia media, notificaciones predictivas.
const AndroidNotificationChannel _forecastChannel = AndroidNotificationChannel(
  'air_quality_forecast',
  'Pronóstico de Calidad del Aire',
  description: 'Alertas predictivas sobre la calidad del aire del día siguiente.',
  importance: Importance.defaultImportance,
  playSound: true,
  enableVibration: true,
  showBadge: true,
);

/// Canal de GEOFENCING: importancia alta, notificaciones de proximidad al ingresar a zonas guardadas.
const AndroidNotificationChannel _geofenceChannel = AndroidNotificationChannel(
  'air_quality_geofence',
  'Alertas de Proximidad (Geofencing)',
  description: 'Notificaciones en tiempo real al ingresar a zonas guardadas con mala calidad del aire.',
  importance: Importance.high,
  playSound: true,
  enableVibration: true,
  showBadge: true,
);

// ---------------------------------------------------------------------------
// Plugin global (se usa también desde el background handler de FCM)
// ---------------------------------------------------------------------------
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// ---------------------------------------------------------------------------
// Handler FCM para segundo plano / app cerrada
// Debe ser una función TOP-LEVEL (fuera de cualquier clase) para que
// Firebase pueda invocarla desde un isolate separado.
// ---------------------------------------------------------------------------
@pragma('vm:entry-point')
Future<void> firebaseBackgroundMessageHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print('[FCM Background] Mensaje recibido: ${message.data}');
  }

  // Inicializar el plugin en el isolate de background
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@drawable/ic_notification');
  await flutterLocalNotificationsPlugin.initialize(
    const InitializationSettings(android: androidSettings),
  );

  // Crear los canales en este isolate también
  final androidPlugin = flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
  await androidPlugin?.createNotificationChannel(_weatherStatusChannel);
  await androidPlugin?.createNotificationChannel(_aqiAlertsChannel);
  await androidPlugin?.createNotificationChannel(_forecastChannel);
  await androidPlugin?.createNotificationChannel(_geofenceChannel);

  // Leer datos del payload FCM
  final data = message.data;
  final String locationName = data['location'] ?? 'Tu ubicación';
  final String weatherCondition = data['condition'] ?? '';
  final double temp =
      double.tryParse(data['temp']?.toString() ?? '') ?? 0.0;
  final int aqi = int.tryParse(data['aqi']?.toString() ?? '') ?? 0;

  if (aqi > 0 || weatherCondition.isNotEmpty) {
    await NotificationService.showStatusNotificationStatic(
      locationName: locationName,
      weatherCondition: weatherCondition,
      temp: temp,
      aqi: aqi,
    );
  }
}

// ---------------------------------------------------------------------------
// Servicio principal
// ---------------------------------------------------------------------------
@singleton
class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // -------------------------------------------------------------------------
  // Inicialización
  // -------------------------------------------------------------------------
  Future<void> initNotifications() async {
    // 1. Configurar plugin local
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@drawable/ic_notification');
    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(android: androidSettings),
      onDidReceiveNotificationResponse: (details) {
        // Manejar tap en notificación (abrir app, navegar, etc.)
        if (kDebugMode) {
          print('[Notification] Tap recibido: ${details.payload}');
        }
      },
    );

    // 2. Crear canales en Android (idempotente: no duplica si ya existen)
    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_weatherStatusChannel);
    await androidPlugin?.createNotificationChannel(_aqiAlertsChannel);
    await androidPlugin?.createNotificationChannel(_forecastChannel);
    await androidPlugin?.createNotificationChannel(_geofenceChannel);

    // 3. Solicitar permiso Firebase / APNs
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // 4. Log del token para debug
    final fcmToken = await _firebaseMessaging.getToken();
    if (kDebugMode) {
      print('[FCM] Token: $fcmToken');
    }

    // 5. Manejar mensajes cuando la app está en FOREGROUND
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('[FCM Foreground] Mensaje: ${message.data}');
      }
      // Los mensajes de datos en foreground también actualizan el status
      final data = message.data;
      if (data.isNotEmpty) {
        showStatusNotificationStatic(
          locationName: data['location'] ?? 'Tu ubicación',
          weatherCondition: data['condition'] ?? '',
          temp: double.tryParse(data['temp']?.toString() ?? '') ?? 0.0,
          aqi: int.tryParse(data['aqi']?.toString() ?? '') ?? 0,
        );
      }
    });
  }

  // -------------------------------------------------------------------------
  // NOTIFICACIÓN DE ESTADO (siempre visible, se sobreescribe)
  // Equivalente a la barra de estado de Google Weather.
  // Usa ID fijo=42 para que Android la actualice sin acumular.
  // -------------------------------------------------------------------------
  Future<void> showPersistentStatusNotification({
    required String locationName,
    required String weatherCondition,
    required double temp,
    required int aqi,
  }) async {
    await showStatusNotificationStatic(
      locationName: locationName,
      weatherCondition: weatherCondition,
      temp: temp,
      aqi: aqi,
    );
  }

  /// Versión estática para poder llamarla desde el background handler (top-level)
  static Future<void> showStatusNotificationStatic({
    required String locationName,
    required String weatherCondition,
    required double temp,
    required int aqi,
  }) async {
    final weatherEmoji = _getWeatherEmoji(weatherCondition);
    final aqiEmoji = _getAqiEmoji(aqi);
    final aqiText = _getAqiLevelText(aqi);

    // Título compacto: se ve en la barra colapsada
    final String title =
        '$weatherEmoji ${temp.round()}°C · $locationName';

    // Cuerpo expandido: se ve al expandir la notificación
    final String expandedBody =
        '$weatherEmoji ${weatherCondition.isNotEmpty ? weatherCondition : 'Sin datos'} — ${temp.round()}°C\n'
        '$aqiEmoji Calidad del aire: $aqiText';

    final BigTextStyleInformation bigText = BigTextStyleInformation(
      expandedBody,
      contentTitle: title,
    );

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      _weatherStatusChannel.id,
      _weatherStatusChannel.name,
      channelDescription: _weatherStatusChannel.description,
      importance: Importance.low,
      priority: Priority.low,
      styleInformation: bigText,
      // Estilo Google Weather: sin sonido, sin vibración, siempre visible
      playSound: false,
      enableVibration: false,
      ongoing: true,       // El usuario NO puede eliminarla con swipe
      autoCancel: false,   // No desaparece al tocarla
      showWhen: false,     // No muestra timestamp (se ve más limpia)
      onlyAlertOnce: true, // No re-alerta si ya existe
    );

    await flutterLocalNotificationsPlugin.show(
      kWeatherStatusNotificationId, // ID FIJO — siempre sobrescribe la misma
      title,
      expandedBody,
      NotificationDetails(android: androidDetails),
      payload: 'status_$locationName',
    );

    // Actualizar los datos del Home Screen Widget nativo en paralelo
    try {
      await WidgetDataService.updateWidgetData(
        locationName: locationName,
        aqi: aqi,
        temp: temp,
        condition: weatherCondition,
      );
    } catch (e) {
      debugPrint('[NotificationService] Error al sincronizar datos del widget: $e');
    }
  }

  // -------------------------------------------------------------------------
  // NOTIFICACIÓN DE ALERTA (intrusiva, solo para AQI ≥ 4)
  // Usa un ID variable para que se acumulen si hay varias ubicaciones en alerta.
  // -------------------------------------------------------------------------
  Future<void> showAqiAlertNotification({
    required String locationName,
    required int aqi,
    required String weatherCondition,
    required double temp,
    String? aiAdvice,
    String languageCode = 'es',
  }) async {
    final aqiEmoji = _getAqiEmoji(aqi);
    final aqiText = _getAqiLevelText(aqi, languageCode: languageCode);
    final weatherEmoji = _getWeatherEmoji(weatherCondition);

    final String title = languageCode == 'en'
        ? '$aqiEmoji Air Quality Alert — $locationName'
        : '$aqiEmoji Alerta de Calidad del Aire — $locationName';

    final sb = StringBuffer();
    sb.writeln('$weatherEmoji ${weatherCondition.isNotEmpty ? weatherCondition : ''} ${temp.round()}°C');
    sb.writeln('$aqiEmoji Calidad del aire: $aqiText (AQI: $aqi)');
    if (aiAdvice != null && aiAdvice.isNotEmpty) {
      sb.writeln('\n$aiAdvice');
    }

    final BigTextStyleInformation bigText = BigTextStyleInformation(
      sb.toString(),
      contentTitle: title,
    );

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      _aqiAlertsChannel.id,
      _aqiAlertsChannel.name,
      channelDescription: _aqiAlertsChannel.description,
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: bigText,
      playSound: true,
      enableVibration: true,
      autoCancel: true,
    );

    // ID único por ubicación para que no se sobreescriban entre sí
    final int notifId =
        kAqiAlertBaseId + locationName.hashCode.abs() % 900;

    await flutterLocalNotificationsPlugin.show(
      notifId,
      title,
      sb.toString(),
      NotificationDetails(android: androidDetails),
      payload: 'alert_$locationName',
    );
  }

  // -------------------------------------------------------------------------
  // NOTIFICACIÓN PREDICTIVA DE FORECAST (Mañana se espera AQI alto)
  // -------------------------------------------------------------------------
  Future<void> showPredictiveForecastNotification({
    required String locationName,
    required int aqi,
    String languageCode = 'es',
  }) async {
    final aqiEmoji = _getAqiEmoji(aqi);
    final aqiText = _getAqiLevelText(aqi, languageCode: languageCode);

    String title = '';
    String body = '';

    if (languageCode == 'es') {
      title = '🔮 Calidad del Aire Mañana — $locationName';
      body = 'Mañana se espera una calidad del aire $aqiText ($aqiEmoji AQI $aqi). Considera adaptar tus actividades al aire libre.';
    } else if (languageCode == 'en') {
      title = '🔮 Tomorrow\'s Air Quality — $locationName';
      body = 'Air quality tomorrow is expected to be $aqiText ($aqiEmoji AQI $aqi). Consider adjusting your outdoor activities.';
    } else if (languageCode == 'pt') {
      title = '🔮 Qualidade do Ar Amanhã — $locationName';
      body = 'Amanhã espera-se qualidade do ar $aqiText ($aqiEmoji AQI $aqi). Considere adaptar suas atividades ao ar livre.';
    } else if (languageCode == 'fr') {
      title = '🔮 Qualité de l\'Air Demain — $locationName';
      body = 'Demain, la qualité de l\'air devrait être $aqiText ($aqiEmoji AQI $aqi). Pensez à adapter vos activités de plein air.';
    } else if (languageCode == 'de') {
      title = '🔮 Luftqualität Morgen — $locationName';
      body = 'Morgen wird eine Luftqualität von $aqiText ($aqiEmoji AQI $aqi) erwartet. Bitte passen Sie Ihre Outdoor-Aktivitäten an.';
    } else {
      title = '🔮 Tomorrow\'s Air Quality — $locationName';
      body = 'Air quality tomorrow is expected to be $aqiText ($aqiEmoji AQI $aqi). Consider adjusting your outdoor activities.';
    }

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      _forecastChannel.id,
      _forecastChannel.name,
      channelDescription: _forecastChannel.description,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      styleInformation: BigTextStyleInformation(body, contentTitle: title),
      playSound: true,
      enableVibration: true,
      autoCancel: true,
    );

    final int notifId = 2000 + locationName.hashCode.abs() % 900;

    await flutterLocalNotificationsPlugin.show(
      notifId,
      title,
      body,
      NotificationDetails(android: androidDetails),
      payload: 'predictive_$locationName',
    );
  }

  // -------------------------------------------------------------------------
  // NOTIFICACIÓN DE GEOFENCING (Cerca de una ubicación guardada con AQI alto)
  // -------------------------------------------------------------------------
  Future<void> showGeofenceAlertNotification({
    required String locationName,
    required int aqi,
    String languageCode = 'es',
  }) async {
    final aqiEmoji = _getAqiEmoji(aqi);
    final aqiText = _getAqiLevelText(aqi, languageCode: languageCode);

    String title = '';
    String body = '';

    if (languageCode == 'es') {
      title = '📍 Entrando a Zona de Alerta — $locationName';
      body = 'Estás ingresando a un área con mala calidad del aire ($aqiText, $aqiEmoji AQI: $aqi). Se recomienda precaución.';
    } else if (languageCode == 'en') {
      title = '📍 Entering Alert Zone — $locationName';
      body = 'You are entering an area with poor air quality ($aqiText, $aqiEmoji AQI: $aqi). Caution is advised.';
    } else if (languageCode == 'pt') {
      title = '📍 Entrando na Zona de Alerta — $locationName';
      body = 'Você está entrando em uma área com qualidade do ar ruim ($aqiText, $aqiEmoji AQI: $aqi). Recomenda-se cautela.';
    } else if (languageCode == 'fr') {
      title = '📍 Entrée en Zone d\'Alerte — $locationName';
      body = 'Vous entrez dans une zone où la qualité de l\'air est médiocre ($aqiText, $aqiEmoji AQI : $aqi). La prudence est de mise.';
    } else if (languageCode == 'de') {
      title = '📍 Betreten der Alarmzone — $locationName';
      body = 'Sie betreten ein Gebiet mit schlechter Luftqualität ($aqiText, $aqiEmoji AQI: $aqi). Vorsicht ist geboten.';
    } else {
      title = '📍 Entering Alert Zone — $locationName';
      body = 'You are entering an area with poor air quality ($aqiText, $aqiEmoji AQI: $aqi). Caution is advised.';
    }

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      _geofenceChannel.id,
      _geofenceChannel.name,
      channelDescription: _geofenceChannel.description,
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(body, contentTitle: title),
      playSound: true,
      enableVibration: true,
      autoCancel: true,
    );

    final int notifId = 3000 + locationName.hashCode.abs() % 900;

    await flutterLocalNotificationsPlugin.show(
      notifId,
      title,
      body,
      NotificationDetails(android: androidDetails),
      payload: 'geofence_$locationName',
    );
  }

  // -------------------------------------------------------------------------
  // Compatibilidad: método legacy usado por alert_monitoring_service.dart
  // Redirige al canal correcto según la urgencia
  // -------------------------------------------------------------------------
  Future<void> showNotification({
    required String title,
    required String body,
    int aqi = 0,
    String locationName = '',
  }) async {
    if (aqi >= 4) {
      await showAqiAlertNotification(
        locationName: locationName.isEmpty ? 'Tu ubicación' : locationName,
        aqi: aqi,
        weatherCondition: '',
        temp: 0,
        aiAdvice: body,
      );
    } else {
      // Fallback: notificación estándar en el canal de alertas
      final AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        _aqiAlertsChannel.id,
        _aqiAlertsChannel.name,
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        styleInformation: BigTextStyleInformation(body, contentTitle: title),
      );
      await flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000 % 10000,
        title,
        body,
        NotificationDetails(android: androidDetails),
      );
    }
  }

  // -------------------------------------------------------------------------
  // Helpers (nivel de clase, accesibles estáticamente desde el isolate BG)
  // -------------------------------------------------------------------------
  static String _getAqiLevelText(int aqi, {String languageCode = 'es'}) {
    if (languageCode == 'en') {
      switch (aqi) {
        case 1: return 'Good';
        case 2: return 'Fair';
        case 3: return 'Moderate';
        case 4: return 'Poor';
        case 5: return 'Very Poor';
        case 6: return 'Dangerous';
        default: return 'Unknown';
      }
    }
    switch (aqi) {
      case 1: return 'Buena';
      case 2: return 'Regular';
      case 3: return 'Moderada';
      case 4: return 'Mala';
      case 5: return 'Muy Mala';
      case 6: return 'Peligrosa';
      default: return 'Sin datos';
    }
  }

  static String _getAqiEmoji(int aqi) {
    switch (aqi) {
      case 1:
      case 2: return '🍃';
      case 3: return '⚠️';
      case 4:
      case 5: return '🚨';
      case 6: return '☢️';
      default: return '📊';
    }
  }

  static String _getWeatherEmoji(String condition) {
    final lower = condition.toLowerCase();
    if (lower.contains('sun') || lower.contains('sol') ||
        lower.contains('clear') || lower.contains('despejado')) {
      return '☀️';
    }
    if (lower.contains('cloud') || lower.contains('nube') ||
        lower.contains('nublado')) {
      return '☁️';
    }
    if (lower.contains('rain') || lower.contains('lluvia') ||
        lower.contains('drizzle')) {
      return '🌧️';
    }
    if (lower.contains('storm') || lower.contains('tormenta')) {
      return '⛈️';
    }
    if (lower.contains('snow') || lower.contains('nieve')) {
      return '❄️';
    }
    if (lower.contains('mist') || lower.contains('fog') ||
        lower.contains('niebla')) {
      return '🌫️';
    }
    return '🌡️';
  }
}
