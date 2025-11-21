// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Aeris';

  @override
  String get welcomeTitle => 'Welcome to Aeris';

  @override
  String get welcomeSubtitle => 'Your clean air companion';

  @override
  String get welcomeFeature1Title => 'Real-Time Monitoring';

  @override
  String get welcomeFeature1Desc => 'Check air quality and weather instantly.';

  @override
  String get welcomeFeature2Title => 'Smart Alerts';

  @override
  String get welcomeFeature2Desc => 'Get notified when air quality worsens.';

  @override
  String get welcomeFeature3Title => 'Detailed History';

  @override
  String get welcomeFeature3Desc => 'Analyze historical pollution trends.';

  @override
  String get welcomeButton => 'Get Started';

  @override
  String get navMap => 'Map';

  @override
  String get navHistory => 'History';

  @override
  String get navAlerts => 'Alerts';

  @override
  String get navSettings => 'Settings';

  @override
  String get mapSearchPlaceholder => 'Search city...';

  @override
  String get mapCurrentWeather => 'Current Weather';

  @override
  String get mapWeatherAdvice => 'Weather Advice';

  @override
  String get mapHealthAdvice => 'Recommendation (AI)';

  @override
  String get mapAirQuality => 'Air Quality';

  @override
  String get mapPollutants => 'Pollutants';

  @override
  String get mapHistoryChart => 'History (Last 24h)';

  @override
  String get mapViewFullHistory => 'View full history';

  @override
  String get historyTitle => 'Air Quality History';

  @override
  String get historyLast7Days => 'Last 7 days';

  @override
  String get historyChartTitle => 'AQI Trend';

  @override
  String get historyNoData => 'No historical data available.';

  @override
  String get alertsTitle => 'Alert Settings';

  @override
  String get alertsSubtitle => 'Manage your notifications';

  @override
  String get alertsSectionPollutants => 'Pollutant Types';

  @override
  String get alertsSwitchAirQuality => 'Air Quality (AQI)';

  @override
  String get alertsSwitchAirQualitySubtitle =>
      'Notify when air is poor or dangerous';

  @override
  String get alertsSwitchWeather => 'Weather Status';

  @override
  String get alertsSwitchWeatherSubtitle => 'Daily notifications like Google';

  @override
  String get alertsSectionLocations => 'Saved Locations';

  @override
  String get alertsAddLocation => 'Add Location';

  @override
  String get alertsCurrentLocation => 'Current Location';

  @override
  String get alertsSavedLocation => 'Saved Location';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSectionGeneral => 'General';

  @override
  String get settingsThemeDark => 'Dark Mode';

  @override
  String get settingsThemeDarkSubtitle => 'Change app appearance';

  @override
  String get settingsSectionSystem => 'System';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsNotificationsSubtitle => 'Manage system permissions';

  @override
  String get settingsLocation => 'Location';

  @override
  String get settingsLocationSubtitle => 'Manage location permissions';

  @override
  String get settingsSectionInfo => 'Info';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsPrivacyPolicy => 'Privacy Policy';

  @override
  String get settingsTermsOfService => 'Terms of Service';

  @override
  String get settingsFooter => 'Aeris v1.0.0';

  @override
  String get legalPrivacyTitle => 'Privacy Policy';

  @override
  String get legalTermsTitle => 'Terms of Service';

  @override
  String get legalFooter => 'Aeris - Free App';

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
  String get errorLoading => 'Error loading data';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get next => 'Next';

  @override
  String get historyTabDay => 'Day';

  @override
  String get historyTabWeek => 'Week';

  @override
  String get historyTabMonth => 'Month';

  @override
  String get historySectionSaved => 'Saved Locations';

  @override
  String get historyNoSavedLocations => 'No saved locations';

  @override
  String get historySectionVisits => 'Recent Visits';

  @override
  String get historyNoRecentHistory => 'No recent history';

  @override
  String get historyDeleteTitle => 'Delete Location';

  @override
  String historyDeleteConfirmation(String name) {
    return 'Are you sure you want to delete $name?';
  }

  @override
  String historyDeleted(String name) {
    return 'Location $name deleted';
  }

  @override
  String get alertsNewLocation => 'New Location';

  @override
  String get alertsNewLocationHint => 'City name';

  @override
  String alertsSelectLocation(String name) {
    return 'Select Location for $name';
  }

  @override
  String get alertsVerifying => 'Verifying...';

  @override
  String alertsVerified(int count) {
    return 'Verified ($count)';
  }

  @override
  String get alertsCheckNow => 'Check Now';

  @override
  String get alertsCurrentLocationSubtitle => 'Use device location';

  @override
  String get alertsPollutantWeather => 'Weather';

  @override
  String get alertsPollutantWeatherSubtitle => 'Weather status';

  @override
  String get alertsPollutantPM25 => 'PM2.5';

  @override
  String get alertsPollutantPM25Subtitle => 'Fine particles';

  @override
  String get alertsPollutantPM10 => 'PM10';

  @override
  String get alertsPollutantPM10Subtitle => 'Respirable particles';

  @override
  String get alertsPollutantO3 => 'Ozone (O3)';

  @override
  String get alertsPollutantO3Subtitle => 'Ground-level ozone';

  @override
  String get alertsLocationHome => 'Home';

  @override
  String get alertsLocationWork => 'Work';

  @override
  String get alertsTapToConfigure => 'Tap to configure';

  @override
  String alertsLocationOf(String name) {
    return 'Location of $name';
  }
}
