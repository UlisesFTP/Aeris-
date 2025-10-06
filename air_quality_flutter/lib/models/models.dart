import 'dart:convert';

// --- MODELO PARA DATOS DE CALIDAD DEL AIRE (ACTUAL Y PREDICCIÓN) ---
class AirQualityData {
  final int aqi;
  final Map<String, dynamic> components;

  AirQualityData({required this.aqi, required this.components});

  factory AirQualityData.fromJson(Map<String, dynamic> json) {
    // La API de OpenWeather anida los datos en una lista
    final data = json['list'][0];
    return AirQualityData(
      aqi: data['main']['aqi'],
      components: Map<String, dynamic>.from(data['components']),
    );
  }
}

// --- MODELO PARA RESULTADOS DE BÚSQUEDA DE UBICACIÓN ---
class LocationSearchResult {
  final String displayName;
  final double latitude;
  final double longitude;

  LocationSearchResult({
    required this.displayName,
    required this.latitude,
    required this.longitude,
  });

  factory LocationSearchResult.fromJson(Map<String, dynamic> json) {
    return LocationSearchResult(
      displayName: json['display_name'],
      latitude: double.parse(json['lat']),
      longitude: double.parse(json['lon']),
    );
  }
}

// --- MODELO PARA UBICACIONES GUARDADAS (FAVORITAS Y RECIENTES) ---
class SavedLocation {
  final String?
      id; // El ID de MongoDB (opcional, puede ser nulo para nuevas ubicaciones)
  final String name;
  final double latitude;
  final double longitude;
  final String? displayName; // Para ubicaciones recientes

  SavedLocation({
    this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.displayName,
  });

  // Constructor para crear desde un resultado de búsqueda (para "recientes")
  factory SavedLocation.fromSearchResult(LocationSearchResult result) {
    return SavedLocation(
      name: result.displayName, // Usamos el displayName como nombre
      latitude: result.latitude,
      longitude: result.longitude,
      displayName: result.displayName,
    );
  }

  // Constructor para decodificar desde JSON (usado para SharedPreferences)
  factory SavedLocation.fromJson(Map<String, dynamic> json) {
    return SavedLocation(
      id: json['_id']?['\$oid'],
      name: json['name'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      displayName: json['displayName'],
    );
  }

  // Método para codificar a JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'displayName': displayName,
    };
  }

  LocationSearchResult toLocationSearchResult() {
    return LocationSearchResult(
      displayName: displayName ?? name,
      latitude: latitude,
      longitude: longitude,
    );
  }
}

// --- MODELO PARA DATOS DEL HISTORIAL ---
class HistoricalDataPoint {
  final DateTime date;
  final int aqi;

  HistoricalDataPoint({required this.date, required this.aqi});

  factory HistoricalDataPoint.fromJson(Map<String, dynamic> json) {
    return HistoricalDataPoint(
      date: DateTime.parse(json['date']),
      aqi: json['aqi'],
    );
  }
}

// --- MODELO PARA DATOS DE PREDICCIÓN ---
class ForecastDataPoint {
  final DateTime timestamp;
  final int aqi;

  ForecastDataPoint({required this.timestamp, required this.aqi});

  factory ForecastDataPoint.fromJson(Map<String, dynamic> json) {
    return ForecastDataPoint(
      timestamp:
          DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000, isUtc: true)
              .toLocal(),
      aqi: json['main']['aqi'],
    );
  }
}
