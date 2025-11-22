import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:air_quality_flutter/models/models.dart';
import '../api/api_service.dart';
import '../services/alert_monitoring_service.dart';

class AppState extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final AlertMonitoringService _alertMonitoring = AlertMonitoringService();
  late SharedPreferences _prefs;

  // --- THEME STATE ---
  bool _isDarkMode = true;
  bool get isDarkMode => _isDarkMode;

  // --- NOTIFICATION PREFERENCES ---
  Map<String, bool> _notificationSettings = {
    'miUbicacion': true,
    'casa': true,
    'trabajo': false,
    'pm25': true,
    'pm10': false,
    'ozono': true,
    'weather': true,
  };
  Map<String, bool> get notificationSettings => _notificationSettings;

  // --- SAVED & RECENT LOCATIONS ---
  Map<String, SavedLocation> _savedLocations = {};
  Map<String, SavedLocation> get savedLocations => _savedLocations;

  List<SavedLocation> _recentLocations = [];
  List<SavedLocation> get recentLocations => _recentLocations;

  // --- ALERT LOCATIONS ---
  Map<String, AlertLocation> _alertLocations = {
    'home': const AlertLocation(id: 'home', name: 'Casa'),
    'work': const AlertLocation(id: 'work', name: 'Trabajo'),
  };
  Map<String, AlertLocation> get alertLocations => _alertLocations;

  // --- LOCATION HISTORY ---
  List<LocationVisit> _locationHistory = [];
  List<LocationVisit> get locationHistory => _locationHistory;
  TimeFilter _currentHistoryFilter = TimeFilter.week;
  TimeFilter get currentHistoryFilter => _currentHistoryFilter;

  // --- LANGUAGE STATE ---
  String _currentLanguageCode = 'es'; // Default to Spanish
  String get currentLanguageCode => _currentLanguageCode;

  void updateLanguage(String languageCode) {
    _currentLanguageCode = languageCode;
    notifyListeners();
  }

  AppState() {
    _loadPreferences();
  }

  // Carga todas las preferencias guardadas desde el disco.
  Future<void> _loadPreferences() async {
    _prefs = await SharedPreferences.getInstance();

    // Cargar tema
    _isDarkMode = _prefs.getBool('isDarkMode') ?? true;

    // Cargar ajustes de notificaciones
    final String? settingsString = _prefs.getString('notificationSettings');
    if (settingsString != null) {
      _notificationSettings =
          Map<String, bool>.from(json.decode(settingsString));
    }

    // Cargar ubicaciones guardadas desde el backend
    await loadSavedLocationsFromApi();

    // Cargar ubicaciones recientes
    final String? recentsString = _prefs.getString('recentLocations');
    if (recentsString != null) {
      final List<dynamic> recentJson = json.decode(recentsString);
      _recentLocations =
          recentJson.map((json) => SavedLocation.fromJson(json)).toList();
    }

    // Cargar ubicaciones de alerta
    final String? alertsString = _prefs.getString('alertLocations');
    if (alertsString != null) {
      final Map<String, dynamic> alertsJson = json.decode(alertsString);
      _alertLocations = alertsJson.map(
        (key, value) => MapEntry(key, AlertLocation.fromJson(value)),
      );
    }

    notifyListeners();

    // Check alert locations after initial load (with delay to ensure everything is ready)
    Future.delayed(const Duration(seconds: 2), () {
      checkAlertLocationsNow();
    });
  }

  // --- THEME METHODS ---
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  // --- NOTIFICATION METHODS ---
  void updateNotificationSetting(String key, bool value) {
    _notificationSettings[key] = value;
    _prefs.setString(
        'notificationSettings', json.encode(_notificationSettings));
    notifyListeners();
  }

  // --- LOCATION METHODS ---

  // Obtiene las ubicaciones guardadas desde la API del backend
  Future<void> loadSavedLocationsFromApi() async {
    try {
      final locationsList = await _apiService.getSavedLocations();
      _savedLocations = {for (var loc in locationsList) loc.name: loc};
      notifyListeners();
    } catch (e) {
      print("Error loading saved locations: $e");
    }
  }

  // Guarda una nueva ubicación o actualiza una existente
  Future<void> saveLocation(
      String name, double latitude, double longitude) async {
    final newLocation = SavedLocation(
      id: _savedLocations[name]?.id, // Mantiene el ID si ya existe
      name: name,
      latitude: latitude,
      longitude: longitude,
    );
    await _apiService.addSavedLocation(newLocation);
    // Recarga todo desde la API para asegurar consistencia
    await loadSavedLocationsFromApi();
  }

  // Elimina una ubicación guardada
  Future<void> removeSavedLocation(String id) async {
    await _apiService.deleteSavedLocation(id);
    await loadSavedLocationsFromApi();
  }

  // Añade una ubicación a la lista de búsquedas recientes
  void addRecentLocation(LocationSearchResult location) {
    final newRecent = SavedLocation.fromSearchResult(location);
    // Evita duplicados y la inserta al principio
    _recentLocations
        .removeWhere((loc) => loc.displayName == newRecent.displayName);
    _recentLocations.insert(0, newRecent);
    // Limita la lista a las 5 más recientes
    if (_recentLocations.length > 5) {
      _recentLocations = _recentLocations.sublist(0, 5);
    }

    final List<Map<String, dynamic>> recentsJson =
        _recentLocations.map((loc) => loc.toJson()).toList();
    _prefs.setString('recentLocations', json.encode(recentsJson));
    notifyListeners();
  }

  // --- ALERT LOCATION METHODS ---

  Future<void> _saveAlertLocations() async {
    final Map<String, dynamic> alertsJson =
        _alertLocations.map((key, value) => MapEntry(key, value.toJson()));
    await _prefs.setString('alertLocations', json.encode(alertsJson));
  }

  Future<void> updateAlertLocation(
      String id, double lat, double lon, String displayName) async {
    final existingLocation = _alertLocations[id];
    if (existingLocation != null) {
      _alertLocations[id] = existingLocation.copyWith(
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

  // --- ALERT MONITORING METHODS ---

  /// Checks all enabled alert locations and sends notifications if needed
  /// Returns the number of locations checked
  Future<int> checkAlertLocationsNow() async {
    if (!_alertMonitoring.shouldCheckNow()) {
      print('Skipping alert check - too soon since last check');
      return 0;
    }

    try {
      print('Checking alert locations for air quality...');
      final results = await _alertMonitoring.checkAlertLocations(
        this,
        languageCode: _currentLanguageCode,
      );
      _alertMonitoring.markCheckComplete();
      print('Checked ${results.length} alert locations');
      return results.length;
    } catch (e) {
      print('Error checking alert locations: $e');
      return 0;
    }
  }

  /// Forces an immediate check regardless of time interval
  Future<int> forceCheckAlertLocations() async {
    _alertMonitoring.resetCheckTimer();
    return await checkAlertLocationsNow();
  }

  // --- LOCATION HISTORY METHODS ---

  /// Load location history with specified time filter
  Future<void> loadLocationHistory(TimeFilter filter) async {
    try {
      _currentHistoryFilter = filter;
      final history = await _apiService.getLocationHistory(filter);
      _locationHistory = history;
      notifyListeners();
    } catch (e) {
      print('Error loading location history: $e');
      _locationHistory = [];
      notifyListeners();
    }
  }

  /// Record a location visit when user searches or views a location
  Future<void> recordLocationVisit(
      double lat, double lon, String locationName) async {
    try {
      await _apiService.recordLocationVisit(lat, lon, locationName);
      // Optionally reload history to reflect the new visit
      await loadLocationHistory(_currentHistoryFilter);
    } catch (e) {
      print('Error recording location visit: $e');
      // Don't interrupt user flow if tracking fails
    }
  }

  /// Change the time filter and reload history
  Future<void> setHistoryFilter(TimeFilter filter) async {
    if (_currentHistoryFilter != filter) {
      await loadLocationHistory(filter);
    }
  }
}
