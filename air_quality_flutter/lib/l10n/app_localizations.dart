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
  /// In es, this message translates to:
  /// **'Aeris'**
  String get appTitle;

  /// No description provided for @welcomeTitle.
  ///
  /// In es, this message translates to:
  /// **'Bienvenido a Aeris'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Tu compañero de aire limpio'**
  String get welcomeSubtitle;

  /// No description provided for @welcomeFeature1Title.
  ///
  /// In es, this message translates to:
  /// **'Monitoreo en Tiempo Real'**
  String get welcomeFeature1Title;

  /// No description provided for @welcomeFeature1Desc.
  ///
  /// In es, this message translates to:
  /// **'Consulta la calidad del aire y el clima al instante.'**
  String get welcomeFeature1Desc;

  /// No description provided for @welcomeFeature2Title.
  ///
  /// In es, this message translates to:
  /// **'Alertas Inteligentes'**
  String get welcomeFeature2Title;

  /// No description provided for @welcomeFeature2Desc.
  ///
  /// In es, this message translates to:
  /// **'Recibe notificaciones cuando la calidad del aire empeore.'**
  String get welcomeFeature2Desc;

  /// No description provided for @welcomeFeature3Title.
  ///
  /// In es, this message translates to:
  /// **'Historial Detallado'**
  String get welcomeFeature3Title;

  /// No description provided for @welcomeFeature3Desc.
  ///
  /// In es, this message translates to:
  /// **'Analiza tendencias históricas de contaminación.'**
  String get welcomeFeature3Desc;

  /// No description provided for @welcomeButton.
  ///
  /// In es, this message translates to:
  /// **'Comenzar'**
  String get welcomeButton;

  /// No description provided for @navMap.
  ///
  /// In es, this message translates to:
  /// **'Mapa'**
  String get navMap;

  /// No description provided for @navHistory.
  ///
  /// In es, this message translates to:
  /// **'Historial'**
  String get navHistory;

  /// No description provided for @navAlerts.
  ///
  /// In es, this message translates to:
  /// **'Alertas'**
  String get navAlerts;

  /// No description provided for @navSettings.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get navSettings;

  /// No description provided for @mapSearchPlaceholder.
  ///
  /// In es, this message translates to:
  /// **'Buscar ciudad...'**
  String get mapSearchPlaceholder;

  /// No description provided for @mapCurrentWeather.
  ///
  /// In es, this message translates to:
  /// **'Clima Actual'**
  String get mapCurrentWeather;

  /// No description provided for @mapWeatherAdvice.
  ///
  /// In es, this message translates to:
  /// **'Consejo del Clima'**
  String get mapWeatherAdvice;

  /// No description provided for @mapHealthAdvice.
  ///
  /// In es, this message translates to:
  /// **'Recomendación (IA)'**
  String get mapHealthAdvice;

  /// No description provided for @mapAirQuality.
  ///
  /// In es, this message translates to:
  /// **'Calidad del Aire'**
  String get mapAirQuality;

  /// No description provided for @mapPollutants.
  ///
  /// In es, this message translates to:
  /// **'Contaminantes'**
  String get mapPollutants;

  /// No description provided for @mapHistoryChart.
  ///
  /// In es, this message translates to:
  /// **'Historial (Últimas 24h)'**
  String get mapHistoryChart;

  /// No description provided for @mapViewFullHistory.
  ///
  /// In es, this message translates to:
  /// **'Ver historial completo'**
  String get mapViewFullHistory;

  /// No description provided for @historyTitle.
  ///
  /// In es, this message translates to:
  /// **'Historial de Calidad del Aire'**
  String get historyTitle;

  /// No description provided for @historyLast7Days.
  ///
  /// In es, this message translates to:
  /// **'Últimos 7 días'**
  String get historyLast7Days;

  /// No description provided for @historyChartTitle.
  ///
  /// In es, this message translates to:
  /// **'Tendencia de AQI'**
  String get historyChartTitle;

  /// No description provided for @historyNoData.
  ///
  /// In es, this message translates to:
  /// **'No hay datos históricos disponibles.'**
  String get historyNoData;

  /// No description provided for @alertsTitle.
  ///
  /// In es, this message translates to:
  /// **'Configuración de Alertas'**
  String get alertsTitle;

  /// No description provided for @alertsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Gestiona tus notificaciones'**
  String get alertsSubtitle;

  /// No description provided for @alertsSectionPollutants.
  ///
  /// In es, this message translates to:
  /// **'Tipos de Contaminantes'**
  String get alertsSectionPollutants;

  /// No description provided for @alertsSwitchAirQuality.
  ///
  /// In es, this message translates to:
  /// **'Calidad del Aire (AQI)'**
  String get alertsSwitchAirQuality;

  /// No description provided for @alertsSwitchAirQualitySubtitle.
  ///
  /// In es, this message translates to:
  /// **'Notificar cuando el aire sea malo o peligroso'**
  String get alertsSwitchAirQualitySubtitle;

  /// No description provided for @alertsSwitchWeather.
  ///
  /// In es, this message translates to:
  /// **'Estado del Clima'**
  String get alertsSwitchWeather;

  /// No description provided for @alertsSwitchWeatherSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones diarias como en Google'**
  String get alertsSwitchWeatherSubtitle;

  /// No description provided for @alertsSectionLocations.
  ///
  /// In es, this message translates to:
  /// **'Ubicaciones Guardadas'**
  String get alertsSectionLocations;

  /// No description provided for @alertsAddLocation.
  ///
  /// In es, this message translates to:
  /// **'Agregar Ubicación'**
  String get alertsAddLocation;

  /// No description provided for @alertsCurrentLocation.
  ///
  /// In es, this message translates to:
  /// **'Ubicación Actual'**
  String get alertsCurrentLocation;

  /// No description provided for @alertsSavedLocation.
  ///
  /// In es, this message translates to:
  /// **'Ubicación Guardada'**
  String get alertsSavedLocation;

  /// No description provided for @settingsTitle.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get settingsTitle;

  /// No description provided for @settingsSectionGeneral.
  ///
  /// In es, this message translates to:
  /// **'General'**
  String get settingsSectionGeneral;

  /// No description provided for @settingsThemeDark.
  ///
  /// In es, this message translates to:
  /// **'Tema Oscuro'**
  String get settingsThemeDark;

  /// No description provided for @settingsThemeDarkSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Cambiar apariencia de la aplicación'**
  String get settingsThemeDarkSubtitle;

  /// No description provided for @settingsSectionSystem.
  ///
  /// In es, this message translates to:
  /// **'Sistema'**
  String get settingsSectionSystem;

  /// No description provided for @settingsNotifications.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones'**
  String get settingsNotifications;

  /// No description provided for @settingsNotificationsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Gestionar permisos en el sistema'**
  String get settingsNotificationsSubtitle;

  /// No description provided for @settingsLocation.
  ///
  /// In es, this message translates to:
  /// **'Ubicación'**
  String get settingsLocation;

  /// No description provided for @settingsLocationSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Gestionar permisos de ubicación'**
  String get settingsLocationSubtitle;

  /// No description provided for @settingsSectionInfo.
  ///
  /// In es, this message translates to:
  /// **'Información'**
  String get settingsSectionInfo;

  /// No description provided for @settingsVersion.
  ///
  /// In es, this message translates to:
  /// **'Versión'**
  String get settingsVersion;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In es, this message translates to:
  /// **'Política de Privacidad'**
  String get settingsPrivacyPolicy;

  /// No description provided for @settingsTermsOfService.
  ///
  /// In es, this message translates to:
  /// **'Términos de Servicio'**
  String get settingsTermsOfService;

  /// No description provided for @settingsFooter.
  ///
  /// In es, this message translates to:
  /// **'Aeris v1.0.0'**
  String get settingsFooter;

  /// No description provided for @legalPrivacyTitle.
  ///
  /// In es, this message translates to:
  /// **'Política de Privacidad'**
  String get legalPrivacyTitle;

  /// No description provided for @legalTermsTitle.
  ///
  /// In es, this message translates to:
  /// **'Términos de Servicio'**
  String get legalTermsTitle;

  /// No description provided for @legalFooter.
  ///
  /// In es, this message translates to:
  /// **'Aeris - App Gratuita'**
  String get legalFooter;

  /// No description provided for @aqiGood.
  ///
  /// In es, this message translates to:
  /// **'Bueno'**
  String get aqiGood;

  /// No description provided for @aqiFair.
  ///
  /// In es, this message translates to:
  /// **'Regular'**
  String get aqiFair;

  /// No description provided for @aqiModerate.
  ///
  /// In es, this message translates to:
  /// **'Moderado'**
  String get aqiModerate;

  /// No description provided for @aqiPoor.
  ///
  /// In es, this message translates to:
  /// **'Malo'**
  String get aqiPoor;

  /// No description provided for @aqiVeryPoor.
  ///
  /// In es, this message translates to:
  /// **'Muy Malo'**
  String get aqiVeryPoor;

  /// No description provided for @aqiDangerous.
  ///
  /// In es, this message translates to:
  /// **'Peligroso'**
  String get aqiDangerous;

  /// No description provided for @errorLoading.
  ///
  /// In es, this message translates to:
  /// **'Error cargando datos'**
  String get errorLoading;

  /// No description provided for @retry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get delete;

  /// No description provided for @next.
  ///
  /// In es, this message translates to:
  /// **'Siguiente'**
  String get next;

  /// No description provided for @historyTabDay.
  ///
  /// In es, this message translates to:
  /// **'Día'**
  String get historyTabDay;

  /// No description provided for @historyTabWeek.
  ///
  /// In es, this message translates to:
  /// **'Semana'**
  String get historyTabWeek;

  /// No description provided for @historyTabMonth.
  ///
  /// In es, this message translates to:
  /// **'Mes'**
  String get historyTabMonth;

  /// No description provided for @historySectionSaved.
  ///
  /// In es, this message translates to:
  /// **'Ubicaciones Guardadas'**
  String get historySectionSaved;

  /// No description provided for @historyNoSavedLocations.
  ///
  /// In es, this message translates to:
  /// **'No hay ubicaciones guardadas'**
  String get historyNoSavedLocations;

  /// No description provided for @historySectionVisits.
  ///
  /// In es, this message translates to:
  /// **'Visitas Recientes'**
  String get historySectionVisits;

  /// No description provided for @historyNoRecentHistory.
  ///
  /// In es, this message translates to:
  /// **'No hay historial reciente'**
  String get historyNoRecentHistory;

  /// No description provided for @historyDeleteTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar Ubicación'**
  String get historyDeleteTitle;

  /// No description provided for @historyDeleteConfirmation.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que quieres eliminar {name}?'**
  String historyDeleteConfirmation(String name);

  /// No description provided for @historyDeleted.
  ///
  /// In es, this message translates to:
  /// **'Ubicación {name} eliminada'**
  String historyDeleted(String name);

  /// No description provided for @alertsNewLocation.
  ///
  /// In es, this message translates to:
  /// **'Nueva Ubicación'**
  String get alertsNewLocation;

  /// No description provided for @alertsNewLocationHint.
  ///
  /// In es, this message translates to:
  /// **'Nombre de la ciudad'**
  String get alertsNewLocationHint;

  /// No description provided for @alertsSelectLocation.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar Ubicación para {name}'**
  String alertsSelectLocation(String name);

  /// No description provided for @alertsVerifying.
  ///
  /// In es, this message translates to:
  /// **'Verificando...'**
  String get alertsVerifying;

  /// No description provided for @alertsVerified.
  ///
  /// In es, this message translates to:
  /// **'Verificado ({count})'**
  String alertsVerified(int count);

  /// No description provided for @alertsCheckNow.
  ///
  /// In es, this message translates to:
  /// **'Comprobar Ahora'**
  String get alertsCheckNow;

  /// No description provided for @alertsCurrentLocationSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Usar ubicación del dispositivo'**
  String get alertsCurrentLocationSubtitle;

  /// No description provided for @alertsPollutantWeather.
  ///
  /// In es, this message translates to:
  /// **'Clima'**
  String get alertsPollutantWeather;

  /// No description provided for @alertsPollutantWeatherSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Estado del tiempo'**
  String get alertsPollutantWeatherSubtitle;

  /// No description provided for @alertsPollutantPM25.
  ///
  /// In es, this message translates to:
  /// **'PM2.5'**
  String get alertsPollutantPM25;

  /// No description provided for @alertsPollutantPM25Subtitle.
  ///
  /// In es, this message translates to:
  /// **'Partículas finas'**
  String get alertsPollutantPM25Subtitle;

  /// No description provided for @alertsPollutantPM10.
  ///
  /// In es, this message translates to:
  /// **'PM10'**
  String get alertsPollutantPM10;

  /// No description provided for @alertsPollutantPM10Subtitle.
  ///
  /// In es, this message translates to:
  /// **'Partículas respirables'**
  String get alertsPollutantPM10Subtitle;

  /// No description provided for @alertsPollutantO3.
  ///
  /// In es, this message translates to:
  /// **'Ozono (O3)'**
  String get alertsPollutantO3;

  /// No description provided for @alertsPollutantO3Subtitle.
  ///
  /// In es, this message translates to:
  /// **'Ozono troposférico'**
  String get alertsPollutantO3Subtitle;

  /// No description provided for @alertsLocationHome.
  ///
  /// In es, this message translates to:
  /// **'Casa'**
  String get alertsLocationHome;

  /// No description provided for @alertsLocationWork.
  ///
  /// In es, this message translates to:
  /// **'Trabajo'**
  String get alertsLocationWork;

  /// No description provided for @alertsTapToConfigure.
  ///
  /// In es, this message translates to:
  /// **'Toca para configurar'**
  String get alertsTapToConfigure;

  /// No description provided for @alertsLocationOf.
  ///
  /// In es, this message translates to:
  /// **'Ubicación de {name}'**
  String alertsLocationOf(String name);

  /// No description provided for @legalPrivacyContent.
  ///
  /// In es, this message translates to:
  /// **'**Política de Privacidad de Aeris**\\n\\n**Última actualización:** 21 de Noviembre de 2024\\n\\n**1. Introducción**\\nAeris es una aplicación gratuita desarrollada para informar sobre la calidad del aire y el clima. No mostramos anuncios ni vendemos tus datos.\\n\\n**2. Recopilación de Datos**\\nAeris NO recopila, almacena ni comparte información personal identificable. No requerimos registro ni inicio de sesión.\\n\\n**3. Datos de Ubicación**\\nPara proporcionarte datos precisos del clima y calidad del aire, la aplicación necesita acceso a tu ubicación.\\n- Las coordenadas se envían a nuestros proveedores de datos (OpenWeather) de forma anónima.\\n- Si guardas una ubicación, las coordenadas se almacenan cifradas en nuestro servidor seguro.\\n- No rastreamos tu historial de movimientos fuera de las consultas que realizas activamente.\\n\\n**4. Servicios de Terceros**\\nUtilizamos servicios de confianza para obtener datos:\\n- **OpenWeather:** Para datos meteorológicos y de calidad del aire.\\n- **Google Gemini:** Para generar recomendaciones de salud y clima basadas en los datos actuales.\\n\\n**5. Contacto**\\nSi tienes preguntas sobre esta política, contáctanos a través de la tienda de aplicaciones.'**
  String get legalPrivacyContent;

  /// No description provided for @legalTermsContent.
  ///
  /// In es, this message translates to:
  /// **'**Términos de Servicio de Aeris**\\n\\n**1. Aceptación**\\nAl usar Aeris, aceptas estos términos. La aplicación es gratuita y se proporciona tal cual.\\n\\n**2. Uso de la Aplicación**\\nEres libre de usar la aplicación para fines personales e informativos. No está permitido realizar ingeniería inversa ni intentar dañar nuestros servicios.\\n\\n**3. Descargo de Responsabilidad**\\nLa información de salud y clima es generada por Inteligencia Artificial y proveedores externos.\\n- **No es un consejo médico:** Las recomendaciones son solo informativas. Consulta siempre a un profesional de la salud.\\n- **Precisión:** No garantizamos que los datos sean 100% exactos en todo momento.\\n\\n**4. Cambios**\\nPodemos actualizar estos términos en cualquier momento. El uso continuo implica la aceptación de los cambios.'**
  String get legalTermsContent;
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
