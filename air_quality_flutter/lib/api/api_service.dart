import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:air_quality_flutter/models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/foundation.dart' show kIsWeb;

// --- URL PARA DEPURACIÓN LOCAL ---
// Detecta automáticamente si estamos en Web o en Android Emulator
String get flaskBackendUrl {
  if (kIsWeb) {
    return "http://127.0.0.1:5000/api";
  } else {
    return "http://10.0.2.2:5000/api";
  }
}

//const String flaskBackendUrl = "https://air-quality-api-2b88.onrender.com/api";

class ApiService {
  String? _userId;

  // Obtiene o genera un ID de usuario único para este dispositivo
  Future<String> _getUserId() async {
    if (_userId != null) return _userId!;

    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('user_id');

    if (_userId == null) {
      // Generar un nuevo ID único
      _userId =
          'user_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(9999)}';
      await prefs.setString('user_id', _userId!);
      print('Generated new user ID: $_userId');
    } else {
      print('Loaded existing user ID: $_userId');
    }

    return _userId!;
  }

  // --- OBTENER DATOS ACTUALES ---
  Future<AirQualityData> getAirQuality(
      double latitude, double longitude) async {
    final response = await http.get(
      Uri.parse('$flaskBackendUrl/air_quality?lat=$latitude&lon=$longitude'),
    );
    if (response.statusCode == 200) {
      return AirQualityData.fromJson(json.decode(response.body));
    } else {
      throw Exception(
          'Failed to load air quality data. Status: ${response.statusCode}');
    }
  }

  // --- BUSCAR UBICACIONES (Nominatim) ---
  Future<List<LocationSearchResult>> searchLocation(String query) async {
    final response = await http.get(
        Uri.parse(
            'https://nominatim.openstreetmap.org/search?format=json&q=$query&limit=5'),
        headers: {'User-Agent': 'AuraClimaApp/1.0'});
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
    final response = await http.get(
      Uri.parse('$flaskBackendUrl/history?lat=$latitude&lon=$longitude'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => HistoricalDataPoint.fromJson(json)).toList();
    } else {
      throw Exception(
          'Failed to load history data. Status: ${response.statusCode}');
    }
  }

  // --- GESTIÓN DE UBICACIONES GUARDADAS ---
  Future<List<SavedLocation>> getSavedLocations() async {
    final userId = await _getUserId();
    final response =
        await http.get(Uri.parse('$flaskBackendUrl/locations?user_id=$userId'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => SavedLocation.fromJson(json)).toList();
    } else {
      throw Exception(
          'Failed to load saved locations. Status: ${response.statusCode}');
    }
  }

  // --- AÑADIR/ACTUALIZAR UBICACIÓN GUARDADA ---
  Future<void> addSavedLocation(SavedLocation location) async {
    final userId = await _getUserId();
    final locationData = location.toJson();
    locationData['user_id'] = userId;

    final response = await http.post(
      Uri.parse('$flaskBackendUrl/locations'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(locationData),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to save location');
    }
  }

  // --- ELIMINAR UBICACIÓN GUARDADA ---
  Future<void> deleteSavedLocation(String id) async {
    final userId = await _getUserId();
    final response = await http
        .delete(Uri.parse('$flaskBackendUrl/locations/$id?user_id=$userId'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete location');
    }
  }

  // --- OBTENER CLIMA Y PRONÓSTICO ---
  Future<Map<String, dynamic>> getWeather(
      double latitude, double longitude) async {
    final response = await http.get(
      Uri.parse('$flaskBackendUrl/weather?lat=$latitude&lon=$longitude'),
    );
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

  // --- OBTENER CONSEJO PERSONALIZADO (GEMINI) ---
  Future<HealthAdvice> getAdvice({
    required String weatherCondition,
    required int aqi,
    required Map<String, dynamic> components,
  }) async {
    final response = await http.post(
      Uri.parse('$flaskBackendUrl/advice'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'weather': weatherCondition,
        'aqi': {
          'aqi': aqi,
          'components': components,
        }
      }),
    );

    if (response.statusCode == 200) {
      return HealthAdvice.fromJson(json.decode(response.body));
    } else {
      print('Error getting advice: ${response.body}');
      return const HealthAdvice(
          advice: "No se pudo obtener el consejo en este momento.");
    }
  }

  // --- HISTORIAL DE VISITAS A UBICACIONES ---
  Future<List<LocationVisit>> getLocationHistory(TimeFilter filter) async {
    final userId = await _getUserId();
    final days = filter.days;

    final response = await http.get(
      Uri.parse(
          '$flaskBackendUrl/locations/history?user_id=$userId&days=$days'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => LocationVisit.fromJson(json)).toList();
    } else {
      throw Exception(
          'Failed to load location history. Status: ${response.statusCode}');
    }
  }

  Future<void> recordLocationVisit(
      double lat, double lon, String locationName) async {
    final userId = await _getUserId();

    final response = await http.post(
      Uri.parse('$flaskBackendUrl/locations/visit'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'user_id': userId,
        'latitude': lat,
        'longitude': lon,
        'location_name': locationName,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      print('Failed to record location visit: ${response.statusCode}');
      // No lanzamos excepción para no interrumpir la experiencia del usuario
    }
  }
}
