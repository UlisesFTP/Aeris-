import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:air_quality_flutter/api/api_service.dart';
import 'package:air_quality_flutter/api/notifications_service.dart';
import 'package:air_quality_flutter/core/app_state.dart';
import 'package:air_quality_flutter/models/models.dart';

class AlertMonitoringService {
  final ApiService _apiService = ApiService();
  final NotificationService _notificationService = NotificationService();

  // AQI threshold for sending alerts (4 = Poor, 5 = Very Poor, 6 = Hazardous)
  static const int _aqiAlertThreshold = 4;

  /// Checks air quality for all enabled alert locations
  /// Returns a map of location names to their AQI values
  Future<Map<String, int>> checkAlertLocations(
    AppState appState, {
    required String languageCode,
    bool force = false,
  }) async {
    final results = <String, int>{};
    final locationsToCheck = appState.alertLocations.values
        .where((loc) => loc.enabled && loc.isConfigured)
        .toList();

    for (final location in locationsToCheck) {
      try {
        // 1. Check Air Quality
        final airQuality = await _apiService.getAirQuality(
          location.latitude!,
          location.longitude!,
        );

        results[location.name] = airQuality.aqi;

        // Send notification if AQI exceeds threshold OR if forced (only on mobile)
        if ((airQuality.aqi >= _aqiAlertThreshold || force) && !kIsWeb) {
          await _handleCombinedAlert(
            location,
            airQuality,
            appState.notificationSettings,
            languageCode,
          );
        }
      } catch (e) {
        print('Error checking alerts for ${location.name}: $e');
      }
    }

    return results;
  }

  /// Handles the logic for fetching weather/AI data and sending the combined alert
  Future<void> _handleCombinedAlert(
    AlertLocation location,
    AirQualityData airQuality,
    Map<String, bool> settings,
    String languageCode,
  ) async {
    try {
      // 1. Fetch Weather Data
      final weatherMap = await _apiService.getWeather(
        location.latitude!,
        location.longitude!,
        language: languageCode,
      );
      final current = weatherMap['current'] as WeatherData;

      // 2. Check AI Preference
      final useAi = settings['useAiRecommendations'] ?? true;

      // 3. Construct and Send Notification
      await _sendCombinedNotification(
        location.name,
        airQuality,
        current,
        useAi,
        languageCode,
      );
    } catch (e) {
      print('Error preparing combined alert: $e');
      // Fallback: Send simple AQI alert if weather/AI fails
      await _sendSimpleAqiAlert(location.name, airQuality.aqi, languageCode);
    }
  }

  Future<void> _sendCombinedNotification(
    String locationName,
    AirQualityData airQuality,
    WeatherData weather,
    bool useAi,
    String languageCode,
  ) async {
    // Title
    final aqiEmoji = _getAqiEmoji(airQuality.aqi);
    final title = languageCode == 'en'
        ? '$aqiEmoji Air Quality Alert'
        : '$aqiEmoji Alerta de Calidad del Aire';

    // Body Construction
    final sb = StringBuffer();

    // Part 1: AQI Status
    final aqiText = _getAqiLevelText(airQuality.aqi, languageCode);
    sb.writeln('$locationName: $aqiText (AQI: ${airQuality.aqi})');

    // Part 2: Simplified Particles
    final pm25 = airQuality.components['pm2_5'];
    final pm10 = airQuality.components['pm10'];
    if (pm25 != null || pm10 != null) {
      sb.write('🌫️ ');
      if (pm25 != null) sb.write('PM2.5: ${pm25.round()} ');
      if (pm10 != null) sb.write('PM10: ${pm10.round()}');
      sb.writeln();
    }

    // Part 3: Weather
    final weatherEmoji = _getWeatherEmoji(weather.condition);
    sb.writeln(
        '$weatherEmoji ${weather.temp.round()}°C - ${weather.condition}');

    // Part 4: AI Recommendation (if enabled)
    if (useAi) {
      try {
        final advice = await _apiService.getAdvice(
          weatherCondition: weather.condition,
          aqi: airQuality.aqi,
          components: airQuality.components,
          language: languageCode,
        );
        sb.writeln('\n💡 ${advice.advice}');
      } catch (e) {
        print('Error fetching AI advice: $e');
      }
    }

    await _notificationService.showNotification(
      title: title,
      body: sb.toString(),
    );
  }

  Future<void> _sendSimpleAqiAlert(
      String locationName, int aqi, String languageCode) async {
    final aqiLevel = _getAqiLevelText(aqi, languageCode);
    final aqiEmoji = _getAqiEmoji(aqi);
    final alertTitle = languageCode == 'en'
        ? 'Air Quality Alert'
        : 'Alerta de Calidad del Aire';

    await _notificationService.showNotification(
      title: '$aqiEmoji $alertTitle',
      body: '$locationName: $aqiLevel (AQI: $aqi)',
    );
  }

  /// Gets the text description for an AQI level
  String _getAqiLevelText(int aqi, String languageCode) {
    if (languageCode == 'en') {
      switch (aqi) {
        case 1:
          return 'Good';
        case 2:
          return 'Fair';
        case 3:
          return 'Moderate';
        case 4:
          return 'Poor';
        case 5:
          return 'Very Poor';
        case 6:
          return 'Dangerous';
        default:
          return 'Unknown';
      }
    } else {
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
  }

  /// Gets an emoji for visual representation
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
        lower.contains('despejado')) {
      return '☀️';
    } else if (lower.contains('cloud') ||
        lower.contains('nube') ||
        lower.contains('nublado')) {
      return '☁️';
    } else if (lower.contains('rain') ||
        lower.contains('lluvia') ||
        lower.contains('drizzle')) {
      return '🌧️';
    } else if (lower.contains('storm') || lower.contains('tormenta')) {
      return '⛈️';
    } else if (lower.contains('snow') || lower.contains('nieve')) {
      return '❄️';
    } else if (lower.contains('mist') ||
        lower.contains('fog') ||
        lower.contains('niebla')) {
      return '🌫️';
    }
    return '🌡️';
  }

  /// Checks if enough time has passed since last check
  static DateTime? _lastCheckTime;
  static const Duration _minimumCheckInterval = Duration(hours: 1);

  bool shouldCheckNow() {
    if (_lastCheckTime == null) return true;
    final timeSinceLastCheck = DateTime.now().difference(_lastCheckTime!);
    return timeSinceLastCheck >= _minimumCheckInterval;
  }

  void markCheckComplete() {
    _lastCheckTime = DateTime.now();
  }

  void resetCheckTimer() {
    _lastCheckTime = null;
  }
}
