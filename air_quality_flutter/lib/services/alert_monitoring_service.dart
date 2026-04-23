import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
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

    // Load shared preferences to sync with background service
    final prefs = await SharedPreferences.getInstance();
    final String? lastStateString = prefs.getString('lastKnownState');
    Map<String, dynamic> lastState = {};
    if (lastStateString != null) {
      lastState = json.decode(lastStateString);
    }

    for (final location in locationsToCheck) {
      try {
        // Check if we should skip based on recent background update
        if (!force && lastState.containsKey(location.id)) {
          final lastUpdate =
              DateTime.parse(lastState[location.id]['timestamp']);
          if (DateTime.now().difference(lastUpdate).inMinutes < 30) {
            print(
                'Skipping ${location.name} - updated recently by background service');
            continue;
          }
        }

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

          // Update state for background service
          // We need weather data for the state, so we might need to fetch it here if not already
          // _handleCombinedAlert fetches weather, but we don't have it here easily unless we refactor.
          // For now, let's just mark the timestamp. The background service will re-fetch and update full state next time.
          // Or better, let _handleCombinedAlert return the weather data or update the state.
          // Let's make _handleCombinedAlert return the WeatherData.
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

      // 4. Update Shared State (for background sync)
      final prefs = await SharedPreferences.getInstance();
      final String? lastStateString = prefs.getString('lastKnownState');
      Map<String, dynamic> lastState = {};
      if (lastStateString != null) {
        lastState = json.decode(lastStateString);
      }

      lastState[location.id] = {
        'aqi': airQuality.aqi,
        'condition': current.condition,
        'temp': current.temp,
        'timestamp': DateTime.now().toIso8601String(),
      };

      await prefs.setString('lastKnownState', json.encode(lastState));
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
    final title = languageCode == 'en'
        ? 'Air Quality & Weather'
        : 'Calidad del Aire y Clima';

    // Body Construction
    final sb = StringBuffer();

    // Line 1: Weather
    final weatherEmoji = _getWeatherEmoji(weather.condition);
    sb.writeln('$weatherEmoji ${weather.condition} ${weather.temp.round()}°C');

    // Line 2: AQI Status
    final aqiEmoji = _getAqiEmoji(airQuality.aqi);
    final aqiText = _getAqiLevelText(airQuality.aqi, languageCode);
    final aqiLabel = languageCode == 'en' ? 'Air Quality' : 'Calidad del aire';
    sb.writeln('$aqiEmoji $aqiLabel: $aqiText');

    // Line 3: AI Recommendation (if enabled)
    if (useAi) {
      try {
        final advice = await _apiService.getAdvice(
          weatherCondition: weather.condition,
          aqi: airQuality.aqi,
          components: airQuality.components,
          language: languageCode,
        );
        sb.writeln('\n${advice.advice}');
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
