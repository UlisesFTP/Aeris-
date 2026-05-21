import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/models.dart';

/// Gestiona la caché local de datos del mapa (AQI + clima + pronóstico).
///
/// La caché se invalida si la ubicación cambia más de ~2 km o tiene más de 15 min.
/// Reemplaza los métodos cacheMapData / getCachedMapData de AppState.
/// Consumers: MapScreen.
@singleton
class MapDataNotifier extends ChangeNotifier {
  final SharedPreferences _prefs;

  MapDataNotifier(this._prefs);

  /// Guarda en caché los datos de AQI + clima para una ubicación.
  Future<void> cacheMapData({
    required double lat,
    required double lon,
    required AirQualityData airQuality,
    required WeatherData weather,
    required List<ForecastItem> forecast,
  }) async {
    final cache = {
      'lat': lat,
      'lon': lon,
      'timestamp': DateTime.now().toIso8601String(),
      'airQuality': {
        'aqi': airQuality.aqi,
        'components': airQuality.components,
      },
      'weather': {
        'temp': weather.temp,
        'condition': weather.condition,
        'icon': weather.icon,
      },
      'forecast': forecast
          .map((f) => {
                'date': f.date,
                'min_temp': f.minTemp,
                'max_temp': f.maxTemp,
                'icon': f.icon,
                'condition': f.condition,
                'aqi': f.aqi,
              })
          .toList(),
    };
    await _prefs.setString('_cachedMapData', json.encode(cache));
  }

  /// Retorna datos cacheados si la ubicación está cerca (< 2 km) y son recientes (< 15 min).
  /// Retorna null si no hay caché válida.
  Map<String, dynamic>? getCachedMapData(double lat, double lon) {
    final raw = _prefs.getString('_cachedMapData');
    if (raw == null) return null;
    try {
      final cache = json.decode(raw) as Map<String, dynamic>;
      final cachedLat = (cache['lat'] as num).toDouble();
      final cachedLon = (cache['lon'] as num).toDouble();
      final timestamp = DateTime.parse(cache['timestamp'] as String);
      final age = DateTime.now().difference(timestamp);

      final distanceOk =
          (lat - cachedLat).abs() < 0.02 && (lon - cachedLon).abs() < 0.02;
      final timeOk = age <= const Duration(minutes: 15);

      if (distanceOk && timeOk) return cache;
    } catch (_) {}
    return null;
  }
}
