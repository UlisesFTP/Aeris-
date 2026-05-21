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
  String get alertsSectionPreferences => 'Preferencias de Notificación';

  @override
  String get alertsAiRecommendations => 'Recomendaciones de IA';

  @override
  String get alertsAiRecommendationsSubtitle =>
      'Recibe consejos personalizados combinando clima y calidad del aire.';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsSectionGeneral => 'General';

  @override
  String get settingsThemeDark => 'Tema Oscuro';

  @override
  String get settingsThemeDarkSubtitle => 'Cambiar apariencia de la aplicación';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageSubtitle => 'Selecciona tu idioma preferido';

  @override
  String get langSystem => 'Predeterminado del Sistema';

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
  String get mapSearchResults => 'Resultados de Búsqueda';

  @override
  String get mapLocationOnMap => 'Ubicación en mapa';

  @override
  String get mapSelectLocation => 'Selecciona una ubicación';

  @override
  String get mapSaveLocationTooltip => 'Guardar esta ubicación';

  @override
  String get mapSaveLocationHint => 'Ej: Casa, Oficina...';

  @override
  String get mapCancel => 'Cancelar';

  @override
  String get mapSave => 'Guardar';

  @override
  String mapLocationSaved(String name) {
    return '\"$name\" guardado.';
  }

  @override
  String get mapWeeklyForecast => 'Pronóstico Semanal';

  @override
  String get mapNoForecastAvailable => 'No hay pronóstico disponible.';

  @override
  String get mapSelectLocationPrompt => 'Selecciona una ubicación.';

  @override
  String mapErrorGeolocation(String error) {
    return 'Error de Geolocalización: $error';
  }

  @override
  String mapErrorSearching(String error) {
    return 'Error al buscar: $error';
  }

  @override
  String mapErrorGettingData(String error) {
    return 'Error al obtener datos: $error';
  }

  @override
  String get notifAirQualityAlert => 'Alerta de Calidad del Aire';

  @override
  String notifWeatherAt(int temp, String location) {
    return '$temp°C en $location';
  }

  @override
  String notifWeatherForecast(String condition, int maxTemp, int minTemp) {
    return '$condition. Máx: $maxTemp° Mín: $minTemp°';
  }

  @override
  String notifAirQualityBody(String location, String level, int aqi) {
    return '$location: $level (AQI: $aqi)';
  }

  @override
  String get mapHealthAdviceAI => 'Consejo de Salud (IA)';

  @override
  String get mapMainPollutants => 'Contaminantes principales';

  @override
  String get mapEnvironmentalConditions => 'Condiciones ambientales';

  @override
  String get pollutantStatusLow => 'Bajo';

  @override
  String get pollutantStatusModerate => 'Moderado';

  @override
  String get pollutantStatusHigh => 'Alto';

  @override
  String get metricHumidity => 'Humedad';

  @override
  String get metricWind => 'Viento';

  @override
  String get metricPressure => 'Presión';

  @override
  String get metricFeelsLike => 'Sensación térmica';

  @override
  String get aqiDescGood =>
      'Aire limpio. Perfecto para actividades al aire libre.';

  @override
  String get aqiDescFair =>
      'Calidad aceptable. Personas muy sensibles, precaución.';

  @override
  String get aqiDescModerate =>
      'Grupos sensibles pueden sentir efectos. Limita exposición.';

  @override
  String get aqiDescPoor =>
      'Efectos en la salud para todos. Reduce actividad exterior.';

  @override
  String get aqiDescVeryPoor =>
      'Alerta sanitaria. Evita salir si no es necesario.';

  @override
  String get aqiDescDangerous =>
      'Emergencia de salud. Permanece en interiores.';

  @override
  String get forecastToday => 'Hoy';

  @override
  String get forecastTomorrow => 'Mañana';

  @override
  String get emptyHistoryTitle => 'Aún no hay historial';

  @override
  String get emptyHistorySubtitle =>
      'Comienza a explorar ubicaciones para crear tu historial.';

  @override
  String get emptySavedLocationsTitle => 'No hay ubicaciones guardadas';

  @override
  String get emptySavedLocationsSubtitle =>
      'Guarda tus lugares favoritos para monitorear la calidad del aire.';

  @override
  String get emptyAlertsTitle => 'No hay alertas activas';

  @override
  String get emptyAlertsSubtitle =>
      'Configura alertas para recibir notificaciones sobre la calidad del aire.';

  @override
  String get emptySearchTitle => 'Sin resultados';

  @override
  String get emptySearchSubtitle =>
      'Intenta buscar con un nombre de ciudad diferente.';

  @override
  String get errorNetworkTitle => 'Sin conexión a internet';

  @override
  String get errorNetworkSubtitle => 'Verifica tu conexión e intenta de nuevo.';

  @override
  String get errorLocationTitle => 'Acceso a ubicación denegado';

  @override
  String get errorLocationSubtitle =>
      'Permite el acceso a la ubicación para ver la calidad del aire local.';

  @override
  String get errorGenericTitle => 'Algo salió mal';

  @override
  String get errorGenericSubtitle =>
      'Ocurrió un error inesperado. Por favor intenta de nuevo.';

  @override
  String get openSettings => 'Abrir Ajustes';

  @override
  String get onboardingMapTitle => 'Arrastra el panel hacia arriba';

  @override
  String get onboardingMapSubtitle =>
      'Desliza para ver detalles de calidad del aire, clima y pronóstico.';

  @override
  String get onboardingAlertsTitle => 'Configura ubicaciones de alerta';

  @override
  String get onboardingAlertsSubtitle =>
      'Toca una tarjeta de ubicación para configurar dónde monitorear la calidad del aire.';

  @override
  String get legalPrivacyContent =>
      '**Política de Privacidad de Aeris**\\n\\n**Última actualización:** 21 de Noviembre de 2024\\n\\n**1. Introducción**\\nAeris es una aplicación gratuita desarrollada para informar sobre la calidad del aire y el clima. No mostramos anuncios ni vendemos tus datos.\\n\\n**2. Recopilación de Datos**\\nAeris NO recopila, almacena ni comparte información personal identificable. No requerimos registro ni inicio de sesión.\\n\\n**3. Datos de Ubicación**\\nPara proporcionarte datos precisos del clima y calidad del aire, la aplicación necesita acceso a tu ubicación.\\n- Las coordenadas se envían a nuestros proveedores de datos (OpenWeather) de forma anónima.\\n- Si guardas una ubicación, las coordenadas se almacenan cifradas en nuestro servidor seguro.\\n- No rastreamos tu historial de movimientos fuera de las consultas que realizas activamente.\\n\\n**4. Servicios de Terceros**\\nUtilizamos servicios de confianza para obtener datos:\\n- **OpenWeather:** Para datos meteorológicos y de calidad del aire.\\n- **Google Gemini:** Para generar recomendaciones de salud y clima basadas en los datos actuales.\\n\\n**5. Contacto**\\nSi tienes preguntas sobre esta política, contáctanos a través de la tienda de aplicaciones.';

  @override
  String get legalTermsContent =>
      '**Términos de Servicio de Aeris**\\n\\n**1. Aceptación**\\nAl usar Aeris, aceptas estos términos. La aplicación es gratuita y se proporciona tal cual.\\n\\n**2. Uso de la Aplicación**\\nEres libre de usar la aplicación para fines personales e informativos. No está permitido realizar ingeniería inversa ni intentar dañar nuestros servicios.\\n\\n**3. Descargo de Responsabilidad**\\nLa información de salud y clima es generada por Inteligencia Artificial y proveedores externos.\\n- **No es un consejo médico:** Las recomendaciones son solo informativas. Consulta siempre a un profesional de la salud.\\n- **Precisión:** No garantizamos que los datos sean 100% exactos en todo momento.\\n\\n**4. Cambios**\\nPodemos actualizar estos términos en cualquier momento. El uso continuo implica la aceptación de los cambios.';

  @override
  String get aqiAdviceGood =>
      '✅ La calidad del aire es excelente. Ideal para hacer ejercicio al aire libre, salir a caminar o practicar deporte. Disfruta del día sin restricciones.';

  @override
  String get aqiAdviceFair =>
      '🟡 La calidad del aire es aceptable. Personas con asma o enfermedades respiratorias crónicas deben moderar la actividad física intensa al exterior. El resto puede actuar con normalidad.';

  @override
  String get aqiAdviceModerate =>
      '🟠 Calidad moderada. Grupos sensibles (niños, adultos mayores, embarazadas y personas con problemas cardíacos o respiratorios) deben limitar la actividad física prolongada al aire libre.';

  @override
  String get aqiAdvicePoor =>
      '🔴 Calidad del aire deficiente. Todos pueden empezar a sentir efectos. Reduce el tiempo al aire libre, especialmente en actividades de alto esfuerzo físico. Usa mascarilla si sales.';

  @override
  String get aqiAdviceVeryPoor =>
      '🟣 Calidad muy mala — alerta sanitaria. Evita salir al exterior si no es estrictamente necesario. Cierra ventanas, usa purificador de aire en interiores y porta mascarilla FFP2 si debes salir.';

  @override
  String get aqiAdviceDangerous =>
      '⚫ Emergencia de salud pública. Toda la población está en riesgo. Permanece en interiores con ventanas y puertas selladas. Contacta a servicios de emergencia si sientes dificultad para respirar, dolor en el pecho o mareos.';

  @override
  String get weatherAdviceVeryCold =>
      '🧥 Temperatura muy baja. Abrígate bien con capas de ropa, presta especial atención a proteger manos, pies y cabeza. Evita la exposición prolongada al frío y bebe líquidos calientes.';

  @override
  String get weatherAdviceCold =>
      '🌬️ Hace frío. Usa ropa de abrigo y lleva una chaqueta extra. Si eres propenso a catarros o tienes afecciones respiratorias, cubre nariz y boca al salir.';

  @override
  String get weatherAdviceVeryHot =>
      '🥵 Calor extremo. Hidrátate constantemente, evita el sol directo entre las 11 h y las 17 h. Usa protector solar factor 50+, ropa ligera y permanece en lugares frescos. Presta atención a síntomas de golpe de calor (mareo, confusión, piel seca).';

  @override
  String get weatherAdviceHot =>
      '☀️ Día caluroso. Mantente hidratado bebiendo agua con regularidad, usa ropa ligera y aplica protector solar. Evita la actividad física intensa en las horas de mayor calor.';

  @override
  String get weatherAdviceStorm =>
      '⛈️ Tormenta eléctrica prevista. Evita espacios abiertos, árboles y estructuras metálicas. Permanece en interiores y desconecta aparatos eléctricos innecesarios.';

  @override
  String get weatherAdviceRain =>
      '🌧️ Se esperan lluvias. Lleva paraguas o chubasquero. Conduce con precaución por posible pavimento mojado y reduce la velocidad en zonas inundables.';

  @override
  String get weatherAdviceSnow =>
      '❄️ Nevadas. Usa calzado antideslizante, conduce con cadenas o neumáticos de invierno. Ten cuidado con el hielo en aceras y carreteras.';

  @override
  String get weatherAdviceFog =>
      '🌫️ Niebla o neblina. Visibilidad reducida en carreteras — usa luces antiniebla al conducir y reduce la velocidad. Personas con asma pueden notar irritación respiratoria.';

  @override
  String get weatherAdviceWind =>
      '💨 Vientos fuertes. Asegura objetos en balcones y jardines. Ten precaución al conducir vehículos altos y evita actividades al aire libre que requieran equilibrio.';

  @override
  String get weatherAdviceCloud =>
      '☁️ Cielo nublado. Temperatura agradable para actividades al aire libre. Aunque no haya sol directo, el UV puede seguir siendo moderado — considera protector solar.';

  @override
  String get weatherAdviceDefault =>
      '🌤️ Condiciones favorables. Buen día para actividades al exterior. Aplica protector solar si el índice UV es alto y mantente hidratado.';
}
