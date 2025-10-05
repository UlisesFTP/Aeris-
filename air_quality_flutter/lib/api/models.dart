class AirQualityData {
  final int aqi;
  final Map<String, dynamic> components;

  AirQualityData({required this.aqi, required this.components});

  factory AirQualityData.fromJson(Map<String, dynamic> json) {
    return AirQualityData(
      aqi: json['aqi'] as int,
      components: Map<String, dynamic>.from(json['components']),
    );
  }
}

// Modelo para un resultado de búsqueda de ubicación de Nominatim.
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
      displayName: json['display_name'] as String,
      latitude: double.parse(json['lat'] as String),
      longitude: double.parse(json['lon'] as String),
    );
  }
}

// --- NUEVO MODELO ---
// Modelo para un registro histórico de calidad del aire desde MongoDB.
class HistoricalAirQualityData {
  final String id;
  final int aqi;
  final Map<String, dynamic> components;
  final DateTime savedAt;

  HistoricalAirQualityData({
    required this.id,
    required this.aqi,
    required this.components,
    required this.savedAt,
  });

  // El factory 'fromJson' sabe cómo parsear la estructura específica de MongoDB.
  factory HistoricalAirQualityData.fromJson(Map<String, dynamic> json) {
    return HistoricalAirQualityData(
      id: json['_id']['\$oid'] as String,
      aqi: json['aqi'] as int,
      components: Map<String, dynamic>.from(json['components']),
      savedAt: DateTime.fromMillisecondsSinceEpoch(
        int.parse(json['saved_at']['\$date']['\$numberLong'] as String),
      ),
    );
  }
}
