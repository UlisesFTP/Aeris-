import '../models/models.dart';

/// Consejería local basada en tablas estáticas (OMS/EPA).
/// Sin llamadas a red — respuesta instantánea, funciona offline.
class LocalAdviceService {
  // ── AQI Health Advice ──────────────────────────────────────────────────────
  /// Returns a [HealthAdvice] based on AQI level (1–6, OpenWeather scale).
  static HealthAdvice getAqiAdvice(int aqi) {
    const advice = [
      // 1 – Good
      HealthAdvice(
        advice:
            '✅ La calidad del aire es excelente. Ideal para hacer ejercicio '
            'al aire libre, salir a caminar o practicar deporte. Disfruta del '
            'día sin restricciones.',
      ),
      // 2 – Fair
      HealthAdvice(
        advice:
            '🟡 La calidad del aire es aceptable. Personas con asma o '
            'enfermedades respiratorias crónicas deben moderar la actividad '
            'física intensa al exterior. El resto puede actuar con normalidad.',
      ),
      // 3 – Moderate
      HealthAdvice(
        advice:
            '🟠 Calidad moderada. Grupos sensibles (niños, adultos mayores, '
            'embarazadas y personas con problemas cardíacos o respiratorios) '
            'deben limitar la actividad física prolongada al aire libre.',
      ),
      // 4 – Poor
      HealthAdvice(
        advice:
            '🔴 Calidad del aire deficiente. Todos pueden empezar a sentir '
            'efectos. Reduce el tiempo al aire libre, especialmente en '
            'actividades de alto esfuerzo físico. Usa mascarilla si sales.',
      ),
      // 5 – Very Poor
      HealthAdvice(
        advice:
            '🟣 Calidad muy mala — alerta sanitaria. Evita salir al exterior '
            'si no es estrictamente necesario. Cierra ventanas, usa '
            'purificador de aire en interiores y porta mascarilla FFP2 si '
            'debes salir.',
      ),
      // 6 – Dangerous / Hazardous
      HealthAdvice(
        advice:
            '⚫ Emergencia de salud pública. Toda la población está en riesgo. '
            'Permanece en interiores con ventanas y puertas selladas. '
            'Contacta a servicios de emergencia si sientes dificultad para '
            'respirar, dolor en el pecho o mareos.',
      ),
    ];

    final idx = (aqi - 1).clamp(0, advice.length - 1);
    return advice[idx];
  }

  // ── Weather Advice ─────────────────────────────────────────────────────────
  /// Returns a [HealthAdvice] based on weather condition string and temperature.
  static HealthAdvice getWeatherAdvice({
    required String condition,
    required double temp,
    double? minTemp,
    double? maxTemp,
  }) {
    final lower = condition.toLowerCase();

    // --- Very cold ---
    if (temp < 5) {
      return const HealthAdvice(
        advice:
            '🧥 Temperatura muy baja. Abrígate bien con capas de ropa, '
            'presta especial atención a proteger manos, pies y cabeza. '
            'Evita la exposición prolongada al frío y bebe líquidos calientes.',
      );
    }

    // --- Cold ---
    if (temp < 15) {
      return const HealthAdvice(
        advice:
            '🌬️ Hace frío. Usa ropa de abrigo y lleva una chaqueta extra. '
            'Si eres propenso a catarros o tienes afecciones respiratorias, '
            'cubre nariz y boca al salir.',
      );
    }

    // --- Very hot ---
    if (temp > 35) {
      return const HealthAdvice(
        advice:
            '🥵 Calor extremo. Hidrátate constantemente, evita el sol directo '
            'entre las 11 h y las 17 h. Usa protector solar factor 50+, ropa '
            'ligera y permanece en lugares frescos. Presta atención a síntomas '
            'de golpe de calor (mareo, confusión, piel seca).',
      );
    }

    // --- Hot ---
    if (temp > 28) {
      return const HealthAdvice(
        advice:
            '☀️ Día caluroso. Mantente hidratado bebiendo agua con regularidad, '
            'usa ropa ligera y aplica protector solar. Evita la actividad '
            'física intensa en las horas de mayor calor.',
      );
    }

    // --- Condition-based (pleasant temperature range 15–28 °C) ---
    if (lower.contains('storm') || lower.contains('tormenta') ||
        lower.contains('thunder') || lower.contains('trueno')) {
      return const HealthAdvice(
        advice:
            '⛈️ Tormenta eléctrica prevista. Evita espacios abiertos, '
            'árboles y estructuras metálicas. Permanece en interiores y '
            'desconecta aparatos eléctricos innecesarios.',
      );
    }

    if (lower.contains('rain') || lower.contains('lluvia') ||
        lower.contains('drizzle') || lower.contains('llovizna') ||
        lower.contains('shower')) {
      return const HealthAdvice(
        advice:
            '🌧️ Se esperan lluvias. Lleva paraguas o chubasquero. Conduce con '
            'precaución por posible pavimento mojado y reduce la velocidad en '
            'zonas inundables.',
      );
    }

    if (lower.contains('snow') || lower.contains('nieve') ||
        lower.contains('blizzard') || lower.contains('sleet')) {
      return const HealthAdvice(
        advice:
            '❄️ Nevadas. Usa calzado antideslizante, conduce con cadenas o '
            'neumáticos de invierno. Ten cuidado con el hielo en aceras '
            'y carreteras.',
      );
    }

    if (lower.contains('fog') || lower.contains('niebla') ||
        lower.contains('mist') || lower.contains('haze') ||
        lower.contains('bruma')) {
      return const HealthAdvice(
        advice:
            '🌫️ Niebla o neblina. Visibilidad reducida en carreteras — '
            'usa luces antiniebla al conducir y reduce la velocidad. '
            'Personas con asma pueden notar irritación respiratoria.',
      );
    }

    if (lower.contains('wind') || lower.contains('viento') ||
        lower.contains('gust') || lower.contains('r\u00e1faga')) {
      return const HealthAdvice(
        advice:
            '💨 Vientos fuertes. Asegura objetos en balcones y jardines. '
            'Ten precaución al conducir vehículos altos y evita actividades '
            'al aire libre que requieran equilibrio.',
      );
    }

    if (lower.contains('cloud') || lower.contains('nube') ||
        lower.contains('overcast') || lower.contains('nublado')) {
      return const HealthAdvice(
        advice:
            '☁️ Cielo nublado. Temperatura agradable para actividades al '
            'aire libre. Aunque no haya sol directo, el UV puede seguir '
            'siendo moderado — considera protector solar.',
      );
    }

    // --- Default: clear / sunny ---
    return const HealthAdvice(
      advice:
          '🌤️ Condiciones favorables. Buen día para actividades al exterior. '
          'Aplica protector solar si el índice UV es alto y mantente hidratado.',
    );
  }
}
