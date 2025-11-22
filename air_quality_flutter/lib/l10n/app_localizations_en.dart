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

  @override
  String get mapSearchResults => 'Search Results';

  @override
  String get mapLocationOnMap => 'Location on map';

  @override
  String get mapSelectLocation => 'Select a location';

  @override
  String get mapSaveLocationTooltip => 'Save this location';

  @override
  String get mapSaveLocationHint => 'E.g.: Home, Office...';

  @override
  String get mapCancel => 'Cancel';

  @override
  String get mapSave => 'Save';

  @override
  String mapLocationSaved(String name) {
    return '\"$name\" saved.';
  }

  @override
  String get mapWeeklyForecast => 'Weekly Forecast';

  @override
  String get mapNoForecastAvailable => 'No forecast available.';

  @override
  String get mapSelectLocationPrompt => 'Select a location.';

  @override
  String mapErrorGeolocation(String error) {
    return 'Geolocation Error: $error';
  }

  @override
  String mapErrorSearching(String error) {
    return 'Error searching: $error';
  }

  @override
  String mapErrorGettingData(String error) {
    return 'Error getting data: $error';
  }

  @override
  String get mapHealthAdviceAI => 'Health Advice (AI)';

  @override
  String get legalPrivacyContent =>
      '**Aeris Privacy Policy**\\n\\n**Last Updated:** November 21, 2024\\n\\n**1. Introduction**\\nAeris is a free application developed to inform about air quality and weather. We do not show ads or sell your data.\\n\\n**2. Data Collection**\\nAeris does NOT collect, store, or share personally identifiable information. We do not require registration or login.\\n\\n**3. Location Data**\\nTo provide you with accurate weather and air quality data, the application needs access to your location.\\n- Coordinates are sent to our data providers (OpenWeather) anonymously.\\n- If you save a location, coordinates are stored encrypted on our secure server.\\n- We do not track your movement history outside of queries you actively make.\\n\\n**4. Third-Party Services**\\nWe use trusted services to obtain data:\\n- **OpenWeather:** For weather and air quality data.\\n- **Google Gemini:** To generate health and weather recommendations based on current data.\\n\\n**5. Contact**\\nIf you have questions about this policy, contact us through the app store.';

  @override
  String get legalTermsContent =>
      '**Aeris Terms of Service**\\n\\n**1. Acceptance**\\nBy using Aeris, you accept these terms. The application is free and provided as is.\\n\\n**2. Use of the Application**\\nYou are free to use the application for personal and informational purposes. Reverse engineering or attempting to harm our services is not permitted.\\n\\n**3. Disclaimer**\\nHealth and weather information is generated by Artificial Intelligence and external providers.\\n- **Not medical advice:** Recommendations are informational only. Always consult a healthcare professional.\\n- **Accuracy:** We do not guarantee that data is 100% accurate at all times.\\n\\n**4. Changes**\\nWe may update these terms at any time. Continued use implies acceptance of changes.';
}
