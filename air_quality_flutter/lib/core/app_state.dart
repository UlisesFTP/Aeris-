import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Esta clase manejará el estado global de la aplicación, como el tema.
class AppState extends ChangeNotifier {
  // Por defecto, la app iniciará en modo oscuro, como en los diseños.
  bool _isDarkMode = true;
  bool get isDarkMode => _isDarkMode;

  AppState() {
    // Al iniciar, cargamos la preferencia de tema guardada.
    _loadTheme();
  }

  // Carga el estado del tema desde el almacenamiento local.
  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode =
        prefs.getBool('isDarkMode') ?? true; // Si no hay nada, es oscuro.
    notifyListeners();
  }

  // Cambia el tema y guarda la nueva preferencia.
  void toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners(); // Notifica a los widgets que escuchan para que se reconstruyan.
  }
}
