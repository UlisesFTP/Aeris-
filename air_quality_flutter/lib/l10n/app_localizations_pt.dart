// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Aeris';

  @override
  String get welcomeTitle => 'Bem-vindo ao Aeris';

  @override
  String get welcomeSubtitle => 'Seu companheiro de ar limpo';

  @override
  String get welcomeFeature1Title => 'Monitoramento em Tempo Real';

  @override
  String get welcomeFeature1Desc =>
      'Consulte a qualidade do ar e o clima instantaneamente.';

  @override
  String get welcomeFeature2Title => 'Alertas Inteligentes';

  @override
  String get welcomeFeature2Desc =>
      'Receba notificações quando a qualidade do ar piorar.';

  @override
  String get welcomeFeature3Title => 'Histórico Detalhado';

  @override
  String get welcomeFeature3Desc =>
      'Analise tendências históricas de poluição.';

  @override
  String get welcomeButton => 'Começar';

  @override
  String get navMap => 'Mapa';

  @override
  String get navHistory => 'Histórico';

  @override
  String get navAlerts => 'Alertas';

  @override
  String get navSettings => 'Configurações';

  @override
  String get mapSearchPlaceholder => 'Buscar cidade...';

  @override
  String get mapCurrentWeather => 'Clima Atual';

  @override
  String get mapWeatherAdvice => 'Conselho do Clima';

  @override
  String get mapHealthAdvice => 'Recomendação (IA)';

  @override
  String get mapAirQuality => 'Qualidade do Ar';

  @override
  String get mapPollutants => 'Poluentes';

  @override
  String get mapHistoryChart => 'Histórico (Últimas 24h)';

  @override
  String get mapViewFullHistory => 'Ver histórico completo';

  @override
  String get historyTitle => 'Histórico da Qualidade do Ar';

  @override
  String get historyLast7Days => 'Últimos 7 dias';

  @override
  String get historyChartTitle => 'Tendência de AQI';

  @override
  String get historyNoData => 'Nenhum dado de histórico disponível.';

  @override
  String get alertsTitle => 'Configuração de Alertas';

  @override
  String get alertsSubtitle => 'Gerencie suas notificações';

  @override
  String get alertsSectionPollutants => 'Tipos de Poluentes';

  @override
  String get alertsSwitchAirQuality => 'Qualidade do Ar (AQI)';

  @override
  String get alertsSwitchAirQualitySubtitle =>
      'Notificar quando o ar estiver ruim ou perigoso';

  @override
  String get alertsSwitchWeather => 'Estado do Clima';

  @override
  String get alertsSwitchWeatherSubtitle =>
      'Notificações diárias como o Google';

  @override
  String get alertsSectionLocations => 'Locais Salvos';

  @override
  String get alertsAddLocation => 'Adicionar Local';

  @override
  String get alertsCurrentLocation => 'Localização Atual';

  @override
  String get alertsSavedLocation => 'Local Salvo';

  @override
  String get alertsSectionPreferences => 'Preferências de Notificação';

  @override
  String get alertsAiRecommendations => 'Recomendações de IA';

  @override
  String get alertsAiRecommendationsSubtitle =>
      'Receba conselhos personalizados combinando clima e qualidade do ar.';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get settingsSectionGeneral => 'Geral';

  @override
  String get settingsThemeDark => 'Modo Escuro';

  @override
  String get settingsThemeDarkSubtitle => 'Alterar a aparência do aplicativo';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageSubtitle => 'Selecione seu idioma preferido';

  @override
  String get langSystem => 'Padrão do Sistema';

  @override
  String get settingsSectionSystem => 'Sistema';

  @override
  String get settingsNotifications => 'Notificações';

  @override
  String get settingsNotificationsSubtitle => 'Gerenciar permissões do sistema';

  @override
  String get settingsLocation => 'Localização';

  @override
  String get settingsLocationSubtitle => 'Gerenciar permissões de localização';

  @override
  String get settingsSectionInfo => 'Informações';

  @override
  String get settingsVersion => 'Versão';

  @override
  String get settingsPrivacyPolicy => 'Política de Privacidade';

  @override
  String get settingsTermsOfService => 'Termos de Serviço';

  @override
  String get settingsFooter => 'Aeris v1.0.0';

  @override
  String get legalPrivacyTitle => 'Política de Privacidade';

  @override
  String get legalTermsTitle => 'Termos de Serviço';

  @override
  String get legalFooter => 'Aeris - Aplicativo Gratuito';

  @override
  String get aqiGood => 'Bom';

  @override
  String get aqiFair => 'Aceitável';

  @override
  String get aqiModerate => 'Moderado';

  @override
  String get aqiPoor => 'Ruim';

  @override
  String get aqiVeryPoor => 'Muito Ruim';

  @override
  String get aqiDangerous => 'Perigoso';

  @override
  String get errorLoading => 'Erro ao carregar dados';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Excluir';

  @override
  String get next => 'Próximo';

  @override
  String get historyTabDay => 'Dia';

  @override
  String get historyTabWeek => 'Semana';

  @override
  String get historyTabMonth => 'Mês';

  @override
  String get historySectionSaved => 'Locais Salvos';

  @override
  String get historyNoSavedLocations => 'Nenhum local salvo';

  @override
  String get historySectionVisits => 'Visitas Recentes';

  @override
  String get historyNoRecentHistory => 'Nenhum histórico recente';

  @override
  String get historyDeleteTitle => 'Excluir Local';

  @override
  String historyDeleteConfirmation(String name) {
    return 'Tem certeza de que deseja excluir $name?';
  }

  @override
  String historyDeleted(String name) {
    return 'Local $name excluído';
  }

  @override
  String get alertsNewLocation => 'Novo Local';

  @override
  String get alertsNewLocationHint => 'Nome da cidade';

  @override
  String alertsSelectLocation(String name) {
    return 'Selecionar Local para $name';
  }

  @override
  String get alertsVerifying => 'Verificando...';

  @override
  String alertsVerified(int count) {
    return 'Verificado ($count)';
  }

  @override
  String get alertsCheckNow => 'Verificar Agora';

  @override
  String get alertsCurrentLocationSubtitle => 'Usar localização do dispositivo';

  @override
  String get alertsPollutantWeather => 'Clima';

  @override
  String get alertsPollutantWeatherSubtitle => 'Estado do tempo';

  @override
  String get alertsPollutantPM25 => 'PM2.5';

  @override
  String get alertsPollutantPM25Subtitle => 'Partículas finas';

  @override
  String get alertsPollutantPM10 => 'PM10';

  @override
  String get alertsPollutantPM10Subtitle => 'Partículas respiráveis';

  @override
  String get alertsPollutantO3 => 'Ozônio (O3)';

  @override
  String get alertsPollutantO3Subtitle => 'Ozônio troposférico';

  @override
  String get alertsLocationHome => 'Casa';

  @override
  String get alertsLocationWork => 'Trabalho';

  @override
  String get alertsTapToConfigure => 'Toque para configurar';

  @override
  String alertsLocationOf(String name) {
    return 'Localização de $name';
  }

  @override
  String get mapSearchResults => 'Resultados da Busca';

  @override
  String get mapLocationOnMap => 'Localização no mapa';

  @override
  String get mapSelectLocation => 'Selecione uma localização';

  @override
  String get mapSaveLocationTooltip => 'Salvar esta localização';

  @override
  String get mapSaveLocationHint => 'Ex: Casa, Escritório...';

  @override
  String get mapCancel => 'Cancelar';

  @override
  String get mapSave => 'Salvar';

  @override
  String mapLocationSaved(String name) {
    return '\"$name\" salvo.';
  }

  @override
  String get mapWeeklyForecast => 'Previsão Semanal';

  @override
  String get mapNoForecastAvailable => 'Nenhuma previsão disponível.';

  @override
  String get mapSelectLocationPrompt => 'Selecione uma localização.';

  @override
  String mapErrorGeolocation(String error) {
    return 'Erro de Geolocalização: $error';
  }

  @override
  String mapErrorSearching(String error) {
    return 'Erro ao buscar: $error';
  }

  @override
  String mapErrorGettingData(String error) {
    return 'Erro ao obter dados: $error';
  }

  @override
  String get notifAirQualityAlert => 'Alerta de Qualidade do Ar';

  @override
  String notifWeatherAt(int temp, String location) {
    return '$temp°C em $location';
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
  String get mapHealthAdviceAI => 'Conselho de Saúde (IA)';

  @override
  String get mapMainPollutants => 'Poluentes principais';

  @override
  String get mapEnvironmentalConditions => 'Condições ambientais';

  @override
  String get pollutantStatusLow => 'Baixo';

  @override
  String get pollutantStatusModerate => 'Moderado';

  @override
  String get pollutantStatusHigh => 'Alto';

  @override
  String get metricHumidity => 'Umidade';

  @override
  String get metricWind => 'Vento';

  @override
  String get metricPressure => 'Pressão';

  @override
  String get metricFeelsLike => 'Sensação térmica';

  @override
  String get aqiDescGood => 'Ar limpo. Perfeito para atividades ao ar livre.';

  @override
  String get aqiDescFair =>
      'Qualidade aceitável. Pessoas muito sensíveis, atenção.';

  @override
  String get aqiDescModerate =>
      'Grupos sensíveis podem sentir efeitos. Limite a exposição.';

  @override
  String get aqiDescPoor =>
      'Efeitos na saúde de todos. Reduza atividades ao ar livre.';

  @override
  String get aqiDescVeryPoor =>
      'Alerta de saúde. Evite sair se não for necessário.';

  @override
  String get aqiDescDangerous =>
      'Emergência de saúde. Permaneça em ambientes fechados.';

  @override
  String get forecastToday => 'Hoje';

  @override
  String get forecastTomorrow => 'Amanhã';

  @override
  String get emptyHistoryTitle => 'Ainda sem histórico';

  @override
  String get emptyHistorySubtitle =>
      'Comece a explorar locais para criar seu histórico.';

  @override
  String get emptySavedLocationsTitle => 'Nenhum local salvo';

  @override
  String get emptySavedLocationsSubtitle =>
      'Salve seus lugares favoritos para monitorar a qualidade do ar.';

  @override
  String get emptyAlertsTitle => 'Nenhum alerta ativo';

  @override
  String get emptyAlertsSubtitle =>
      'Configure alertas para ser notificado sobre a qualidade do ar.';

  @override
  String get emptySearchTitle => 'Nenhum resultado encontrado';

  @override
  String get emptySearchSubtitle =>
      'Tente pesquisar por um nome de cidade diferente.';

  @override
  String get errorNetworkTitle => 'Sem conexão com a internet';

  @override
  String get errorNetworkSubtitle => 'Verifique sua conexão e tente novamente.';

  @override
  String get errorLocationTitle => 'Acesso à localização negado';

  @override
  String get errorLocationSubtitle =>
      'Permita o acesso à localização para ver a qualidade do ar local.';

  @override
  String get errorGenericTitle => 'Algo deu errado';

  @override
  String get errorGenericSubtitle =>
      'Ocorreu um erro inesperado. Por favor, tente novamente.';

  @override
  String get openSettings => 'Abrir Configurações';

  @override
  String get onboardingMapTitle => 'Arraste o painel para cima';

  @override
  String get onboardingMapSubtitle =>
      'Deslize para cima para ver detalhes da qualidade do ar, clima e previsão.';

  @override
  String get onboardingAlertsTitle => 'Defina locais de alerta';

  @override
  String get onboardingAlertsSubtitle =>
      'Toque em um cartão de local para configurar onde monitorar a qualidade do ar.';

  @override
  String get legalPrivacyContent =>
      '**Política de Privacidade do Aeris**\\n\\n**Última Atualização:** 21 de Novembro de 2024\\n\\n**1. Introdução**\\nO Aeris é um aplicativo gratuito desenvolvido para informar sobre a qualidade do ar e o clima. Não exibimos anúncios nem vendemos seus dados.\\n\\n**2. Coleta de Dados**\\nO Aeris NÃO coleta, armazena ou compartilha informações de identificação pessoal. Não solicitamos registro ou login.\\n\\n**3. Dados de Localização**\\nPara fornecer dados precisos do clima e qualidade do ar, o aplicativo precisa de acesso à sua localização.\\n- As coordenadas são enviadas aos nossos provedores de dados (OpenWeather) de forma anônima.\\n- Se você salvar um local, as coordenadas serão armazenadas de forma criptografada em nosso servidor seguro.\\n- Não rastreamos o histórico de seus movimentos fora das consultas feitas de forma ativa por você.\\n\\n**4. Serviços de Terceiros**\\nUsamos serviços confiáveis para obter dados:\\n- **OpenWeather:** Para dados meteorológicos e de qualidade do ar.\\n- **Google Gemini:** Para gerar recomendações de saúde e clima com base nos dados atuais.\\n\\n**5. Contato**\\nSe tiver dúvidas sobre esta política, entre em contato conosco através da loja de aplicativos.';

  @override
  String get legalTermsContent =>
      '**Termos de Serviço do Aeris**\\n\\n**1. Aceitação**\\nAo usar o Aeris, você aceita estes termos. O aplicativo é gratuito e fornecido no estado em que se encontra.\\n\\n**2. Uso do Aplicativo**\\nVocê é livre para usar o aplicativo para fins pessoais e informativos. Não é permitido fazer engenharia reversa ou tentar prejudicar nossos serviços.\\n\\n**3. Isenção de Responsabilidade**\\nAs informações de saúde e clima são geradas por Inteligência Artificial e provedores externos.\\n- **Não é conselho médico:** As recomendações são apenas informativas. Sempre consulte um profissional de saúde.\\n- **Precisão:** Não garantimos que os dados sejam 100% precisos o tempo todo.\\n\\n**4. Alterações**\\nPodemos atualizar estes termos a qualquer momento. O uso contínuo implica na aceitação das alterações.';

  @override
  String get aqiAdviceGood =>
      '✅ A qualidade do ar é excelente. Ideal para exercícios ao ar livre, caminhadas ou esportes. Aproveite o dia sem restrições.';

  @override
  String get aqiAdviceFair =>
      '🟡 A qualidade do ar é aceitável. Pessoas com asma ou doenças respiratórias crônicas devem moderar a atividade física intensa ao ar livre. Outros podem agir normalmente.';

  @override
  String get aqiAdviceModerate =>
      '🟠 Qualidade moderada. Grupos sensíveis (crianças, idosos, grávidas e pessoas com problemas cardíacos ou respiratórios) devem limitar a atividade física prolongada ao ar livre.';

  @override
  String get aqiAdvicePoor =>
      '🔴 Qualidade do ar insatisfatória. Todos podem começar a sentir efeitos. Reduza o tempo ao ar livre, especialmente em atividades de alto esforço físico. Use máscara se sair.';

  @override
  String get aqiAdviceVeryPoor =>
      '🟣 Qualidade muito ruim — alerta de saúde. Evite sair ao ar livre, a menos que seja estritamente necessário. Feche as janelas, use um purificador de ar interno e use uma máscara FFP2 se precisar sair.';

  @override
  String get aqiAdviceDangerous =>
      '⚫ Emergência de saúde pública. Toda a população está em risco. Permaneça em ambientes fechados com janelas e portas seladas. Entre em contato com os serviços de emergência se sentir dificuldade para respirar, dor no peito ou tontura.';

  @override
  String get weatherAdviceVeryCold =>
      '🧥 Temperatura muito baixa. Vista-se bem com camadas de roupas, prestando atenção especial à proteção de mãos, pés e cabeça. Evite exposição prolongada ao frio e beba líquidos quentes.';

  @override
  String get weatherAdviceCold =>
      '🌬️ Está frio. Use roupas quentes e leve uma jaqueta extra. Se você é propenso a resfriados ou tem problemas respiratórios, cubra o nariz e a boca ao sair.';

  @override
  String get weatherAdviceVeryHot =>
      '🥵 Calor extremo. Hidrate-se constantemente, evite o sol direto entre 11h e 17h. Use protetor solar FPS 50+, use roupas leves e permaneça em locais frescos. Fique atento aos sintomas de insolação (tontura, confusão, pele seca).';

  @override
  String get weatherAdviceHot =>
      '☀️ Dia quente. Mantenha-se hidratado bebendo água regularmente, use roupas leves e aplique protetor solar. Evite atividades físicas intensas nas horas mais quentes.';

  @override
  String get weatherAdviceStorm =>
      '⛈️ Previsão de tempestade elétrica. Evite espaços abertos, árvores e estruturas metálicas. Permaneça em ambientes fechados e desconecte aparelhos elétricos desnecessários.';

  @override
  String get weatherAdviceRain =>
      '🌧️ Previsão de chuva. Leve um guarda-chuva ou capa de chuva. Dirija com cuidado devido ao asfalto molhado e reduza a velocidade em áreas propensas a alagamentos.';

  @override
  String get weatherAdviceSnow =>
      '❄️ Queda de neve. Use calçados antiderrapantes, dirija com correntes ou pneus de neve. Cuidado com o gelo em calçadas e estradas.';

  @override
  String get weatherAdviceFog =>
      '🌫️ Nevoeiro ou neblina. Visibilidade reduzia nas estradas — use faróis de neblina ao dirigir e reduza a velocidade. Pessoas com asma podem notar irritação respiratória.';

  @override
  String get weatherAdviceWind =>
      '💨 Ventos fortes. Prenda objetos em varandas e jardins. Tenha cuidado ao dirigir veículos altos e evite atividades ao ar livre que exijam equilíbrio.';

  @override
  String get weatherAdviceCloud =>
      '☁️ Céu nublado. Temperatura agradável para atividades ao ar livre. Embora não haja luz solar direta, o índice UV ainda pode ser moderado — considere o uso de protetor solar.';

  @override
  String get weatherAdviceDefault =>
      '🌤️ Condições favoráveis. Bom dia para atividades ao ar livre. Aplique protetor solar se o índice UV estiver alto e mantenha-se hidratado.';
}
