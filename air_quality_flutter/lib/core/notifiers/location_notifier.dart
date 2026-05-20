import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/models.dart';
import '../database/hive_service.dart';

/// Gestiona ubicaciones guardadas, recientes, historial y posición del dispositivo.
///
/// Reemplaza la porción de ubicaciones de AppState.
/// Consumers: MapScreen, HistoryScreen.
@singleton
class LocationNotifier extends ChangeNotifier {
  final SharedPreferences _prefs;
  final HiveService _hiveService;

  // ── Saved locations (Hive) ───────────────────────────────────────────────
  Map<String, SavedLocation> _savedLocations = {};
  Map<String, SavedLocation> get savedLocations => _savedLocations;

  // ── Recent locations (SharedPreferences — datos efímeros) ───────────────
  List<SavedLocation> _recentLocations = [];
  List<SavedLocation> get recentLocations => _recentLocations;

  // ── Location history (Hive) ──────────────────────────────────────────────
  List<LocationVisit> _locationHistory = [];
  List<LocationVisit> get locationHistory => _locationHistory;
  TimeFilter _currentHistoryFilter = TimeFilter.week;
  TimeFilter get currentHistoryFilter => _currentHistoryFilter;

  // ── Last known device position (SharedPreferences) ───────────────────────
  double? _lastKnownDeviceLat;
  double? _lastKnownDeviceLon;
  DateTime? _lastKnownDeviceTimestamp;
  double? get lastKnownDeviceLat => _lastKnownDeviceLat;
  double? get lastKnownDeviceLon => _lastKnownDeviceLon;
  DateTime? get lastKnownDeviceTimestamp => _lastKnownDeviceTimestamp;

  LocationNotifier(this._prefs, this._hiveService) {
    _init();
  }

  void _init() {
    _savedLocations = _hiveService.allSavedLocations;

    final recentsString = _prefs.getString('recentLocations');
    if (recentsString != null) {
      try {
        final recentJson = json.decode(recentsString) as List<dynamic>;
        _recentLocations =
            recentJson.map((j) => SavedLocation.fromJson(j)).toList();
      } catch (_) {}
    }

    _locationHistory = _hiveService.allLocationHistory;
    _loadLastKnownDevicePosition();
  }

  void _loadLastKnownDevicePosition() {
    final raw = _prefs.getString('lastKnownDevicePosition');
    if (raw == null) return;
    try {
      final data = json.decode(raw) as Map<String, dynamic>;
      _lastKnownDeviceLat = (data['lat'] as num).toDouble();
      _lastKnownDeviceLon = (data['lon'] as num).toDouble();
      _lastKnownDeviceTimestamp =
          DateTime.parse(data['timestamp'] as String);
    } catch (_) {}
  }

  // ── Saved location methods ───────────────────────────────────────────────

  Future<void> saveLocation(
      String name, double latitude, double longitude) async {
    final existingId = _savedLocations[name]?.id;
    final newLocation = SavedLocation(
      id: existingId ?? 'local_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      latitude: latitude,
      longitude: longitude,
    );
    _savedLocations[name] = newLocation;
    await _hiveService.replaceAllSavedLocations(_savedLocations);
    notifyListeners();
  }

  Future<void> loadSavedLocationsFromApi() async {
    _savedLocations = _hiveService.allSavedLocations;
    notifyListeners();
  }

  Future<void> removeSavedLocation(String id) async {
    _savedLocations.removeWhere((key, loc) => loc.id == id);
    await _hiveService.replaceAllSavedLocations(_savedLocations);
    notifyListeners();
  }

  // ── Recent location methods ──────────────────────────────────────────────

  void addRecentLocation(LocationSearchResult location) {
    final newRecent = SavedLocation.fromSearchResult(location);
    _recentLocations
        .removeWhere((loc) => loc.displayName == newRecent.displayName);
    _recentLocations.insert(0, newRecent);
    if (_recentLocations.length > 5) {
      _recentLocations = _recentLocations.sublist(0, 5);
    }
    _prefs.setString(
      'recentLocations',
      json.encode(_recentLocations.map((l) => l.toJson()).toList()),
    );
    notifyListeners();
  }

  // ── Location history methods ─────────────────────────────────────────────

  Future<void> loadLocationHistory(TimeFilter filter) async {
    _currentHistoryFilter = filter;
    _locationHistory = _hiveService.allLocationHistory;
    final cutoff = DateTime.now().subtract(Duration(days: filter.days));
    _locationHistory =
        _locationHistory.where((v) => v.visitedAt.isAfter(cutoff)).toList();
    notifyListeners();
  }

  Future<void> setHistoryFilter(TimeFilter filter) async {
    if (_currentHistoryFilter != filter) {
      await loadLocationHistory(filter);
    }
  }

  Future<void> recordLocationVisit(
      double lat, double lon, String locationName) async {
    // Recargar desde disco para no perder datos escritos en background.
    _locationHistory = _hiveService.allLocationHistory;

    final existingIndex = _locationHistory.indexWhere(
      (v) =>
          v.locationName == locationName &&
          (v.latitude - lat).abs() < 0.01 &&
          (v.longitude - lon).abs() < 0.01,
    );

    if (existingIndex >= 0) {
      final existing = _locationHistory[existingIndex];
      _locationHistory[existingIndex] = LocationVisit(
        locationName: existing.locationName,
        latitude: existing.latitude,
        longitude: existing.longitude,
        visitedAt: DateTime.now(),
        searchCount: existing.searchCount + 1,
      );
    } else {
      _locationHistory.insert(
        0,
        LocationVisit(
          locationName: locationName,
          latitude: lat,
          longitude: lon,
          visitedAt: DateTime.now(),
          searchCount: 1,
        ),
      );
    }

    _locationHistory.sort((a, b) => b.visitedAt.compareTo(a.visitedAt));
    if (_locationHistory.length > 50) {
      _locationHistory = _locationHistory.sublist(0, 50);
    }

    await _hiveService.replaceAllLocationHistory(_locationHistory);
    notifyListeners();
  }

  // ── Device position ──────────────────────────────────────────────────────

  Future<void> updateLastKnownDevicePosition(double lat, double lon) async {
    _lastKnownDeviceLat = lat;
    _lastKnownDeviceLon = lon;
    _lastKnownDeviceTimestamp = DateTime.now();
    await _prefs.setString(
      'lastKnownDevicePosition',
      json.encode({
        'lat': lat,
        'lon': lon,
        'timestamp': _lastKnownDeviceTimestamp!.toIso8601String(),
      }),
    );
    notifyListeners();
  }
}
