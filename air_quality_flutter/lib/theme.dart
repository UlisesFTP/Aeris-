import 'package:flutter/material.dart';

// --- TEMA CLARO ---
final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.black,
  scaffoldBackgroundColor: const Color(0xFFF5F5F5), // Un blanco no tan puro
  fontFamily: 'ProductSans', // Aplicamos tu nueva fuente
  colorScheme: const ColorScheme.light(
    primary: Colors.black,
    secondary: Colors.blueAccent,
    surface: Colors.white,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: Colors.black,
    background: Color(0xFFF5F5F5),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    elevation: 1,
    titleTextStyle: TextStyle(
      color: Colors.black,
      fontSize: 20,
      fontWeight: FontWeight.bold,
      fontFamily: 'ProductSans',
    ),
    iconTheme: IconThemeData(color: Colors.black),
  ),
  cardTheme: const CardThemeData(
    // Corregido a CardThemeData
    color: Colors.white,
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
  ),
  // ... (otros estilos para el tema claro)
);

// --- TEMA OSCURO ---
final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.white,
  scaffoldBackgroundColor: const Color(0xFF121212),
  fontFamily: 'ProductSans', // Aplicamos tu nueva fuente
  colorScheme: const ColorScheme.dark(
    primary: Colors.white,
    secondary: Color(0xFFBB86FC),
    surface: Color(0xFF000A11), // Tu color personalizado para las cards
    onPrimary: Colors.black,
    onSecondary: Colors.black,
    onSurface: Colors.white,
    background: Color(0xFF121212),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF0F1014), // Tu color personalizado para la AppBar
    elevation: 0,
    titleTextStyle: TextStyle(
      color:
          Colors.white, // CORREGIDO: El texto ahora es blanco para ser visible
      fontSize: 20,
      fontWeight: FontWeight.bold,
      fontFamily: 'ProductSans',
    ),
    iconTheme: IconThemeData(color: Colors.white),
  ),
  cardTheme: CardThemeData(
    color: const Color(0xFF1E1E1E),
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  // ... (otros estilos para el tema oscuro)
);
