import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:air_quality_flutter/models/models.dart';
import '../services/alert_monitoring_service.dart';

class AppState extends ChangeNotifier {
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
    'useAiRecommendations': true,
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

  // Carga todas las preferencias guardadas desde el disco (100% local, sin API).
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

    // Cargar ubicaciones guardadas (LOCAL)
    _loadSavedLocationsLocal();

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

    // Cargar historial de visitas (LOCAL)
    _loadLocationVisitHistoryLocal();

    // Cargar última posición conocida del dispositivo
    _loadLastKnownDevicePosition();

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

  // --- LOCATION METHODS (100% LOCAL — SharedPreferences) ---

  // Carga las ubicaciones guardadas desde SharedPreferences
  void _loadSavedLocationsLocal() {
    final String? savedString = _prefs.getString('savedLocations');
    if (savedString != null) {
      final Map<String, dynamic> savedJson = json.decode(savedString);
      _savedLocations = savedJson.map(
        (key, value) => MapEntry(key, SavedLocation.fromJson(value)),
      );
    }
  }

  // Persiste las ubicaciones guardadas a SharedPreferences
  Future<void> _persistSavedLocations() async {
    final Map<String, dynamic> savedJson =
        _savedLocations.map((key, value) => MapEntry(key, value.toJson()));
    await _prefs.setString('savedLocations', json.encode(savedJson));
  }

  // Método público para recargar ubicaciones guardadas (ahora local, instantáneo)
  Future<void> loadSavedLocationsFromApi() async {
    _loadSavedLocationsLocal();
    notifyListeners();
  }

