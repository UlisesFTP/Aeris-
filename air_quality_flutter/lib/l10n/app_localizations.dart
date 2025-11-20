import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Air Quality Monitor'**
  String get appTitle;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search location...'**
  String get searchHint;

  /// No description provided for @searchResults.
  ///
  /// In en, this message translates to:
  /// **'Search Results'**
  String get searchResults;

  /// No description provided for @currentWeather.
  ///
  /// In en, this message translates to:
  /// **'Current Weather'**
  String get currentWeather;

  /// No description provided for @pollutionLevel.
  ///
  /// In en, this message translates to:
  /// **'Pollution Level'**
  String get pollutionLevel;

  /// No description provided for @weeklyForecast.
  ///
  /// In en, this message translates to:
  /// **'Weekly Forecast'**
  String get weeklyForecast;

  /// No description provided for @historicalTrends.
  ///
  /// In en, this message translates to:
  /// **'Historical Trends'**
  String get historicalTrends;

  /// No description provided for @saveLocation.
  ///
  /// In en, this message translates to:
  /// **'Save Location'**
  String get saveLocation;

  /// No description provided for @saveLocationHint.
  ///
  /// In en, this message translates to:
  /// **'Ex: Home, Office...'**
  String get saveLocationHint;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'saved.'**
  String get saved;

  /// No description provided for @locationSaved.
  ///
  /// In en, this message translates to:
  /// **'Location saved'**
  String get locationSaved;

  /// No description provided for @selectLocation.
  ///
  /// In en, this message translates to:
  /// **'Select a location'**
  String get selectLocation;

  /// No description provided for @currentLocation.
  ///
  /// In en, this message translates to:
  /// **'Current Location'**
  String get currentLocation;

  /// No description provided for @locationInMap.
  ///
  /// In en, this message translates to:
  /// **'Location on map'**
  String get locationInMap;

  /// No description provided for @errorGeolocation.
  ///
  /// In en, this message translates to:
  /// **'Geolocation Error'**
  String get errorGeolocation;

  /// No description provided for @errorSearch.
  ///
  /// In en, this message translates to:
  /// **'Search Error'**
  String get errorSearch;

  /// No description provided for @errorData.
  ///
  /// In en, this message translates to:
  /// **'Error fetching data'**
  String get errorData;

  /// No description provided for @noForecast.
  ///
  /// In en, this message translates to:
  /// **'No forecast available'**
  String get noForecast;

  /// No description provided for @selectLocationMessage.
  ///
  /// In en, this message translates to:
  /// **'Select a location.'**
  String get selectLocationMessage;

  /// No description provided for @healthAdvice.
  ///
  /// In en, this message translates to:
  /// **'Health Advice (AI)'**
  String get healthAdvice;

  /// No description provided for @aqiGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get aqiGood;

  /// No description provided for @aqiFair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get aqiFair;

  /// No description provided for @aqiModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get aqiModerate;

  /// No description provided for @aqiPoor.
  ///
  /// In en, this message translates to:
  /// **'Poor'**
  String get aqiPoor;

  /// No description provided for @aqiVeryPoor.
  ///
  /// In en, this message translates to:
  /// **'Very Poor'**
  String get aqiVeryPoor;

  /// No description provided for @aqiDangerous.
  ///
  /// In en, this message translates to:
  /// **'Dangerous'**
  String get aqiDangerous;

  /// No description provided for @aqiRecommendationGood.
  ///
  /// In en, this message translates to:
  /// **'Air quality is considered satisfactory, and air pollution poses little or no risk.'**
  String get aqiRecommendationGood;

  /// No description provided for @aqiRecommendationFair.
  ///
  /// In en, this message translates to:
  /// **'Air quality is acceptable; however, for some pollutants there may be a moderate health concern for a very small number of people who are unusually sensitive to air pollution.'**
  String get aqiRecommendationFair;

  /// No description provided for @aqiRecommendationModerate.
  ///
  /// In en, this message translates to:
  /// **'Members of sensitive groups may experience health effects. The general public is not likely to be affected.'**
  String get aqiRecommendationModerate;

  /// No description provided for @aqiRecommendationPoor.
  ///
  /// In en, this message translates to:
  /// **'Everyone may begin to experience health effects; members of sensitive groups may experience more serious health effects.'**
  String get aqiRecommendationPoor;

  /// No description provided for @aqiRecommendationVeryPoor.
  ///
  /// In en, this message translates to:
  /// **'Health warnings of emergency conditions. The entire population is more likely to be affected.'**
  String get aqiRecommendationVeryPoor;

  /// No description provided for @aqiRecommendationDangerous.
  ///
  /// In en, this message translates to:
  /// **'Health alert: everyone may experience more serious health effects.'**
  String get aqiRecommendationDangerous;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
