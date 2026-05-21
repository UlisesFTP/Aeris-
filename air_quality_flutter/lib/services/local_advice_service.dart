import '../models/models.dart';
import 'package:air_quality_flutter/l10n/app_localizations.dart';

/// Consejería local basada en tablas estáticas (OMS/EPA).
/// Sin llamadas a red — respuesta instantánea, funciona offline.
class LocalAdviceService {
  // ── AQI Health Advice ──────────────────────────────────────────────────────
  /// Returns a [HealthAdvice] based on AQI level (1–6, OpenWeather scale).
  static HealthAdvice getAqiAdvice(int aqi, AppLocalizations l10n) {
    final advice = [
      // 1 – Good
      HealthAdvice(advice: l10n.aqiAdviceGood),
      // 2 – Fair
      HealthAdvice(advice: l10n.aqiAdviceFair),
      // 3 – Moderate
      HealthAdvice(advice: l10n.aqiAdviceModerate),
      // 4 – Poor
      HealthAdvice(advice: l10n.aqiAdvicePoor),
      // 5 – Very Poor
      HealthAdvice(advice: l10n.aqiAdviceVeryPoor),
      // 6 – Dangerous / Hazardous
      HealthAdvice(advice: l10n.aqiAdviceDangerous),
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
    required AppLocalizations l10n,
  }) {
    final lower = condition.toLowerCase();

    // --- Very cold ---
    if (temp < 5) {
      return HealthAdvice(advice: l10n.weatherAdviceVeryCold);
    }

    // --- Cold ---
    if (temp < 15) {
      return HealthAdvice(advice: l10n.weatherAdviceCold);
    }

    // --- Very hot ---
    if (temp > 35) {
      return HealthAdvice(advice: l10n.weatherAdviceVeryHot);
    }

    // --- Hot ---
    if (temp > 28) {
      return HealthAdvice(advice: l10n.weatherAdviceHot);
    }

    // --- Condition-based (pleasant temperature range 15–28 °C) ---
    if (lower.contains('storm') || lower.contains('tormenta') ||
        lower.contains('thunder') || lower.contains('trueno')) {
      return HealthAdvice(advice: l10n.weatherAdviceStorm);
    }

    if (lower.contains('rain') || lower.contains('lluvia') ||
        lower.contains('drizzle') || lower.contains('llovizna') ||
        lower.contains('shower')) {
      return HealthAdvice(advice: l10n.weatherAdviceRain);
    }

    if (lower.contains('snow') || lower.contains('nieve') ||
        lower.contains('blizzard') || lower.contains('sleet')) {
      return HealthAdvice(advice: l10n.weatherAdviceSnow);
    }

    if (lower.contains('fog') || lower.contains('niebla') ||
        lower.contains('mist') || lower.contains('haze') ||
        lower.contains('bruma')) {
      return HealthAdvice(advice: l10n.weatherAdviceFog);
    }

    if (lower.contains('wind') || lower.contains('viento') ||
        lower.contains('gust') || lower.contains('r\u00e1faga')) {
      return HealthAdvice(advice: l10n.weatherAdviceWind);
    }

    if (lower.contains('cloud') || lower.contains('nube') ||
        lower.contains('overcast') || lower.contains('nublado')) {
      return HealthAdvice(advice: l10n.weatherAdviceCloud);
    }

    // --- Default: clear / sunny ---
    return HealthAdvice(advice: l10n.weatherAdviceDefault);
  }
}
