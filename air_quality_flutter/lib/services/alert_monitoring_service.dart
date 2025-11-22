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

        // Send notification if AQI exceeds threshold (only on mobile)
        if (airQuality.aqi >= _aqiAlertThreshold && !kIsWeb) {
          await _sendAlert(
            location.name,
            airQuality.aqi,
            languageCode: languageCode,
          );
        }

        // 2. Check Weather (if enabled)
        if (appState.notificationSettings['weather'] == true && !kIsWeb) {
          await _checkWeatherAndNotify(location, languageCode: languageCode);
        }
      } catch (e) {
        print('Error checking alerts for ${location.name}: $e');
      }
    }

    return results;
  }

  /// Checks weather and sends a notification if appropriate
  Future<void> _checkWeatherAndNotify(
    AlertLocation location, {
    required String languageCode,
  }) async {
    // Simple rate limiting: only send weather notification if we haven't sent one recently
    // For now, we'll rely on the main check interval (1 hour), but ideally this should be daily.
    // To avoid spamming every hour, let's check if the hour is e.g. 8 AM or 6 PM,
    // OR just send it if it's the first check of the session.
    // For this MVP, we'll just send it. To prevent spam, we could add a local timestamp map.

    try {
      final weatherData = await _apiService.getWeather(
        location.latitude!,
        location.longitude!,
        language: languageCode,
      );

      final current = weatherData['current'] as WeatherData;
      final forecast = weatherData['forecast'] as List<ForecastItem>;

      if (forecast.isNotEmpty) {
        final today = forecast.first;
        await _sendWeatherNotification(
          location.name,
          current,
          today,
          languageCode: languageCode,
        );
      }
    } catch (e) {
      print('Error checking weather for ${location.name}: $e');
    }
  }

  Future<void> _sendWeatherNotification(
    String locationName,
    WeatherData current,
    ForecastItem today, {
    required String languageCode,
  }) async {
    try {
      // Fetch AI-generated weather advice
      final weatherAdvice = await _apiService.getWeatherAdvice(
        temp: current.temp,
        condition: current.condition,
        minTemp: today.minTemp,
        maxTemp: today.maxTemp,
        language: languageCode,
      );

      // Use simple translations for titles
      final title =
          '${current.temp.round()}°${languageCode == 'en' ? 'C in' : 'C en'} $locationName';
      final body = '${weatherAdvice.advice}';

      await _notificationService.showNotification(
        title: title,
        body: body,
      );
    } catch (e) {
      print('Error sending weather notification: $e');
      // Fallback to simple notification
      final title =
          '${current.temp.round()}°${languageCode == 'en' ? 'C in' : 'C en'} $locationName';
      final maxMin = languageCode == 'en'
          ? 'Max: ${today.maxTemp.round()}° Min: ${today.minTemp.round()}°'
          : 'Máx: ${today.maxTemp.round()}° Mín: ${today.minTemp.round()}°';
      final body = '${current.condition}. $maxMin';

      await _notificationService.showNotification(
        title: title,
        body: body,
      );
    }
  }

  /// Sends a notification for poor air quality
  Future<void> _sendAlert(
    String locationName,
    int aqi, {
    required String languageCode,
  }) async {
    final aqiLevel = _getAqiLevelText(aqi, languageCode);
    final aqiColor = _getAqiEmoji(aqi);
    final alertTitle = languageCode == 'en'
        ? 'Air Quality Alert'
        : 'Alerta de Calidad del Aire';

    await _notificationService.showNotification(
      title: '$aqiColor $alertTitle',
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
      // Spanish (default)
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

  /// Checks if enough time has passed since last check
  /// to avoid spamming notifications
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

  /// Resets the check timer (useful for manual refresh)
  void resetCheckTimer() {
    _lastCheckTime = null;
  }
}
