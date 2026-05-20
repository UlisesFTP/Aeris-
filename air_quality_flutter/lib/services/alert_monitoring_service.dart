import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:air_quality_flutter/api/api_service.dart';
import 'package:air_quality_flutter/api/notifications_service.dart';
import 'package:air_quality_flutter/models/models.dart';

@singleton
class AlertMonitoringService {
  final ApiService _apiService;
  final NotificationService _notificationService;

  AlertMonitoringService(this._apiService, this._notificationService);

  // AQI threshold for sending intrusive alerts (4 = Poor)
  static const int _aqiAlertThreshold = 4;

  /// Verifica la calidad del aire para todas las ubicaciones de alerta habilitadas,
  /// incluyendo la posición actual del dispositivo (si miUbicacion está activo).
  ///
  /// Recibe los datos directamente en lugar de depender de AppState.
  Future<Map<String, int>> checkAlertLocations({
    required Map<String, AlertLocation> alertLocations,
    required Map<String, bool> notificationSettings,
    required String languageCode,
    bool force = false,
  }) async {
    final results = <String, int>{};

    // 1. Build list of locations to check (saved locations)
    final locationsToCheck = alertLocations.values
        .where((loc) => loc.enabled && loc.isConfigured)
        .toList();

    // 2. Add current device location if monitoring is enabled
    final prefs = await SharedPreferences.getInstance();
    final bool monitorCurrent =
        notificationSettings['miUbicacion'] ?? true;
    if (monitorCurrent) {
      final String? lastPosString = prefs.getString('lastKnownDevicePosition');
      if (lastPosString != null) {
        try {
          final lastPosJson = json.decode(lastPosString);
          final lat = (lastPosJson['lat'] as num).toDouble();
          final lon = (lastPosJson['lon'] as num).toDouble();
          final timestamp = DateTime.parse(lastPosJson['timestamp'] as String);
          // Valid for 2 hours
          if (DateTime.now().difference(timestamp) <=
              const Duration(hours: 2)) {
            locationsToCheck.insert(
              0,
              AlertLocation(
                id: 'current_device',
                name: 'Mi Ubicación',
                latitude: lat,
                longitude: lon,
                displayName: 'Ubicación Actual',
                enabled: true,
              ),
            );
          }
        } catch (e) {
          print('Error reading lastKnownDevicePosition: $e');
        }
      }
    }

    // 3. Load last known state for deduplication
    final String? lastStateString = prefs.getString('lastKnownState');
    Map<String, dynamic> lastState = {};
    if (lastStateString != null) {
      lastState = json.decode(lastStateString);
    }

    bool statusUpdated = false;

    for (final location in locationsToCheck) {
      try {
        // Skip if checked recently by background service (unless forced)
        if (!force && lastState.containsKey(location.id)) {
          final lastUpdate =
              DateTime.parse(lastState[location.id]['timestamp']);
          if (DateTime.now().difference(lastUpdate).inMinutes < 30) {
            print('Skipping ${location.name} - updated recently');
            continue;
          }
        }

        // Fetch AQI + Weather in parallel
        final responses = await Future.wait([
          _apiService.getAirQuality(location.latitude!, location.longitude!),
          _apiService.getWeather(
            location.latitude!,
            location.longitude!,
            language: languageCode,
          ),
        ]);
        final airQuality = responses[0] as AirQualityData;
        final weatherMap = responses[1] as Map<String, dynamic>;
        final currentWeather = weatherMap['current'] as WeatherData;

        results[location.name] = airQuality.aqi;

        // ── PERSISTENT STATUS NOTIFICATION (current location only) ─────────
        if (location.id == 'current_device' && !kIsWeb && !statusUpdated) {
          await NotificationService.showStatusNotificationStatic(
            locationName: location.displayName ?? location.name,
            weatherCondition: currentWeather.condition,
            temp: currentWeather.temp,
            aqi: airQuality.aqi,
          );
          statusUpdated = true;
        }

        // ── INTRUSIVE ALERT (any location with bad AQI) ────────────────────
        if (airQuality.aqi >= _aqiAlertThreshold && !kIsWeb) {
          await _notificationService.showAqiAlertNotification(
            locationName: location.displayName ?? location.name,
            aqi: airQuality.aqi,
            weatherCondition: currentWeather.condition,
            temp: currentWeather.temp,
            languageCode: languageCode,
          );
        }

        // Update shared state for background sync
        lastState[location.id] = {
          'aqi': airQuality.aqi,
          'condition': currentWeather.condition,
          'temp': currentWeather.temp,
          'timestamp': DateTime.now().toIso8601String(),
        };
      } catch (e) {
        print('Error checking alerts for ${location.name}: $e');
      }
    }

    await prefs.setString('lastKnownState', json.encode(lastState));
    return results;
  }

  /// Checks if enough time has passed since last check
  static DateTime? _lastCheckTime;
  static const Duration _minimumCheckInterval = Duration(minutes: 15);

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
