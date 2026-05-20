import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/models.dart';
import '../../services/alert_monitoring_service.dart';
import '../database/hive_service.dart';

/// Gestiona ubicaciones de alerta, ajustes de notificaciones y monitoreo de AQI.
///
/// Reemplaza la porción de alertas de AppState.
/// Consumers: AlertsScreen.
@singleton
class AlertNotifier extends ChangeNotifier {
  final SharedPreferences _prefs;
  final HiveService _hiveService;
  final AlertMonitoringService _alertMonitoring;

  // Idioma activo — actualizado desde _MyAppState vía updateLanguageCode().
  String _languageCode = 'es';

  // Ajustes de notificaciones (SharedPreferences).
  Map<String, bool> _notificationSettings = {
    'miUbicacion': true,
    'casa': true,
    'trabajo': false,
    'useAiRecommendations': true,
  };

  // Ubicaciones de alerta configuradas (Hive).
  Map<String, AlertLocation> _alertLocations = {
    'home': const AlertLocation(id: 'home', name: 'Casa'),
    'work': const AlertLocation(id: 'work', name: 'Trabajo'),
  };

  Map<String, bool> get notificationSettings => _notificationSettings;
  Map<String, AlertLocation> get alertLocations => _alertLocations;

  AlertNotifier(this._prefs, this._hiveService, this._alertMonitoring) {
    _init();
  }

  void _init() {
    // Cargar ajustes de notificaciones desde SharedPreferences.
    final settingsString = _prefs.getString('notificationSettings');
    if (settingsString != null) {
      try {
        _notificationSettings =
            Map<String, bool>.from(json.decode(settingsString));
      } catch (_) {}
    }

    // Cargar ubicaciones de alerta desde Hive.
    final fromHive = _hiveService.allAlertLocations;
    if (fromHive.isNotEmpty) {
      _alertLocations = fromHive;
    }

    // Verificación diferida (2s) para dar tiempo al framework a arrancar.
    Future.delayed(const Duration(seconds: 2), () {
      checkAlertLocationsNow();
    });
  }

  /// Actualiza el código de idioma para las notificaciones.
  /// Llamado desde _MyAppState cuando cambia el locale.
  void updateLanguageCode(String code) {
    _languageCode = code;
  }

  // ── Notification settings ────────────────────────────────────────────────

  void updateNotificationSetting(String key, bool value) {
    _notificationSettings[key] = value;
    _prefs.setString('notificationSettings', json.encode(_notificationSettings));
    notifyListeners();
  }

  // ── Alert locations ──────────────────────────────────────────────────────

  Future<void> _saveAlertLocations() async {
    await _hiveService.replaceAllAlertLocations(_alertLocations);
  }

  Future<void> updateAlertLocation(
      String id, double lat, double lon, String displayName) async {
    final existing = _alertLocations[id];
    if (existing != null) {
      _alertLocations[id] = existing.copyWith(
        latitude: lat,
        longitude: lon,
        displayName: displayName,
        enabled: true,
      );
      await _saveAlertLocations();
      notifyListeners();
    }
  }

  void toggleAlertLocation(String id, bool enabled) {
    final location = _alertLocations[id];
    if (location != null && location.isConfigured) {
      _alertLocations[id] = location.copyWith(enabled: enabled);
      _saveAlertLocations();
      notifyListeners();
    }
  }

  Future<void> addCustomAlertLocation(
      String name, double lat, double lon, String displayName) async {
    final id = 'custom_${DateTime.now().millisecondsSinceEpoch}';
    _alertLocations[id] = AlertLocation(
      id: id,
      name: name,
      latitude: lat,
      longitude: lon,
      displayName: displayName,
      enabled: true,
    );
    await _saveAlertLocations();
    notifyListeners();
  }

  Future<void> removeAlertLocation(String id) async {
    if (id.startsWith('custom_')) {
      _alertLocations.remove(id);
      await _saveAlertLocations();
      notifyListeners();
    }
  }

  // ── Alert monitoring ─────────────────────────────────────────────────────

  Future<int> checkAlertLocationsNow({bool force = false}) async {
    if (!force && !_alertMonitoring.shouldCheckNow()) return 0;
    try {
      final results = await _alertMonitoring.checkAlertLocations(
        alertLocations: _alertLocations,
        notificationSettings: _notificationSettings,
        languageCode: _languageCode,
        force: force,
      );
      _alertMonitoring.markCheckComplete();
      return results.length;
    } catch (e) {
      return 0;
    }
  }

  Future<int> forceCheckAlertLocations() async {
    _alertMonitoring.resetCheckTimer();
    return await checkAlertLocationsNow(force: true);
  }
}
