import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Gestiona únicamente el estado de tema y lenguaje.
///
/// Reemplaza la porción de tema de AppState.
/// Consumers: MyApp (themeMode), SettingsScreen (isDarkMode).
@singleton
class ThemeNotifier extends ChangeNotifier {
  final SharedPreferences _prefs;

  bool _isDarkMode;
  String _currentLanguageCode = 'es';

  bool get isDarkMode => _isDarkMode;
  String get currentLanguageCode => _currentLanguageCode;

  ThemeNotifier(this._prefs)
      : _isDarkMode = _prefs.getBool('isDarkMode') ?? true;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  /// Actualizado desde _MyAppState.didChangeLocales() y en postFrame.
  void updateLanguage(String languageCode) {
    if (_currentLanguageCode == languageCode) return;
    _currentLanguageCode = languageCode;
    notifyListeners();
  }
}
