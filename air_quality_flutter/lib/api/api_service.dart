import 'dart:convert';
import 'package:http/http.dart' as http;
// CORRECCIÓN DEFINITIVA: Apuntamos a la única fuente de verdad.
import 'package:air_quality_flutter/models/models.dart';

// URL del backend de Flask
const String flaskBackendUrl = "http://127.0.0.1:5000/api";

class ApiService {
  // Obtiene la calidad del aire actual para una latitud y longitud.
  Future<AirQualityData> getAirQuality(double lat, double lon) async {
    final response = await http.get(
      Uri.parse('$flaskBackendUrl/air_quality?lat=$lat&lon=$lon'),
    );

    if (response.statusCode == 200) {
      return AirQualityData.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load air quality data.');
    }
  }

  // Busca ubicaciones usando la API de Nominatim.
  Future<List<LocationSearchResult>> searchLocation(String query) async {
    final response = await http.get(
      Uri.parse(
          'https://nominatim.openstreetmap.org/search?format=json&q=$query&limit=5'),
      headers: {'User-Agent': 'AirQualityFlutterApp/1.0'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => LocationSearchResult.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search for location.');
    }
  }
}
