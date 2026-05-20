import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/models.dart';
import 'hive_service.dart';

/// Migración única de SharedPreferences → Hive para datos estructurados.
///
/// Se ejecuta en main.dart una sola vez (guarda un flag en SharedPreferences
/// al terminar). Migra:
///   - savedLocations (JSON map)  → HiveService.savedLocationsBox
///   - alertLocations (JSON map)  → HiveService.alertLocationsBox
///   - locationVisitHistory (JSON list) → HiveService.locationHistoryBox
///
/// Las claves de SharedPreferences que almacenan PRIMITIVAS (isDarkMode,
/// showWelcome, notificationSettings, recentLocations, etc.) NO se migran
/// porque AppState seguirá leyendo esas claves directamente desde SharedPreferences.
class MigrationService {
  MigrationService._(); // Clase utilitaria, sin instancia.

  /// Clave que indica que la migración v1 ya fue completada.
  static const _migrationDoneKey = 'hive_migration_v1_done';

  // Claves de SharedPreferences que serán migradas y luego ya no se usan
  // (los datos pasarán a Hive).
  static const _keysSavedLocations = 'savedLocations';
  static const _keysAlertLocations = 'alertLocations';
  static const _keysLocationHistory = 'locationVisitHistory';

  /// Ejecuta la migración si no se ha hecho todavía.
  /// Es seguro llamar esto en cada arranque; es un no-op si ya migró.
  static Future<void> run({
    required SharedPreferences prefs,
    required HiveService hive,
  }) async {
    if (prefs.getBool(_migrationDoneKey) == true) return; // Ya migrado.

    // ── Ubicaciones guardadas ────────────────────────────────────────────────
    final savedJson = prefs.getString(_keysSavedLocations);
    if (savedJson != null) {
      try {
        final map = json.decode(savedJson) as Map<String, dynamic>;
        for (final entry in map.entries) {
          final loc = SavedLocation.fromJson(
            entry.value as Map<String, dynamic>,
          );
          await hive.putSavedLocation(entry.key, loc);
        }
      } catch (_) {
        // Si el JSON está corrupto, ignorar y dejar caja vacía.
      }
    }

    // ── Ubicaciones de alertas ───────────────────────────────────────────────
    final alertJson = prefs.getString(_keysAlertLocations);
    if (alertJson != null) {
      try {
        final map = json.decode(alertJson) as Map<String, dynamic>;
        final locations = <String, AlertLocation>{};
        for (final entry in map.entries) {
          locations[entry.key] = AlertLocation.fromJson(
            entry.value as Map<String, dynamic>,
          );
        }
        await hive.replaceAllAlertLocations(locations);
      } catch (_) {
        // Si el JSON está corrupto, usar los defaults (se crean en AppState).
      }
    }

    // ── Historial de visitas ─────────────────────────────────────────────────
    final historyJson = prefs.getString(_keysLocationHistory);
    if (historyJson != null) {
      try {
        final list = json.decode(historyJson) as List<dynamic>;
        final visits = list
            .map((e) => LocationVisit.fromJson(e as Map<String, dynamic>))
            .toList();
        await hive.replaceAllLocationHistory(visits);
      } catch (_) {
        // Si el JSON está corrupto, dejar historial vacío.
      }
    }

    // Marcar como completada.
    await prefs.setBool(_migrationDoneKey, true);
  }
}
