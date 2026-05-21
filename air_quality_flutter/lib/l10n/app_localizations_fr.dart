// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Aeris';

  @override
  String get welcomeTitle => 'Bienvenue sur Aeris';

  @override
  String get welcomeSubtitle => 'Votre compagnon pour un air sain';

  @override
  String get welcomeFeature1Title => 'Suivi en Temps Réel';

  @override
  String get welcomeFeature1Desc =>
      'Consultez instantanément la qualité de l\'air et la météo.';

  @override
  String get welcomeFeature2Title => 'Alertes Intelligentes';

  @override
  String get welcomeFeature2Desc =>
      'Soyez notifié lorsque la qualité de l\'air se dégrade.';

  @override
  String get welcomeFeature3Title => 'Historique Détaillé';

  @override
  String get welcomeFeature3Desc =>
      'Analysez les tendances historiques de pollution.';

  @override
  String get welcomeButton => 'Démarrer';

  @override
  String get navMap => 'Carte';

  @override
  String get navHistory => 'Historique';

  @override
  String get navAlerts => 'Alertes';

  @override
  String get navSettings => 'Paramètres';

  @override
  String get mapSearchPlaceholder => 'Rechercher une ville...';

  @override
  String get mapCurrentWeather => 'Météo Actuelle';

  @override
  String get mapWeatherAdvice => 'Conseil Météo';

  @override
  String get mapHealthAdvice => 'Recommandation (IA)';

  @override
  String get mapAirQuality => 'Qualité de l\'Air';

  @override
  String get mapPollutants => 'Polluants';

  @override
  String get mapHistoryChart => 'Historique (Dernières 24h)';

  @override
  String get mapViewFullHistory => 'Voir tout l\'historique';

  @override
  String get historyTitle => 'Historique de la Qualité de l\'Air';

  @override
  String get historyLast7Days => 'Derniers 7 jours';

  @override
  String get historyChartTitle => 'Évolution de l\'IQA';

  @override
  String get historyNoData => 'Aucune donnée historique disponible.';

  @override
  String get alertsTitle => 'Réglages des Alertes';

  @override
  String get alertsSubtitle => 'Gérez vos notifications';

  @override
  String get alertsSectionPollutants => 'Types de Polluants';

  @override
  String get alertsSwitchAirQuality => 'Qualité de l\'Air (IQA)';

  @override
  String get alertsSwitchAirQualitySubtitle =>
      'Notifier si l\'air est mauvais ou dangereux';

  @override
  String get alertsSwitchWeather => 'Statut Météo';

  @override
  String get alertsSwitchWeatherSubtitle =>
      'Notifications quotidiennes de type Google';

  @override
  String get alertsSectionLocations => 'Lieux Enregistrés';

  @override
  String get alertsAddLocation => 'Ajouter un Lieu';

  @override
  String get alertsCurrentLocation => 'Position Actuelle';

  @override
  String get alertsSavedLocation => 'Lieu Enregistré';

  @override
  String get alertsSectionPreferences => 'Préférences de Notification';

  @override
  String get alertsAiRecommendations => 'Recommandations IA';

  @override
  String get alertsAiRecommendationsSubtitle =>
      'Recevez des conseils personnalisés combinant météo et qualité de l\'air.';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsSectionGeneral => 'Général';

  @override
  String get settingsThemeDark => 'Mode Sombre';

  @override
  String get settingsThemeDarkSubtitle =>
      'Modifier l\'apparence de l\'application';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsLanguageSubtitle => 'Sélectionnez votre langue préférée';

  @override
  String get langSystem => 'Par Défaut du Système';

  @override
  String get settingsSectionSystem => 'Système';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsNotificationsSubtitle => 'Gérer les autorisations système';

  @override
  String get settingsLocation => 'Localisation';

  @override
  String get settingsLocationSubtitle =>
      'Gérer les autorisations de localisation';

  @override
  String get settingsSectionInfo => 'Informations';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsPrivacyPolicy => 'Politique de Confidentialité';

  @override
  String get settingsTermsOfService => 'Conditions d\'Utilisation';

  @override
  String get settingsFooter => 'Aeris v1.0.0';

  @override
  String get legalPrivacyTitle => 'Politique de Confidentialité';

  @override
  String get legalTermsTitle => 'Conditions d\'Utilisation';

  @override
  String get legalFooter => 'Aeris - Application Gratuite';

  @override
  String get aqiGood => 'Bon';

  @override
  String get aqiFair => 'Acceptable';

  @override
  String get aqiModerate => 'Modéré';

  @override
  String get aqiPoor => 'Mauvais';

  @override
  String get aqiVeryPoor => 'Très Mauvais';

  @override
  String get aqiDangerous => 'Dangereux';

  @override
  String get errorLoading => 'Erreur de chargement';

  @override
  String get retry => 'Réessayer';

  @override
  String get cancel => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String get next => 'Suivant';

  @override
  String get historyTabDay => 'Jour';

  @override
  String get historyTabWeek => 'Semaine';

  @override
  String get historyTabMonth => 'Mois';

  @override
  String get historySectionSaved => 'Lieux Enregistrés';

  @override
  String get historyNoSavedLocations => 'Aucun lieu enregistré';

  @override
  String get historySectionVisits => 'Visites Récentes';

  @override
  String get historyNoRecentHistory => 'Aucun historique récent';

  @override
  String get historyDeleteTitle => 'Supprimer le Lieu';

  @override
  String historyDeleteConfirmation(String name) {
    return 'Voulez-vous vraiment supprimer $name ?';
  }

  @override
  String historyDeleted(String name) {
    return 'Lieu $name supprimé';
  }

  @override
  String get alertsNewLocation => 'Nouveau Lieu';

  @override
  String get alertsNewLocationHint => 'Nom de la ville';

  @override
  String alertsSelectLocation(String name) {
    return 'Sélectionner le Lieu pour $name';
  }

  @override
  String get alertsVerifying => 'Vérification...';

  @override
  String alertsVerified(int count) {
    return 'Vérifié ($count)';
  }

  @override
  String get alertsCheckNow => 'Vérifier Maintenant';

  @override
  String get alertsCurrentLocationSubtitle =>
      'Utiliser la position de l\'appareil';

  @override
  String get alertsPollutantWeather => 'Météo';

  @override
  String get alertsPollutantWeatherSubtitle => 'État météo';

  @override
  String get alertsPollutantPM25 => 'PM2.5';

  @override
  String get alertsPollutantPM25Subtitle => 'Particules fines';

  @override
  String get alertsPollutantPM10 => 'PM10';

  @override
  String get alertsPollutantPM10Subtitle => 'Particules respirables';

  @override
  String get alertsPollutantO3 => 'Ozone (O3)';

  @override
  String get alertsPollutantO3Subtitle => 'Ozone troposphérique';

  @override
  String get alertsLocationHome => 'Maison';

  @override
  String get alertsLocationWork => 'Travail';

  @override
  String get alertsTapToConfigure => 'Appuyer pour configurer';

  @override
  String alertsLocationOf(String name) {
    return 'Position de $name';
  }

  @override
  String get mapSearchResults => 'Résultats de Recherche';

  @override
  String get mapLocationOnMap => 'Position sur la carte';

  @override
  String get mapSelectLocation => 'Sélectionnez un lieu';

  @override
  String get mapSaveLocationTooltip => 'Enregistrer ce lieu';

  @override
  String get mapSaveLocationHint => 'Ex : Maison, Bureau...';

  @override
  String get mapCancel => 'Annuler';

  @override
  String get mapSave => 'Enregistrer';

  @override
  String mapLocationSaved(String name) {
    return '\"$name\" enregistré.';
  }

  @override
  String get mapWeeklyForecast => 'Prévisions Hebdomadaires';

  @override
  String get mapNoForecastAvailable => 'Aucune prévision disponible.';

  @override
  String get mapSelectLocationPrompt => 'Sélectionnez un lieu.';

  @override
  String mapErrorGeolocation(String error) {
    return 'Erreur de géolocalisation : $error';
  }

  @override
  String mapErrorSearching(String error) {
    return 'Erreur lors de la recherche : $error';
  }

  @override
  String mapErrorGettingData(String error) {
    return 'Erreur lors de la récupération des données : $error';
  }

  @override
  String get notifAirQualityAlert => 'Alerte de Qualité de l\'Air';

  @override
  String notifWeatherAt(int temp, String location) {
    return '$temp°C à $location';
  }

  @override
  String notifWeatherForecast(String condition, int maxTemp, int minTemp) {
    return '$condition. Max : $maxTemp° Min : $minTemp°';
  }

  @override
  String notifAirQualityBody(String location, String level, int aqi) {
    return '$location : $level (IQA : $aqi)';
  }

  @override
  String get mapHealthAdviceAI => 'Conseil de Santé (IA)';

  @override
  String get mapMainPollutants => 'Polluants principaux';

  @override
  String get mapEnvironmentalConditions => 'Conditions environnementales';

  @override
  String get pollutantStatusLow => 'Faible';

  @override
  String get pollutantStatusModerate => 'Modéré';

  @override
  String get pollutantStatusHigh => 'Élevé';

  @override
  String get metricHumidity => 'Humidité';

  @override
  String get metricWind => 'Vent';

  @override
  String get metricPressure => 'Pression';

  @override
  String get metricFeelsLike => 'Ressenti';

  @override
  String get aqiDescGood =>
      'Air propre. Idéal pour les activités en plein air.';

  @override
  String get aqiDescFair =>
      'Qualité acceptable. Personnes sensibles, soyez prudentes.';

  @override
  String get aqiDescModerate =>
      'Les groupes sensibles peuvent ressentir des effets. Limiter l\'exposition.';

  @override
  String get aqiDescPoor =>
      'Effets sur la santé pour tous. Réduire les activités extérieures.';

  @override
  String get aqiDescVeryPoor =>
      'Alerte sanitaire. Éviter de sortir sauf nécessité.';

  @override
  String get aqiDescDangerous => 'Urgence sanitaire. Rester à l\'intérieur.';

  @override
  String get forecastToday => 'Aujourd\'hui';

  @override
  String get forecastTomorrow => 'Demain';

  @override
  String get emptyHistoryTitle => 'Pas encore d\'historique';

  @override
  String get emptyHistorySubtitle =>
      'Explorez des lieux pour commencer à créer votre historique.';

  @override
  String get emptySavedLocationsTitle => 'Aucun lieu enregistré';

  @override
  String get emptySavedLocationsSubtitle =>
      'Enregistrez vos endroits favoris pour suivre la qualité de l\'air.';

  @override
  String get emptyAlertsTitle => 'Aucune alerte active';

  @override
  String get emptyAlertsSubtitle =>
      'Configurez des alertes pour être notifié de la qualité de l\'air.';

  @override
  String get emptySearchTitle => 'Aucun résultat trouvé';

  @override
  String get emptySearchSubtitle => 'Essayez de rechercher une autre ville.';

  @override
  String get errorNetworkTitle => 'Pas de connexion internet';

  @override
  String get errorNetworkSubtitle =>
      'Veuillez vérifier votre connexion et réessayer.';

  @override
  String get errorLocationTitle => 'Accès à la position refusé';

  @override
  String get errorLocationSubtitle =>
      'Autorisez l\'accès à la position pour voir la qualité de l\'air locale.';

  @override
  String get errorGenericTitle => 'Une erreur est survenue';

  @override
  String get errorGenericSubtitle =>
      'Une erreur inattendue s\'est produite. Veuillez réessayer.';

  @override
  String get openSettings => 'Ouvrir les Paramètres';

  @override
  String get onboardingMapTitle => 'Faites glisser le panneau vers le haut';

  @override
  String get onboardingMapSubtitle =>
      'Faites glisser pour voir la qualité de l\'air, la météo et les prévisions.';

  @override
  String get onboardingAlertsTitle => 'Définir les alertes météo';

  @override
  String get onboardingAlertsSubtitle =>
      'Appuyez sur une carte pour configurer la position de surveillance.';

  @override
  String get legalPrivacyContent =>
      '**Politique de Confidentialité d\'Aeris**\\n\\n**Dernière mise à jour :** 21 novembre 2024\\n\\n**1. Introduction**\\nAeris est une application gratuite conçue pour informer sur la qualité de l\'air et la météo. Nous n\'affichons pas de publicité et ne vendons pas vos données.\\n\\n**2. Collecte de Données**\\nAeris ne collecte, ne stocke ni ne partage AUCUNE information d\'identification personnelle. Aucune inscription ou connexion n\'est requise.\\n\\n**3. Données de Localisation**\\nPour vous fournir des données précises sur la météo et la qualité de l\'air, l\'application a besoin d\'accéder à votre localisation.\\n- Les coordonnées sont transmises de manière anonyme à nos fournisseurs de données (OpenWeather).\\n- Si vous enregistrez un lieu, ses coordonnées sont stockées de façon chiffrée sur notre serveur sécurisé.\\n- Nous ne suivons pas votre historique de déplacement en dehors des requêtes que vous effectuez activement.\\n\\n**4. Services Tiers**\\nNous utilisons des services de confiance pour récupérer les données :\\n- **OpenWeather :** Pour la météo et la qualité de l\'air.\\n- **Google Gemini :** Pour générer des conseils météo et de santé basés sur les données actu.\\n\\n**5. Contact**\\nPour toute question relative à cette politique, contactez-nous via la boutique d\'applications.';

  @override
  String get legalTermsContent =>
      '**Conditions d\'Utilisation d\'Aeris**\\n\\n**1. Acceptation**\\nEn utilisant Aeris, vous acceptez les présentes conditions. L\'application est gratuite et fournie en l\'état.\\n\\n**2. Utilisation de l\'Application**\\nVous êtes libre d\'utiliser l\'application à des fins personnelles et informatives. Toute ingénierie inverse ou tentative de nuire à nos services est interdite.\\n\\n**3. Clause de Non-responsabilité**\\nLes informations météo et de santé sont générées par intelligence artificielle et des fournisseurs externes.\\n- **Pas de conseil médical :** Les recommandations sont purement informatives. Consultez toujours un professionnel de la santé.\\n- **Précision :** Nous ne garantissons pas l\'exactitude absolue des données à tout moment.\\n\\n**4. Modifications**\\nNous pouvons modifier ces conditions à tout moment. L\'utilisation continue de l\'application vaut acceptation des modifications.';

  @override
  String get aqiAdviceGood =>
      '✅ La qualité de l\'air est excellente. Idéal pour faire de l\'exercice en plein air, se promener ou faire du sport. Profitez de la journée sans restriction.';

  @override
  String get aqiAdviceFair =>
      '🟡 La qualité de l\'air est acceptable. Les personnes souffrant d\'asthme ou de maladies respiratoires chroniques doivent modérer leur activité physique intense en plein air. Les autres peuvent agir normalement.';

  @override
  String get aqiAdviceModerate =>
      '🟠 Qualité modérée. Les groupes sensibles (enfants, personnes âgées, femmes enceintes et personnes souffrant de problèmes cardiaques ou respiratoires) doivent limiter l\'activité physique prolongée en plein air.';

  @override
  String get aqiAdvicePoor =>
      '🔴 Mauvaise qualité de l\'air. Tout le monde peut commencer à en ressentir les effets. Réduisez le temps passé à l\'extérieur, en particulier pour les activités physiques intenses. Portez un masque si vous sortez.';

  @override
  String get aqiAdviceVeryPoor =>
      '🟣 Très mauvaise qualité — alerte sanitaire. Évitez de sortir à l\'extérieur sauf en cas de stricte nécessité. Fermez les fenêtres, utilisez un purificateur d\'air intérieur et portez un masque FFP2 si vous devez sortir.';

  @override
  String get aqiAdviceDangerous =>
      '⚫ Urgence de santé publique. Toute la population est à risque. Restez à l\'intérieur, fenêtres et portes fermées. Contactez les services d\'urgence si vous ressentez des difficultés respiratoires, des douleurs thoraciques ou des vertiges.';

  @override
  String get weatherAdviceVeryCold =>
      '🧥 Température très basse. Habillez-vous chaudement avec plusieurs couches de vêtements, en veillant particulièrement à protéger vos mains, vos pieds et votre tête. Évitez toute exposition prolongée au froid et buvez des boissons chaudes.';

  @override
  String get weatherAdviceCold =>
      '🌬️ Il fait froid. Portez des vêtements chauds et apportez une veste supplémentaire. Si vous êtes sujet aux rhumes ou si vous souffrez de problèmes respiratoires, couvrez-vous le nez et la bouche en sortant.';

  @override
  String get weatherAdviceVeryHot =>
      '🥵 Chaleur extrême. Hydratez-vous constamment, évitez le soleil direct entre 11h et 17h. Utilisez un écran solaire FPS 50+, portez des vêtements légers et restez dans des endroits frais. Soyez attentif aux symptômes du coup de chaleur (vertiges, confusion, peau sèche).';

  @override
  String get weatherAdviceHot =>
      '☀️ Journée chaude. Restez hydraté en buvant de l\'eau régulièrement, portez des vêtements légers et appliquez de l\'écran solaire. Évitez les activités physiques intenses aux heures les plus chaudes.';

  @override
  String get weatherAdviceStorm =>
      '⛈️ Orage prévu. Évitez les espaces ouverts, les arbres et les structures métalliques. Restez à l\'intérieur et débranchez les appareils électriques inutiles.';

  @override
  String get weatherAdviceRain =>
      '🌧️ Pluie attendue. Apportez un parapluie ou un imperméable. Conduisez avec prudence en raison de la chaussée mouillée et réduisez votre vitesse dans les zones inondables.';

  @override
  String get weatherAdviceSnow =>
      '❄️ Chutes de neige. Portez des chaussures antidérapantes, conduisez avec des chaînes ou des pneus neige. Faites attention au verglas sur les trottoirs et les routes.';

  @override
  String get weatherAdviceFog =>
      '🌫️ Brouillard ou brume. Visibilité réduite sur les routes — utilisez les feux de brouillard en conduisant et réduisez votre vitesse. Les asthmatiques peuvent ressentir une irritation respiratoire.';

  @override
  String get weatherAdviceWind =>
      '💨 Vents forts. Sécurisez les objets sur les balcons et les jardins. Soyez prudent lorsque vous conduisez des véhicules surélevés et évitez les activités de plein air nécessitant de l\'équilibre.';

  @override
  String get weatherAdviceCloud =>
      '☁️ Ciel nuageux. Température agréable pour les activités de plein air. Même s\'il n\'y a pas de soleil direct, l\'indice UV peut rester modéré — pensez à l\'écran solaire.';

  @override
  String get weatherAdviceDefault =>
      '🌤️ Conditions favorables. Bonne journée pour les activités de plein air. Appliquez de l\'écran solaire si l\'indice UV est élevé et restez hydraté.';
}
