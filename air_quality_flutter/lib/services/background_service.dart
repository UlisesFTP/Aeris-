import 'dart:convert';
import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import '../models/models.dart';

// Constants
const String taskName = 'check_air_quality_changes';
const String uniqueTaskName =
    'com.example.air_quality_flutter.background_check';

// Entry point for the background task
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      if (task == taskName) {
        await _checkBackgroundUpdates();
      }
      return Future.value(true);
    } catch (e) {
      print('Background task error: $e');
      return Future.value(false);
    }
  });
}

Future<void> _checkBackgroundUpdates() async {
  // 1. Initialize Environment
  try {
    await dotenv.load(fileName: "assets/.env");
  } catch (e) {
    print("Error loading .env in background: $e");
    // Fallback or exit if critical
  }

  final prefs = await SharedPreferences.getInstance();
  final String backendUrl =
      dotenv.env['API_URL'] ?? "http://127.0.0.1:5000/api";

  // 2. Load Alert Locations
  final String? alertsString = prefs.getString('alertLocations');
  if (alertsString == null) return;

  final Map<String, dynamic> alertsJson = json.decode(alertsString);
  final List<AlertLocation> locations = alertsJson.values
      .map((e) => AlertLocation.fromJson(e))
      .where((l) => l.enabled && l.isConfigured)
      .toList();

  // 3. Load Last Known State
  final String? lastStateString = prefs.getString('lastKnownState');
  Map<String, dynamic> lastState = {};
  if (lastStateString != null) {
    lastState = json.decode(lastStateString);
  }

  // 4. Initialize Notifications
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@drawable/ic_notification');
  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // 5. Check Each Location
  bool stateChanged = false;

  for (final location in locations) {
    try {
      // Fetch Data
      final airResponse = await http.get(Uri.parse(
          '$backendUrl/air_quality?lat=${location.latitude}&lon=${location.longitude}'));
      final weatherResponse = await http.get(Uri.parse(
          '$backendUrl/weather?lat=${location.latitude}&lon=${location.longitude}&lang=es'));

      if (airResponse.statusCode == 200 && weatherResponse.statusCode == 200) {
        final airData = AirQualityData.fromJson(json.decode(airResponse.body));
        final weatherJson = json.decode(weatherResponse.body);
        final weatherData = WeatherData.fromJson(weatherJson['current']);

        // Check for Changes
        final lastLocState = lastState[location.id];
        bool shouldNotify = false;
        String changeDescription = "";

        if (lastLocState == null) {
          // First run for this location, save state but maybe don't notify to avoid spam on startup
          // OR notify once. Let's notify once to confirm it works.
          shouldNotify = true;
          changeDescription = "Seguimiento iniciado";
        } else {
          final int lastAqi = lastLocState['aqi'];
          final String lastCondition = lastLocState['condition'];
          final double lastTemp = lastLocState['temp'];

          // Logic: Notify if AQI changes category OR Weather condition changes OR Temp changes > 3 degrees
          if (airData.aqi != lastAqi) {
            shouldNotify = true;
            changeDescription = "Cambio en Calidad del Aire";
          } else if (weatherData.condition != lastCondition) {
            shouldNotify = true;
            changeDescription = "Cambio en el Clima";
          } else if ((weatherData.temp - lastTemp).abs() > 3.0) {
            shouldNotify = true;
            changeDescription = "Cambio de Temperatura";
          }
        }

        if (shouldNotify) {
          await _sendNotification(
            flutterLocalNotificationsPlugin,
            location.displayName ?? location.name,
            airData,
            weatherData,
            changeDescription,
          );

          // Update State
          lastState[location.id] = {
            'aqi': airData.aqi,
            'condition': weatherData.condition,
            'temp': weatherData.temp,
            'timestamp': DateTime.now().toIso8601String(),
          };
          stateChanged = true;
        }
      }
    } catch (e) {
      print("Error checking location ${location.name}: $e");
    }
  }

  // 6. Save New State
  if (stateChanged) {
    await prefs.setString('lastKnownState', json.encode(lastState));
  }
}

Future<void> _sendNotification(
  FlutterLocalNotificationsPlugin plugin,
  String locationName,
  AirQualityData airData,
  WeatherData weather,
  String reason,
) async {
  final BigTextStyleInformation bigTextStyleInformation =
      BigTextStyleInformation(
    '${_getWeatherEmoji(weather.condition)} ${weather.condition} ${weather.temp.round()}°C\n'
    '${_getAqiEmoji(airData.aqi)} Calidad del aire: ${_getAqiLevelText(airData.aqi)}\n'
    'ℹ️ $reason',
    htmlFormatBigText: true,
    contentTitle: '$locationName: Actualización',
    htmlFormatContentTitle: true,
  );

  final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'air_quality_channel', // Match main app channel ID
    'Alertas de Calidad del Aire', // Match main app channel name
    channelDescription:
        'Notificaciones sobre cambios en el clima y calidad del aire',
    importance: Importance.high,
    priority: Priority.high,
    styleInformation: bigTextStyleInformation,
  );

  final NotificationDetails details =
      NotificationDetails(android: androidDetails);

  await plugin.show(
    DateTime.now().millisecondsSinceEpoch ~/ 1000, // Unique ID
    '$locationName: Actualización',
    '${_getWeatherEmoji(weather.condition)} ${weather.temp.round()}°C | AQI: ${airData.aqi}',
    details,
  );
}

// Helpers (Duplicated for standalone background service)
String _getAqiLevelText(int aqi) {
  switch (aqi) {
    case 1:
      return 'Bueno';
    case 2:
      return 'Regular';
    case 3:
      return 'Moderado';
    case 4:
      return 'Malo';
    case 5:
      return 'Muy Malo';
    case 6:
      return 'Peligroso';
    default:
      return 'Desconocido';
  }
}

String _getAqiEmoji(int aqi) {
  switch (aqi) {
    case 1:
    case 2:
      return '🍃';
    case 3:
      return '⚠️';
    case 4:
    case 5:
      return '🚨';
    case 6:
      return '☢️';
    default:
      return '📊';
  }
}

String _getWeatherEmoji(String condition) {
  final lower = condition.toLowerCase();
  if (lower.contains('sun') ||
      lower.contains('sol') ||
      lower.contains('clear') ||
      lower.contains('despejado')) return '☀️';
  if (lower.contains('cloud') ||
      lower.contains('nube') ||
      lower.contains('nublado')) return '☁️';
  if (lower.contains('rain') || lower.contains('lluvia')) return '🌧️';
  if (lower.contains('storm') || lower.contains('tormenta')) return '⛈️';
  if (lower.contains('snow') || lower.contains('nieve')) return '❄️';
  if (lower.contains('mist') ||
      lower.contains('fog') ||
      lower.contains('niebla')) return '🌫️';
  return '🌡️';
}