  // Guarda una nueva ubicación o actualiza una existente (LOCAL)
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
    await _persistSavedLocations();
    notifyListeners();
  }

  // Elimina una ubicación guardada (LOCAL)
  Future<void> removeSavedLocation(String id) async {
    _savedLocations.removeWhere((key, loc) => loc.id == id);
    await _persistSavedLocations();
    notifyListeners();
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
  Future<int> checkAlertLocationsNow({bool force = false}) async {
    if (!force && !_alertMonitoring.shouldCheckNow()) {
      print('Skipping alert check - too soon since last check');
      return 0;
    }

    try {
      print('Checking alert locations for air quality...');
      final results = await _alertMonitoring.checkAlertLocations(
        this,
        languageCode: _currentLanguageCode,
        force: force,
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
    return await checkAlertLocationsNow(force: true);
  }

  // --- LOCATION HISTORY METHODS (100% LOCAL — SharedPreferences) ---

  /// Carga el historial completo de visitas desde SharedPreferences
  void _loadLocationVisitHistoryLocal() {
    final String? historyString = _prefs.getString('locationVisitHistory');
    if (historyString != null) {
      final List<dynamic> historyJson = json.decode(historyString);
      _locationHistory =
          historyJson.map((j) => LocationVisit.fromJson(j)).toList();
    }
  }

  /// Persiste el historial de visitas a SharedPreferences
  Future<void> _persistLocationVisitHistory() async {
    final List<Map<String, dynamic>> historyJson =
        _locationHistory.map((v) => v.toJson()).toList();
    await _prefs.setString('locationVisitHistory', json.encode(historyJson));
  }

  /// Load location history with specified time filter (LOCAL)
  Future<void> loadLocationHistory(TimeFilter filter) async {
    _currentHistoryFilter = filter;
    // Recargar desde disco por si se actualizó
    _loadLocationVisitHistoryLocal();

    // Filtrar según el rango de tiempo seleccionado
    final cutoff = DateTime.now().subtract(Duration(days: filter.days));
    _locationHistory =
        _locationHistory.where((v) => v.visitedAt.isAfter(cutoff)).toList();
    notifyListeners();
  }

  /// Record a location visit when user searches or views a location (LOCAL)
  Future<void> recordLocationVisit(
      double lat, double lon, String locationName) async {
    // Recargar historial completo para no perder datos
    _loadLocationVisitHistoryLocal();

    // Buscar si ya existe una visita para esta ubicación
    final existingIndex = _locationHistory.indexWhere(
      (v) =>
          v.locationName == locationName &&
          (v.latitude - lat).abs() < 0.01 &&
          (v.longitude - lon).abs() < 0.01,
    );

    if (existingIndex >= 0) {
      // Actualizar la visita existente: incrementar contador y actualizar fecha
      final existing = _locationHistory[existingIndex];
      _locationHistory[existingIndex] = LocationVisit(
        locationName: existing.locationName,
        latitude: existing.latitude,
        longitude: existing.longitude,
        visitedAt: DateTime.now(),
        searchCount: existing.searchCount + 1,
      );
    } else {
      // Nueva visita
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

    // Limitar a las 50 visitas más recientes
    _locationHistory.sort((a, b) => b.visitedAt.compareTo(a.visitedAt));
    if (_locationHistory.length > 50) {
      _locationHistory = _locationHistory.sublist(0, 50);
    }

    await _persistLocationVisitHistory();
    notifyListeners();
  }

  /// Change the time filter and reload history
  Future<void> setHistoryFilter(TimeFilter filter) async {
    if (_currentHistoryFilter != filter) {
      await loadLocationHistory(filter);
    }
  }

  // ── LAST KNOWN DEVICE POSITION (para notificaciones de background) ─────────
  double? _lastKnownDeviceLat;
  double? _lastKnownDeviceLon;
  DateTime? _lastKnownDeviceTimestamp;

  double? get lastKnownDeviceLat => _lastKnownDeviceLat;
  double? get lastKnownDeviceLon => _lastKnownDeviceLon;
  DateTime? get lastKnownDeviceTimestamp => _lastKnownDeviceTimestamp;

  Future<void> updateLastKnownDevicePosition(double lat, double lon) async {
    _lastKnownDeviceLat = lat;
    _lastKnownDeviceLon = lon;
    _lastKnownDeviceTimestamp = DateTime.now();
    await _prefs.setString('lastKnownDevicePosition', json.encode({
      'lat': lat,
      'lon': lon,
      'timestamp': _lastKnownDeviceTimestamp!.toIso8601String(),
    }));
    notifyListeners();
  }

  void _loadLastKnownDevicePosition() {
    final String? raw = _prefs.getString('lastKnownDevicePosition');
    if (raw == null) return;
    try {
      final data = json.decode(raw) as Map<String, dynamic>;
      _lastKnownDeviceLat = (data['lat'] as num).toDouble();
      _lastKnownDeviceLon = (data['lon'] as num).toDouble();
      _lastKnownDeviceTimestamp = DateTime.parse(data['timestamp'] as String);
    } catch (_) {
      // Ignorar datos corruptos
    }
  }

  // ── CACHE LOCAL DE DATOS DEL MAPA ─────────────────────────────────────────
  /// Guarda en caché los datos de AQI + clima para una ubicación.
  Future<void> cacheMapData({
    required double lat,
    required double lon,
    required AirQualityData airQuality,
    required WeatherData weather,
    required List<ForecastItem> forecast,
  }) async {
    final cache = {
      'lat': lat,
      'lon': lon,
      'timestamp': DateTime.now().toIso8601String(),
      'airQuality': {'aqi': airQuality.aqi, 'components': airQuality.components},
      'weather': {'temp': weather.temp, 'condition': weather.condition, 'icon': weather.icon},
      'forecast': forecast.map((f) => {
        'date': f.date,
        'min_temp': f.minTemp,
        'max_temp': f.maxTemp,
        'icon': f.icon,
        'condition': f.condition,
      }).toList(),
    };
    await _prefs.setString('_cachedMapData', json.encode(cache));
  }

  /// Carga datos cacheados si la ubicación está cerca (< 2 km) y son recientes (< 15 min).
  Map<String, dynamic>? getCachedMapData(double lat, double lon) {
    final raw = _prefs.getString('_cachedMapData');
    if (raw == null) return null;
    try {
      final cache = json.decode(raw) as Map<String, dynamic>;
      final cachedLat = (cache['lat'] as num).toDouble();
      final cachedLon = (cache['lon'] as num).toDouble();
      final timestamp = DateTime.parse(cache['timestamp'] as String);
      final age = DateTime.now().difference(timestamp);

      // Considerar válido si está a menos de ~2 km y tiene menos de 15 min
      final distanceOk = (lat - cachedLat).abs() < 0.02 && (lon - cachedLon).abs() < 0.02;
      final timeOk = age <= const Duration(minutes: 15);

      if (distanceOk && timeOk) {
        return cache;
      }
    } catch (_) {
      // Ignorar cache corrupto
    }
    return null;
  }
}
