// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Aeris';

  @override
  String get welcomeTitle => 'Willkommen bei Aeris';

  @override
  String get welcomeSubtitle => 'Ihr Begleiter für saubere Luft';

  @override
  String get welcomeFeature1Title => 'Echtzeit-Überwachung';

  @override
  String get welcomeFeature1Desc => 'Luftqualität und Wetter sofort abrufen.';

  @override
  String get welcomeFeature2Title => 'Intelligente Warnungen';

  @override
  String get welcomeFeature2Desc =>
      'Benachrichtigung erhalten, wenn sich die Luft verschlechtert.';

  @override
  String get welcomeFeature3Title => 'Detaillierter Verlauf';

  @override
  String get welcomeFeature3Desc =>
      'Historische Trends der Luftverschmutzung analysieren.';

  @override
  String get welcomeButton => 'Loslegen';

  @override
  String get navMap => 'Karte';

  @override
  String get navHistory => 'Verlauf';

  @override
  String get navAlerts => 'Warnungen';

  @override
  String get navSettings => 'Einstellungen';

  @override
  String get mapSearchPlaceholder => 'Stadt suchen...';

  @override
  String get mapCurrentWeather => 'Aktuelles Wetter';

  @override
  String get mapWeatherAdvice => 'Wetter-Empfehlung';

  @override
  String get mapHealthAdvice => 'Empfehlung (KI)';

  @override
  String get mapAirQuality => 'Luftqualität';

  @override
  String get mapPollutants => 'Schadstoffe';

  @override
  String get mapHistoryChart => 'Verlauf (Letzte 24h)';

  @override
  String get mapViewFullHistory => 'Vollständigen Verlauf anzeigen';

  @override
  String get historyTitle => 'Luftqualitätsverlauf';

  @override
  String get historyLast7Days => 'Letzte 7 Tage';

  @override
  String get historyChartTitle => 'AQI-Trend';

  @override
  String get historyNoData => 'Keine Verlaufsdaten verfügbar.';

  @override
  String get alertsTitle => 'Warnungseinstellungen';

  @override
  String get alertsSubtitle => 'Benachrichtigungen verwalten';

  @override
  String get alertsSectionPollutants => 'Schadstoffarten';

  @override
  String get alertsSwitchAirQuality => 'Luftqualität (AQI)';

  @override
  String get alertsSwitchAirQualitySubtitle =>
      'Benachrichtigen bei schlechter oder gefährlicher Luft';

  @override
  String get alertsSwitchWeather => 'Wetterstatus';

  @override
  String get alertsSwitchWeatherSubtitle =>
      'Tägliche Benachrichtigungen wie bei Google';

  @override
  String get alertsSectionLocations => 'Gespeicherte Orte';

  @override
  String get alertsAddLocation => 'Ort hinzufügen';

  @override
  String get alertsCurrentLocation => 'Aktueller Standort';

  @override
  String get alertsSavedLocation => 'Gespeicherter Ort';

  @override
  String get alertsSectionPreferences => 'Benachrichtigungseinstellungen';

  @override
  String get alertsAiRecommendations => 'KI-Empfehlungen';

  @override
  String get alertsAiRecommendationsSubtitle =>
      'Personalisierte Ratschläge basierend auf Wetter und Luftqualität.';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsSectionGeneral => 'Allgemein';

  @override
  String get settingsThemeDark => 'Dunkelmodus';

  @override
  String get settingsThemeDarkSubtitle => 'App-Erscheinungsbild ändern';

  @override
  String get settingsLanguage => 'Sprache';

  @override
  String get settingsLanguageSubtitle => 'Wählen Sie Ihre bevorzugte Sprache';

  @override
  String get langSystem => 'Systemstandard';

  @override
  String get settingsSectionSystem => 'System';

  @override
  String get settingsNotifications => 'Benachrichtigungen';

  @override
  String get settingsNotificationsSubtitle => 'Systemberechtigungen verwalten';

  @override
  String get settingsLocation => 'Standort';

  @override
  String get settingsLocationSubtitle => 'Standortberechtigungen verwalten';

  @override
  String get settingsSectionInfo => 'Informationen';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsPrivacyPolicy => 'Datenschutzerklärung';

  @override
  String get settingsTermsOfService => 'Nutzungsbedingungen';

  @override
  String get settingsFooter => 'Aeris v1.0.0';

  @override
  String get legalPrivacyTitle => 'Datenschutzerklärung';

  @override
  String get legalTermsTitle => 'Nutzungsbedingungen';

  @override
  String get legalFooter => 'Aeris - Kostenlose App';

  @override
  String get aqiGood => 'Gut';

  @override
  String get aqiFair => 'Akzeptabel';

  @override
  String get aqiModerate => 'Mäßig';

  @override
  String get aqiPoor => 'Schlecht';

  @override
  String get aqiVeryPoor => 'Sehr Schlecht';

  @override
  String get aqiDangerous => 'Gefährlich';

  @override
  String get errorLoading => 'Fehler beim Laden';

  @override
  String get retry => 'Wiederholen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get delete => 'Löschen';

  @override
  String get next => 'Weiter';

  @override
  String get historyTabDay => 'Tag';

  @override
  String get historyTabWeek => 'Woche';

  @override
  String get historyTabMonth => 'Monat';

  @override
  String get historySectionSaved => 'Gespeicherte Orte';

  @override
  String get historyNoSavedLocations => 'Keine gespeicherten Orte';

  @override
  String get historySectionVisits => 'Letzte Besuche';

  @override
  String get historyNoRecentHistory => 'Keine letzten Besuche';

  @override
  String get historyDeleteTitle => 'Ort löschen';

  @override
  String historyDeleteConfirmation(String name) {
    return 'Sind Sie sicher, dass Sie $name löschen möchten ?';
  }

  @override
  String historyDeleted(String name) {
    return 'Ort $name gelöscht';
  }

  @override
  String get alertsNewLocation => 'Neuer Ort';

  @override
  String get alertsNewLocationHint => 'Stadtname';

  @override
  String alertsSelectLocation(String name) {
    return 'Ort auswählen für $name';
  }

  @override
  String get alertsVerifying => 'Überprüfen...';

  @override
  String alertsVerified(int count) {
    return 'Verifiziert ($count)';
  }

  @override
  String get alertsCheckNow => 'Jetzt prüfen';

  @override
  String get alertsCurrentLocationSubtitle => 'Gerätestandort verwenden';

  @override
  String get alertsPollutantWeather => 'Wetter';

  @override
  String get alertsPollutantWeatherSubtitle => 'Wetterstatus';

  @override
  String get alertsPollutantPM25 => 'PM2.5';

  @override
  String get alertsPollutantPM25Subtitle => 'Feinstaub';

  @override
  String get alertsPollutantPM10 => 'PM10';

  @override
  String get alertsPollutantPM10Subtitle => 'Einatembare Partikel';

  @override
  String get alertsPollutantO3 => 'Ozon (O3)';

  @override
  String get alertsPollutantO3Subtitle => 'Bodennahes Ozon';

  @override
  String get alertsLocationHome => 'Zuhause';

  @override
  String get alertsLocationWork => 'Arbeit';

  @override
  String get alertsTapToConfigure => 'Zum Konfigurieren tippen';

  @override
  String alertsLocationOf(String name) {
    return 'Standort von $name';
  }

  @override
  String get mapSearchResults => 'Suchergebnisse';

  @override
  String get mapLocationOnMap => 'Ort auf der Karte';

  @override
  String get mapSelectLocation => 'Ort auswählen';

  @override
  String get mapSaveLocationTooltip => 'Diesen Ort speichern';

  @override
  String get mapSaveLocationHint => 'Z.B.: Zuhause, Büro...';

  @override
  String get mapCancel => 'Abbrechen';

  @override
  String get mapSave => 'Speichern';

  @override
  String mapLocationSaved(String name) {
    return '\"$name\" gespeichert.';
  }

  @override
  String get mapWeeklyForecast => 'Wochenvorhersage';

  @override
  String get mapNoForecastAvailable => 'Keine Vorhersage verfügbar.';

  @override
  String get mapSelectLocationPrompt => 'Wählen Sie einen Ort aus.';

  @override
  String mapErrorGeolocation(String error) {
    return 'Geolokalisierungsfehler: $error';
  }

  @override
  String mapErrorSearching(String error) {
    return 'Fehler bei der Suche: $error';
  }

  @override
  String mapErrorGettingData(String error) {
    return 'Fehler beim Abrufen der Daten: $error';
  }

  @override
  String get notifAirQualityAlert => 'Luftqualitätswarnung';

  @override
  String notifWeatherAt(int temp, String location) {
    return '$temp°C in $location';
  }

  @override
  String notifWeatherForecast(String condition, int maxTemp, int minTemp) {
    return '$condition. Max: $maxTemp° Min: $minTemp°';
  }

  @override
  String notifAirQualityBody(String location, String level, int aqi) {
    return '$location: $level (AQI: $aqi)';
  }

  @override
  String get mapHealthAdviceAI => 'KI-Gesundheitstipp';

  @override
  String get mapMainPollutants => 'Hauptschadstoffe';

  @override
  String get mapEnvironmentalConditions => 'Umgebungsbedingungen';

  @override
  String get pollutantStatusLow => 'Niedrig';

  @override
  String get pollutantStatusModerate => 'Mäßig';

  @override
  String get pollutantStatusHigh => 'Hoch';

  @override
  String get metricHumidity => 'Feuchtigkeit';

  @override
  String get metricWind => 'Wind';

  @override
  String get metricPressure => 'Luftdruck';

  @override
  String get metricFeelsLike => 'Gefühlt wie';

  @override
  String get aqiDescGood => 'Saubere Luft. Perfekt für Outdoor-Aktivitäten.';

  @override
  String get aqiDescFair =>
      'Akzeptable Qualität. Sehr empfindliche Personen sollten vorsichtig sein.';

  @override
  String get aqiDescModerate =>
      'Empfindliche Gruppen können Auswirkungen spüren. Exposition einschränken.';

  @override
  String get aqiDescPoor =>
      'Auswirkungen auf die Gesundheit aller. Aktivitäten im Freien reduzieren.';

  @override
  String get aqiDescVeryPoor =>
      'Gesundheitswarnung. Aufenthalt im Freien nach Möglichkeit vermeiden.';

  @override
  String get aqiDescDangerous =>
      'Gesundheitsnotstand. Bleiben Sie in Innenräumen.';

  @override
  String get forecastToday => 'Heute';

  @override
  String get forecastTomorrow => 'Morgen';

  @override
  String get emptyHistoryTitle => 'Noch kein Verlauf';

  @override
  String get emptyHistorySubtitle =>
      'Suchen Sie Orte, um Ihren Verlauf aufzubauen.';

  @override
  String get emptySavedLocationsTitle => 'Keine gespeicherten Orte';

  @override
  String get emptySavedLocationsSubtitle =>
      'Speichern Sie Ihre Lieblingsorte, um die Luftqualität zu überwachen.';

  @override
  String get emptyAlertsTitle => 'Keine aktiven Warnungen';

  @override
  String get emptyAlertsSubtitle =>
      'Richten Sie Warnungen ein, um über die Luftqualität informiert zu werden.';

  @override
  String get emptySearchTitle => 'Keine Ergebnisse gefunden';

  @override
  String get emptySearchSubtitle =>
      'Versuchen Sie, nach einer anderen Stadt zu suchen.';

  @override
  String get errorNetworkTitle => 'Keine Internetverbindung';

  @override
  String get errorNetworkSubtitle =>
      'Überprüfen Sie Ihre Verbindung und versuchen Sie es erneut.';

  @override
  String get errorLocationTitle => 'Standortzugriff verweigert';

  @override
  String get errorLocationSubtitle =>
      'Erlauben Sie den Standortzugriff, um die lokale Luftqualität zu sehen.';

  @override
  String get errorGenericTitle => 'Etwas ist schiefgelaufen';

  @override
  String get errorGenericSubtitle =>
      'Ein unerwarteter Fehler ist aufgetreten. Bitte versuchen Sie es erneut.';

  @override
  String get openSettings => 'Einstellungen öffnen';

  @override
  String get onboardingMapTitle => 'Panel nach oben ziehen';

  @override
  String get onboardingMapSubtitle =>
      'Nach oben wischen, um Luftqualität, Wetter und Vorhersage anzuzeigen.';

  @override
  String get onboardingAlertsTitle => 'Warnungsorte festlegen';

  @override
  String get onboardingAlertsSubtitle =>
      'Tippen Sie auf eine Ortskarte, um die Überwachung zu konfigurieren.';

  @override
  String get legalPrivacyContent =>
      '**Aeris Datenschutzerklärung**\\n\\n**Zuletzt aktualisiert:** 21. November 2024\\n\\n**1. Einführung**\\nAeris ist eine kostenlose Anwendung zur Information über Luftqualität und Wetter. Wir schalten keine Werbung und verkaufen Ihre Daten nicht.\\n\\n**2. Datenerhebung**\\nAeris erhebt, speichert oder teilt KEINE personenbezogenen Daten. Keine Registrierung oder Anmeldung erforderlich.\\n\\n**3. Standortdaten**\\nUm Ihnen genaue Wetter- und Luftqualitätsdaten bereitzustellen, benötigt die App Zugriff auf Ihren Standort.\\n- Koordinaten werden anonym an unsere Datenanbieter (OpenWeather) gesendet.\\n- Wenn Sie einen Ort speichern, werden die Koordinaten verschlüsselt auf unserem sicheren Server gespeichert.\\n- Wir verfolgen Ihren Bewegungsverlauf außerhalb der von Ihnen aktiv getätigten Abfragen nicht.\\n\\n**4. Dienste von Drittanbietern**\\nWir verwenden vertrauenswürdige Dienste zum Abrufen von Daten:\\n- **OpenWeather:** Für Wetter- und Luftqualitätsdaten.\\n- **Google Gemini:** Zur Generierung von Gesundheits- und Wetterempfehlungen basierend auf aktuellen Daten.\\n\\n**5. Kontakt**\\nBei Fragen zu dieser Richtlinie kontaktieren Sie uns bitte über den App Store.';

  @override
  String get legalTermsContent =>
      '**Aeris Nutzungsbedingungen**\\n\\n**1. Akzeptanz**\\nDurch die Nutzung von Aeris akzeptieren Sie diese Bedingungen. Die App ist kostenlos und wird im Ist-Zustand bereitgestellt.\\n\\n**2. Nutzung der Anwendung**\\nEs steht Ihnen frei, die App für persönliche und informative Zwecke zu nutzen. Reverse Engineering oder der Versuch, unseren Diensten zu schaden, ist nicht gestattet.\\n\\n**3. Haftungsausschluss**\\nGesundheits- und Wetterinformationen werden durch Künstliche Intelligenz und externe Anbieter generiert.\\n- **Keine medizinische Beratung:** Empfehlungen dienen nur zur Information. Konsultieren Sie immer einen Arzt.\\n- **Genauigkeit:** Wir garantieren nicht, dass die Daten jederzeit zu 100 % korrekt sind.\\n\\n**4. Änderungen**\\nWir können diese Bedingungen jederzeit aktualisieren. Die fortgesetzte Nutzung impliziert die Annahme der Änderungen.';

  @override
  String get aqiAdviceGood =>
      '✅ Die Luftqualität ist hervorragend. Ideal für Aktivitäten im Freien, Spaziergänge oder Sport. Genießen Sie den Tag ohne Einschränkungen.';

  @override
  String get aqiAdviceFair =>
      '🟡 Die Luftqualität ist akzeptabel. Menschen mit Asthma oder chronischen Atemwegserkrankungen sollten intensive körperliche Aktivitäten im Freien mäßigen. Andere können sich normal verhalten.';

  @override
  String get aqiAdviceModerate =>
      '🟠 Moderate Qualität. Empfindliche Gruppen (Kinder, ältere Erwachsene, Schwangere und Menschen mit Herz- oder Atemwegsproblemen) sollten längere körperliche Aktivitäten im Freien einschränken.';

  @override
  String get aqiAdvicePoor =>
      '🔴 Schlechte Luftqualität. Jeder kann beginnen, gesundheitliche Auswirkungen zu spüren. Reduzieren Sie die Zeit im Freien, insbesondere bei anstrengenden körperlichen Aktivitäten. Tragen Sie eine Maske, wenn Sie ausgehen.';

  @override
  String get aqiAdviceVeryPoor =>
      '🟣 Sehr schlechte Qualität — Gesundheitswarnung. Vermeiden Sie den Aufenthalt im Freien, es sei denn, dies ist unbedingt erforderlich. Schließen Sie die Fenster, verwenden Sie einen Luftreiniger in Innenräumen und tragen Sie eine FFP2-Maske, wenn Sie ausgehen.';

  @override
  String get aqiAdviceDangerous =>
      '⚫ Sicherheits- und Gesundheitsnotstand. Die gesamte Bevölkerung ist gefährdet. Bleiben Sie in Innenräumen und halten Sie Fenster und Türen geschlossen. Wenden Sie sich an den Rettungsdienst, wenn Sie Atembeschwerden, Brustschmerzen oder Schwindel verspüren.';

  @override
  String get weatherAdviceVeryCold =>
      '🧥 Sehr niedrige Temperatur. Ziehen Sie sich warm in mehreren Schichten an und achten Sie besonders darauf, Hände, Füße und Kopf zu schützen. Vermeiden Sie längeren Aufenthalt in der Kälte und trinken Sie warme Flüssigkeiten.';

  @override
  String get weatherAdviceCold =>
      '🌬️ Es ist kalt. Tragen Sie warme Kleidung und nehmen Sie eine zusätzliche Jacke mit. Wenn Sie anfällig für Erkältungen sind oder Atemwegserkrankungen haben, bedecken Sie Nase und Mund beim Ausgehen.';

  @override
  String get weatherAdviceVeryHot =>
      '🥵 Extreme Hitze. Trinken Sie ständig Wasser und vermeiden Sie direkte Sonneneinstrahlung zwischen 11 und 17 Uhr. Verwenden Sie Sonnenschutzmittel mit LSF 50+, tragen Sie leichte Kleidung und halten Sie sich an kühlen Orten auf. Achten Sie auf Symptome eines Hitzschlags (Schwindel, Verwirrung, trockene Haut).';

  @override
  String get weatherAdviceHot =>
      '☀️ Heißer Tag. Trinken Sie regelmäßig Wasser, tragen Sie leichte Kleidung und tragen Sie Sonnenschutzmittel auf. Vermeiden Sie intensive körperliche Aktivitäten in den heißesten Stunden.';

  @override
  String get weatherAdviceStorm =>
      '⛈️ Gewitter vorhergesagt. Vermeiden Sie offene Flächen, Bäume und Metallstrukturen. Bleiben Sie in Innenräumen und trennen Sie unnötige elektrische Geräte vom Stromnetz.';

  @override
  String get weatherAdviceRain =>
      '🌧️ Regen erwartet. Nehmen Sie einen Regenschirm oder eine Regenjacke mit. Fahren Sie vorsichtig wegen nasser Fahrbahnen und reduzieren Sie die Geschwindigkeit in hochwassergefährdeten Gebieten.';

  @override
  String get weatherAdviceSnow =>
      '❄️ Schneefall. Tragen Sie rutschfeste Schuhe, fahren Sie mit Schneeketten oder Winterreifen. Seien Sie vorsichtig bei Eis auf Gehwegen und Straßen.';

  @override
  String get weatherAdviceFog =>
      '🌫️ Nebel oder Dunst. Eingeschränkte Sicht auf den Straßen — verwenden Sie beim Fahren Nebelscheinwerfer und reduzieren Sie die Geschwindigkeit. Menschen mit Asthma können Atemwegsreizungen bemerken.';

  @override
  String get weatherAdviceWind =>
      '💨 Starke Winde. Sichern Sie Gegenstände auf Balkonen und in Gärten. Seien Sie vorsichtig beim Fahren von hohen Fahrzeugen und vermeiden Sie Outdoor-Aktivitäten, die Gleichgewicht erfordern.';

  @override
  String get weatherAdviceCloud =>
      '☁️ Bewölkter Himmel. Angenehme Temperatur für Outdoor-Aktivitäten. Obwohl es keine direkte Sonneneinstrahlung gibt, kann der UV-Index moderat sein — denken Sie an Sonnenschutz.';

  @override
  String get weatherAdviceDefault =>
      '🌤️ Günstige Bedingungen. Schöner Tag für Outdoor-Aktivitäten. Tragen Sie Sonnenschutzmittel auf, wenn der UV-Index hoch ist, und trinken Sie ausreichend Wasser.';
}
