// Este archivo define las estructuras de datos (modelos) que la aplicación utiliza.

// Modelo para los datos de calidad del aire recibidos de nuestra API de Flask.
class AirQualityData {
  final int aqi;
  final Map<String, dynamic> components;

  const AirQualityData({required this.aqi, required this.components});

  // Factory constructor para crear una instancia desde un mapa JSON.
  // Este es el punto clave: espera la ESTRUCTURA SIMPLIFICADA de nuestro backend.
  factory AirQualityData.fromJson(Map<String, dynamic> json) {
    return AirQualityData(
      // Usamos '?? 0' para proveer un valor por defecto si 'aqi' es nulo.
      aqi: json['aqi'] as int? ?? 0,
      // Hacemos lo mismo para los componentes.
      components: json['components'] as Map<String, dynamic>? ?? {},
    );
  }
}

// Modelo para un resultado de búsqueda de ubicación de la API de Nominatim.
class LocationSearchResult {
  final String displayName;
  final double latitude;
  final double longitude;

  const LocationSearchResult({
    required this.displayName,
    required this.latitude,
    required this.longitude,
  });

  factory LocationSearchResult.fromJson(Map<String, dynamic> json) {
    return LocationSearchResult(
      displayName: json['display_name'] as String? ?? 'Ubicación Desconocida',
      latitude: double.tryParse(json['lat'] as String? ?? '0.0') ?? 0.0,
      longitude: double.tryParse(json['lon'] as String? ?? '0.0') ?? 0.0,
    );
  }
}

// Modelo para un punto de datos en el historial.
class HistoricalDataPoint {
  final DateTime date;
  final int aqi;

  const HistoricalDataPoint({required this.date, required this.aqi});

  factory HistoricalDataPoint.fromJson(Map<String, dynamic> json) {
    return HistoricalDataPoint(
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      aqi: json['aqi'] as int? ?? 0,
    );
  }
}

// Modelo para una ubicación guardada por el usuario.
class SavedLocation {
  final String?
      id; // El ID de MongoDB, puede ser nulo si es una nueva ubicación
  final String name;
  final String? displayName; // Puede ser nulo
  final double latitude;
  final double longitude;

  const SavedLocation({
    this.id,
    required this.name,
    this.displayName,
    required this.latitude,
    required this.longitude,
  });

  // Convierte un resultado de búsqueda en una ubicación guardable
  factory SavedLocation.fromSearchResult(LocationSearchResult result) {
    return SavedLocation(
      name: result.displayName, // El nombre por defecto es el display name
      displayName: result.displayName,
      latitude: result.latitude,
      longitude: result.longitude,
    );
  }

  // Convierte un SavedLocation de vuelta a un LocationSearchResult para la navegación
  LocationSearchResult toLocationSearchResult() {
    return LocationSearchResult(
      displayName: displayName ?? name,
      latitude: latitude,
      longitude: longitude,
    );
  }

  factory SavedLocation.fromJson(Map<String, dynamic> json) {
    return SavedLocation(
      id: json['_id'] as String?,
      name: json['name'] as String? ?? 'Sin Nombre',
      displayName: json['displayName'] as String?,
      latitude: json['latitude'] as double? ?? 0.0,
      longitude: json['longitude'] as double? ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'name': name,
      'displayName': displayName ?? name,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class WeatherData {
  final double temp;
  final String condition;
  final String icon;

  const WeatherData({
    required this.temp,
    required this.condition,
    required this.icon,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      temp: (json['temp'] as num?)?.toDouble() ?? 0.0,
      condition: json['condition'] as String? ?? '',
      icon: json['icon'] as String? ?? '',
    );
  }
}

class ForecastItem {
  final String date;
  final double minTemp;
  final double maxTemp;
  final String icon;
  final String condition;

  const ForecastItem({
    required this.date,
    required this.minTemp,
    required this.maxTemp,
    required this.icon,
    required this.condition,
  });

  factory ForecastItem.fromJson(Map<String, dynamic> json) {
    return ForecastItem(
      date: json['date'] as String? ?? '',
      minTemp: (json['min_temp'] as num?)?.toDouble() ?? 0.0,
      maxTemp: (json['max_temp'] as num?)?.toDouble() ?? 0.0,
      icon: json['icon'] as String? ?? '',
      condition: json['condition'] as String? ?? '',
    );
  }
}

class HealthAdvice {
  final String advice;

  const HealthAdvice({required this.advice});

  factory HealthAdvice.fromJson(Map<String, dynamic> json) {
    return HealthAdvice(
      advice: json['advice'] as String? ?? 'No hay consejos disponibles.',
    );
  }
}
