import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:air_quality_flutter/models/models.dart';
import '../api/api_service.dart';

// Esta clase es el "cerebro" que gestiona el estado global de la aplicación.
class AppState extends ChangeNotifier {
  final ApiService _apiService = ApiService();
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
  };
  Map<String, bool> get notificationSettings => _notificationSettings;

  // --- SAVED & RECENT LOCATIONS ---
  Map<String, SavedLocation> _savedLocations = {};
  Map<String, SavedLocation> get savedLocations => _savedLocations;

  List<SavedLocation> _recentLocations = [];
  List<SavedLocation> get recentLocations => _recentLocations;

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

    notifyListeners();
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
}
