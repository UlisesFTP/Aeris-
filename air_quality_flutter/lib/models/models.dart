class AirQualityData {
  final Map<String, dynamic> coordinates;
  final int aqi;
  final Map<String, dynamic> components;

  AirQualityData({
    required this.coordinates,
    required this.aqi,
    required this.components,
  });

  factory AirQualityData.fromJson(Map<String, dynamic> json) {
    return AirQualityData(
      coordinates: json['coordinates'],
      aqi: json['aqi'],
      components: json['components'],
    );
  }
}

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
