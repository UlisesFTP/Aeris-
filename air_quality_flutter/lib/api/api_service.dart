import 'dart:convert';
import 'package:http/http.dart' as http;
// Se cambia a una importación absoluta de paquete para mayor robustez.
import 'package:air_quality_flutter/api/models.dart';

class ApiService {
  // URL de tu backend de Flask
  static const String _flaskBackendUrl = "http://127.0.0.1:5000/api";
  // URL de la API de Nominatim (OpenStreetMap)
  static const String _nominatimUrl = "https://nominatim.openstreetmap.org";

  // Obtiene los datos de calidad del aire desde nuestro backend
  Future<AirQualityData> getAirQuality(double lat, double lon) async {
    final uri = Uri.parse('$_flaskBackendUrl/air_quality?lat=$lat&lon=$lon');
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        return AirQualityData.fromJson(json.decode(response.body));
      } else {
        // Si el servidor responde con un error, lo lanzamos.
        throw Exception('Error al cargar datos de calidad del aire');
      }
    } catch (e) {
      // Si hay un error de conexión, también lo lanzamos.
      throw Exception('No se pudo conectar al servidor: $e');
    }
  }

  // Busca una ubicación usando la API de Nominatim
  Future<List<LocationSearchResult>> searchLocation(String query) async {
    final uri = Uri.parse('$_nominatimUrl/search?format=json&q=$query&limit=5');
    try {
      // Nominatim requiere un User-Agent
      final response = await http.get(uri, headers: {
        'User-Agent': 'AirQualityFlutterApp/1.0',
      });

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => LocationSearchResult.fromJson(json)).toList();
      } else {
        throw Exception('Error al buscar la ubicación');
      }
    } catch (e) {
      throw Exception('Error de conexión al buscar ubicación: $e');
    }
  }
}
