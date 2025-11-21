import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:air_quality_flutter/api/api_service.dart';
import 'package:air_quality_flutter/api/notifications_service.dart';
import 'package:air_quality_flutter/core/app_state.dart';

class AlertMonitoringService {
  final ApiService _apiService = ApiService();
  final NotificationService _notificationService = NotificationService();

  // AQI threshold for sending alerts (4 = Poor, 5 = Very Poor, 6 = Hazardous)
  static const int _aqiAlertThreshold = 4;

  /// Checks air quality for all enabled alert locations
  /// Returns a map of location names to their AQI values
  Future<Map<String, int>> checkAlertLocations(AppState appState) async {
    final results = <String, int>{};
    final locationsToCheck = appState.alertLocations.values
        .where((loc) => loc.enabled && loc.isConfigured)
        .toList();

    for (final location in locationsToCheck) {
      try {
        final airQuality = await _apiService.getAirQuality(
          location.latitude!,
          location.longitude!,
        );

        results[location.name] = airQuality.aqi;

        // Send notification if AQI exceeds threshold (only on mobile)
        if (airQuality.aqi >= _aqiAlertThreshold && !kIsWeb) {
          await _sendAlert(location.name, airQuality.aqi);
        }
      } catch (e) {
        print('Error checking AQI for ${location.name}: $e');
      }
    }

    return results;
  }

  /// Sends a notification for poor air quality
  Future<void> _sendAlert(String locationName, int aqi) async {
    final aqiLevel = _getAqiLevelText(aqi);
    final aqiColor = _getAqiEmoji(aqi);

    await _notificationService.showNotification(
      title: '$aqiColor Alerta de Calidad del Aire',
      body: '$locationName: $aqiLevel (AQI: $aqi)',
    );
  }

  /// Gets the text description for an AQI level
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
