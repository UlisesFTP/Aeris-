import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Gestiona el estado de tema y la preferencia de lenguaje.
///
/// Reemplaza la porción de tema de AppState.
/// Consumers: MyApp (themeMode), SettingsScreen (isDarkMode).
@singleton
class ThemeNotifier extends ChangeNotifier {
  final SharedPreferences _prefs;

  bool _isDarkMode;
  String? _preferredLanguageCode; // Nulo representa "sistema" (automático)
  String _systemLanguageCode = 'es';

  bool get isDarkMode => _isDarkMode;
  
  /// Idioma preferido guardado (nulo si es automático/sistema)
  String? get preferredLanguageCode => _preferredLanguageCode;

  /// Retorna el idioma activo actual (el seleccionado por el usuario o, en su defecto, el del sistema)
  String get currentLanguageCode => _preferredLanguageCode ?? _systemLanguageCode;

  ThemeNotifier(this._prefs)
      : _isDarkMode = _prefs.getBool('isDarkMode') ?? true,
        _preferredLanguageCode = _prefs.getString('preferredLanguageCode') {
    // Sincronizar el idioma actual al iniciar
    _prefs.setString('currentLanguageCode', currentLanguageCode);
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  /// Actualizado desde _MyAppState.didChangeLocales() y en postFrame
  void updateSystemLanguage(String languageCode) {
    if (_systemLanguageCode == languageCode) return;
    _systemLanguageCode = languageCode;
    _prefs.setString('currentLanguageCode', currentLanguageCode);
    notifyListeners();
  }

  /// Guarda y aplica manualmente un idioma preferido (null para automático)
  void setPreferredLanguage(String? languageCode) {
    if (_preferredLanguageCode == languageCode) return;
    _preferredLanguageCode = languageCode;
    if (languageCode == null) {
      _prefs.remove('preferredLanguageCode');
    } else {
      _prefs.setString('preferredLanguageCode', languageCode);
    }
    _prefs.setString('currentLanguageCode', currentLanguageCode);
    notifyListeners();
  }

  /// Delegación para compatibilidad hacia atrás
  void updateLanguage(String languageCode) {
    updateSystemLanguage(languageCode);
  }
}
