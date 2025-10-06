import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:air_quality_flutter/models/models.dart';

// URL de tu backend de Flask (ajusta si corre en otro lugar)
const String flaskBackendUrl = "http://127.0.0.1:5000/api";

class ApiService {
  // --- OBTENER DATOS ACTUALES ---
  Future<AirQualityData> getAirQuality(
      double latitude, double longitude) async {
    final response = await http.get(
      Uri.parse('$flaskBackendUrl/air_quality?lat=$latitude&lon=$longitude'),
    );
    if (response.statusCode == 200) {
      return AirQualityData.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load air quality data');
    }
  }

  // --- BUSCAR UBICACIONES (Nominatim) ---
  Future<List<LocationSearchResult>> searchLocation(String query) async {
    final response = await http.get(
        Uri.parse(
            'https://nominatim.openstreetmap.org/search?format=json&q=$query&limit=5'),
        headers: {'User-Agent': 'AirQualityApp/1.0'});
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => LocationSearchResult.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search for location');
    }
  }

  // --- NUEVO: OBTENER HISTORIAL ---
  Future<List<HistoricalDataPoint>> getHistory(
      double latitude, double longitude) async {
    final response = await http.get(
      Uri.parse('$flaskBackendUrl/history?lat=$latitude&lon=$longitude'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => HistoricalDataPoint.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load history data');
    }
  }

  // --- NUEVO: OBTENER UBICACIONES GUARDADAS ---
  Future<List<SavedLocation>> getSavedLocations() async {
    final response = await http.get(Uri.parse('$flaskBackendUrl/locations'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => SavedLocation.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load saved locations');
    }
  }

  // --- NUEVO: AÑADIR/ACTUALIZAR UBICACIÓN GUARDADA ---
  Future<void> addSavedLocation(SavedLocation location) async {
    final response = await http.post(
      Uri.parse('$flaskBackendUrl/locations'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(location.toJson()),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to save location');
    }
  }

  // --- NUEVO: ELIMINAR UBICACIÓN GUARDADA ---
  Future<void> deleteSavedLocation(String id) async {
    final response =
        await http.delete(Uri.parse('$flaskBackendUrl/locations/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete location');
    }
  }
}
