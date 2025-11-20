// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Air Quality Monitor';

  @override
  String get searchHint => 'Search location...';

  @override
  String get searchResults => 'Search Results';

  @override
  String get currentWeather => 'Current Weather';

  @override
  String get pollutionLevel => 'Pollution Level';

  @override
  String get weeklyForecast => 'Weekly Forecast';

  @override
  String get historicalTrends => 'Historical Trends';

  @override
  String get saveLocation => 'Save Location';

  @override
  String get saveLocationHint => 'Ex: Home, Office...';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get saved => 'saved.';

  @override
  String get locationSaved => 'Location saved';

  @override
  String get selectLocation => 'Select a location';

  @override
  String get currentLocation => 'Current Location';

  @override
  String get locationInMap => 'Location on map';

  @override
  String get errorGeolocation => 'Geolocation Error';

  @override
  String get errorSearch => 'Search Error';

  @override
  String get errorData => 'Error fetching data';

  @override
  String get noForecast => 'No forecast available';

  @override
  String get selectLocationMessage => 'Select a location.';

  @override
  String get healthAdvice => 'Health Advice (AI)';

  @override
  String get aqiGood => 'Good';

  @override
  String get aqiFair => 'Fair';

  @override
  String get aqiModerate => 'Moderate';

  @override
  String get aqiPoor => 'Poor';

  @override
  String get aqiVeryPoor => 'Very Poor';

  @override
  String get aqiDangerous => 'Dangerous';

  @override
  String get aqiRecommendationGood =>
      'Air quality is considered satisfactory, and air pollution poses little or no risk.';

  @override
  String get aqiRecommendationFair =>
      'Air quality is acceptable; however, for some pollutants there may be a moderate health concern for a very small number of people who are unusually sensitive to air pollution.';

  @override
  String get aqiRecommendationModerate =>
      'Members of sensitive groups may experience health effects. The general public is not likely to be affected.';

  @override
  String get aqiRecommendationPoor =>
      'Everyone may begin to experience health effects; members of sensitive groups may experience more serious health effects.';

  @override
  String get aqiRecommendationVeryPoor =>
      'Health warnings of emergency conditions. The entire population is more likely to be affected.';

  @override
  String get aqiRecommendationDangerous =>
      'Health alert: everyone may experience more serious health effects.';
}
