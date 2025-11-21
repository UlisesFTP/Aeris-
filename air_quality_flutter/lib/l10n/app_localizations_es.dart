// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Aeris';

  @override
  String get welcomeTitle => 'Bienvenido a Aeris';

  @override
  String get welcomeSubtitle => 'Tu compañero de aire limpio';

  @override
  String get welcomeFeature1Title => 'Monitoreo en Tiempo Real';

  @override
  String get welcomeFeature1Desc =>
      'Consulta la calidad del aire y el clima al instante.';

  @override
  String get welcomeFeature2Title => 'Alertas Inteligentes';

  @override
  String get welcomeFeature2Desc =>
      'Recibe notificaciones cuando la calidad del aire empeore.';

  @override
  String get welcomeFeature3Title => 'Historial Detallado';

  @override
  String get welcomeFeature3Desc =>
      'Analiza tendencias históricas de contaminación.';

  @override
  String get welcomeButton => 'Comenzar';

  @override
  String get navMap => 'Mapa';

  @override
  String get navHistory => 'Historial';

  @override
  String get navAlerts => 'Alertas';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get mapSearchPlaceholder => 'Buscar ciudad...';

  @override
  String get mapCurrentWeather => 'Clima Actual';

  @override
  String get mapWeatherAdvice => 'Consejo del Clima';

  @override
  String get mapHealthAdvice => 'Recomendación (IA)';

  @override
  String get mapAirQuality => 'Calidad del Aire';

  @override
  String get mapPollutants => 'Contaminantes';

  @override
  String get mapHistoryChart => 'Historial (Últimas 24h)';

  @override
  String get mapViewFullHistory => 'Ver historial completo';

  @override
  String get historyTitle => 'Historial de Calidad del Aire';

  @override
  String get historyLast7Days => 'Últimos 7 días';

  @override
  String get historyChartTitle => 'Tendencia de AQI';

  @override
  String get historyNoData => 'No hay datos históricos disponibles.';

  @override
  String get alertsTitle => 'Configuración de Alertas';

  @override
  String get alertsSubtitle => 'Gestiona tus notificaciones';

  @override
  String get alertsSectionPollutants => 'Tipos de Contaminantes';

  @override
  String get alertsSwitchAirQuality => 'Calidad del Aire (AQI)';

  @override
  String get alertsSwitchAirQualitySubtitle =>
      'Notificar cuando el aire sea malo o peligroso';

  @override
  String get alertsSwitchWeather => 'Estado del Clima';

  @override
  String get alertsSwitchWeatherSubtitle =>
      'Notificaciones diarias como en Google';

  @override
  String get alertsSectionLocations => 'Ubicaciones Guardadas';

  @override
  String get alertsAddLocation => 'Agregar Ubicación';

  @override
  String get alertsCurrentLocation => 'Ubicación Actual';

  @override
  String get alertsSavedLocation => 'Ubicación Guardada';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsSectionGeneral => 'General';

  @override
  String get settingsThemeDark => 'Tema Oscuro';

  @override
  String get settingsThemeDarkSubtitle => 'Cambiar apariencia de la aplicación';

  @override
  String get settingsSectionSystem => 'Sistema';

  @override
  String get settingsNotifications => 'Notificaciones';

  @override
  String get settingsNotificationsSubtitle =>
      'Gestionar permisos en el sistema';

  @override
  String get settingsLocation => 'Ubicación';

  @override
  String get settingsLocationSubtitle => 'Gestionar permisos de ubicación';

  @override
  String get settingsSectionInfo => 'Información';

  @override
  String get settingsVersion => 'Versión';

  @override
  String get settingsPrivacyPolicy => 'Política de Privacidad';

  @override
  String get settingsTermsOfService => 'Términos de Servicio';

  @override
  String get settingsFooter => 'Aeris v1.0.0';

  @override
  String get legalPrivacyTitle => 'Política de Privacidad';

  @override
  String get legalTermsTitle => 'Términos de Servicio';

  @override
  String get legalFooter => 'Aeris - App Gratuita';

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
  String get errorLoading => 'Error cargando datos';

  @override
  String get retry => 'Reintentar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get next => 'Siguiente';

  @override
  String get historyTabDay => 'Día';

  @override
  String get historyTabWeek => 'Semana';

  @override
  String get historyTabMonth => 'Mes';

  @override
  String get historySectionSaved => 'Ubicaciones Guardadas';

  @override
  String get historyNoSavedLocations => 'No hay ubicaciones guardadas';

  @override
  String get historySectionVisits => 'Visitas Recientes';

  @override
  String get historyNoRecentHistory => 'No hay historial reciente';

  @override
  String get historyDeleteTitle => 'Eliminar Ubicación';

  @override
  String historyDeleteConfirmation(String name) {
    return '¿Estás seguro de que quieres eliminar $name?';
  }

  @override
  String historyDeleted(String name) {
    return 'Ubicación $name eliminada';
  }

  @override
  String get alertsNewLocation => 'Nueva Ubicación';

  @override
  String get alertsNewLocationHint => 'Nombre de la ciudad';

  @override
  String alertsSelectLocation(String name) {
    return 'Seleccionar Ubicación para $name';
  }

  @override
  String get alertsVerifying => 'Verificando...';

  @override
  String alertsVerified(int count) {
    return 'Verificado ($count)';
  }

  @override
  String get alertsCheckNow => 'Comprobar Ahora';

  @override
  String get alertsCurrentLocationSubtitle => 'Usar ubicación del dispositivo';

  @override
  String get alertsPollutantWeather => 'Clima';

  @override
  String get alertsPollutantWeatherSubtitle => 'Estado del tiempo';

  @override
  String get alertsPollutantPM25 => 'PM2.5';

  @override
  String get alertsPollutantPM25Subtitle => 'Partículas finas';

  @override
  String get alertsPollutantPM10 => 'PM10';

  @override
  String get alertsPollutantPM10Subtitle => 'Partículas respirables';

  @override
  String get alertsPollutantO3 => 'Ozono (O3)';

  @override
  String get alertsPollutantO3Subtitle => 'Ozono troposférico';

  @override
  String get alertsLocationHome => 'Casa';

  @override
  String get alertsLocationWork => 'Trabajo';

  @override
  String get alertsTapToConfigure => 'Toca para configurar';

  @override
  String alertsLocationOf(String name) {
    return 'Ubicación de $name';
  }

  @override
  String get legalPrivacyContent =>
      '**Política de Privacidad de Aeris**\\n\\n**Última actualización:** 21 de Noviembre de 2024\\n\\n**1. Introducción**\\nAeris es una aplicación gratuita desarrollada para informar sobre la calidad del aire y el clima. No mostramos anuncios ni vendemos tus datos.\\n\\n**2. Recopilación de Datos**\\nAeris NO recopila, almacena ni comparte información personal identificable. No requerimos registro ni inicio de sesión.\\n\\n**3. Datos de Ubicación**\\nPara proporcionarte datos precisos del clima y calidad del aire, la aplicación necesita acceso a tu ubicación.\\n- Las coordenadas se envían a nuestros proveedores de datos (OpenWeather) de forma anónima.\\n- Si guardas una ubicación, las coordenadas se almacenan cifradas en nuestro servidor seguro.\\n- No rastreamos tu historial de movimientos fuera de las consultas que realizas activamente.\\n\\n**4. Servicios de Terceros**\\nUtilizamos servicios de confianza para obtener datos:\\n- **OpenWeather:** Para datos meteorológicos y de calidad del aire.\\n- **Google Gemini:** Para generar recomendaciones de salud y clima basadas en los datos actuales.\\n\\n**5. Contacto**\\nSi tienes preguntas sobre esta política, contáctanos a través de la tienda de aplicaciones.';

  @override
  String get legalTermsContent =>
      '**Términos de Servicio de Aeris**\\n\\n**1. Aceptación**\\nAl usar Aeris, aceptas estos términos. La aplicación es gratuita y se proporciona tal cual.\\n\\n**2. Uso de la Aplicación**\\nEres libre de usar la aplicación para fines personales e informativos. No está permitido realizar ingeniería inversa ni intentar dañar nuestros servicios.\\n\\n**3. Descargo de Responsabilidad**\\nLa información de salud y clima es generada por Inteligencia Artificial y proveedores externos.\\n- **No es un consejo médico:** Las recomendaciones son solo informativas. Consulta siempre a un profesional de la salud.\\n- **Precisión:** No garantizamos que los datos sean 100% exactos en todo momento.\\n\\n**4. Cambios**\\nPodemos actualizar estos términos en cualquier momento. El uso continuo implica la aceptación de los cambios.';
}
