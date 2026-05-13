import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:air_quality_flutter/models/models.dart';

// --- URL PARA DEPURACIÓN LOCAL ---
// Detecta automáticamente si estamos en Web o en Android Emulator

import 'package:flutter_dotenv/flutter_dotenv.dart';

String get flaskBackendUrl {
  return dotenv.env['API_URL'] ?? "http://127.0.0.1:5000/api";
}

/// Timeout global para todas las peticiones HTTP al backend.
/// Se aumentó a 45 segundos para dar tiempo a que Render despierte (cold start).
const Duration _kHttpTimeout = Duration(seconds: 45);

class ApiService {

  // --- OBTENER DATOS ACTUALES ---
  Future<AirQualityData> getAirQuality(
      double latitude, double longitude) async {
    final response = await http
        .get(
          Uri.parse('$flaskBackendUrl/air_quality?lat=$latitude&lon=$longitude'),
        )
        .timeout(_kHttpTimeout);
    if (response.statusCode == 200) {
      return AirQualityData.fromJson(json.decode(response.body));
    } else {
      throw Exception(
          'Failed to load air quality data. Status: ${response.statusCode}');
    }
  }

  // --- BUSCAR UBICACIONES (Nominatim via Proxy) ---
  Future<List<LocationSearchResult>> searchLocation(String query) async {
    final response = await http
        .get(Uri.parse('$flaskBackendUrl/search?q=$query'))
        .timeout(_kHttpTimeout);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => LocationSearchResult.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search for location');
    }
  }

  // --- OBTENER HISTORIAL ---
  Future<List<HistoricalDataPoint>> getHistory(
      double latitude, double longitude) async {
    final response = await http
        .get(
          Uri.parse('$flaskBackendUrl/history?lat=$latitude&lon=$longitude'),
        )
        .timeout(_kHttpTimeout);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => HistoricalDataPoint.fromJson(json)).toList();
    } else {
      throw Exception(
          'Failed to load history data. Status: ${response.statusCode}');
    }
  }

  // --- OBTENER CLIMA Y PRONÓSTICO ---
  Future<Map<String, dynamic>> getWeather(double latitude, double longitude,
      {String language = 'es'}) async {
    final response = await http
        .get(
          Uri.parse(
              '$flaskBackendUrl/weather?lat=$latitude&lon=$longitude&lang=$language'),
        )
        .timeout(_kHttpTimeout);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        "current": WeatherData.fromJson(data['current']),
        "forecast": (data['forecast'] as List)
            .map((item) => ForecastItem.fromJson(item))
            .toList(),
      };
    } else {
      throw Exception(
          'Failed to load weather data. Status: ${response.statusCode}');
    }
  }

}
