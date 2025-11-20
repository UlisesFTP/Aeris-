// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Monitor de Calidad del Aire';

  @override
  String get searchHint => 'Buscar ubicación...';

  @override
  String get searchResults => 'Resultados de Búsqueda';

  @override
  String get currentWeather => 'Clima Actual';

  @override
  String get pollutionLevel => 'Nivel de Contaminación';

  @override
  String get weeklyForecast => 'Pronóstico Semanal';

  @override
  String get historicalTrends => 'Tendencias Históricas';

  @override
  String get saveLocation => 'Guardar Ubicación';

  @override
  String get saveLocationHint => 'Ej: Casa, Oficina...';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get saved => 'guardado.';

  @override
  String get locationSaved => 'Ubicación guardada';

  @override
  String get selectLocation => 'Selecciona una ubicación';

  @override
  String get currentLocation => 'Ubicación Actual';

  @override
  String get locationInMap => 'Ubicación en mapa';

  @override
  String get errorGeolocation => 'Error de Geolocalización';

  @override
  String get errorSearch => 'Error al buscar';

  @override
  String get errorData => 'Error al obtener datos';

  @override
  String get noForecast => 'No hay pronóstico disponible.';

  @override
  String get selectLocationMessage => 'Selecciona una ubicación.';

  @override
  String get healthAdvice => 'Recomendación (IA)';

  @override
  String get aqiGood => 'Bueno';

  @override
  String get aqiFair => 'Regular';

  @override
  String get aqiModerate => 'Moderado';

  @override
  String get aqiPoor => 'Malo';

  @override
  String get aqiVeryPoor => 'Muy Malo';

  @override
  String get aqiDangerous => 'Peligroso';

  @override
  String get aqiRecommendationGood =>
      'La calidad del aire se considera satisfactoria y la contaminación del aire presenta poco o ningún riesgo.';

  @override
  String get aqiRecommendationFair =>
      'La calidad del aire es aceptable; sin embargo, para algunos contaminantes puede haber una preocupación moderada para la salud de un número muy pequeño de personas que son inusualmente sensibles a la contaminación del aire.';

  @override
  String get aqiRecommendationModerate =>
      'Los miembros de grupos sensibles pueden experimentar efectos en la salud. Es poco probable que el público en general se vea afectado.';

  @override
  String get aqiRecommendationPoor =>
      'Todos pueden comenzar a experimentar efectos en la salud; los miembros de grupos sensibles pueden experimentar efectos de salud más graves.';

  @override
  String get aqiRecommendationVeryPoor =>
      'Advertencias de salud de condiciones de emergencia. Es más probable que toda la población se vea afectada.';

  @override
  String get aqiRecommendationDangerous =>
      'Alerta de salud: todos pueden experimentar efectos de salud más graves.';
}
