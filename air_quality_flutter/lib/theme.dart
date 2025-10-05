import 'package:flutter/material.dart';

// Definimos nuestro tema oscuro personalizado inspirado en los diseños.
final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.white,
  scaffoldBackgroundColor: const Color(0xFF121212), // Un negro no tan puro

  // Usamos la fuente personalizada como la fuente por defecto de la app.
  fontFamily: 'ProductSans',

  // Esquema de colores
  colorScheme: const ColorScheme.dark(
    primary: Colors.white,
    secondary:
        Color(0xFFBB86FC), // Un acento morado sutil para algunos elementos
    surface: Color.fromARGB(
        255, 0, 10, 17), // Color para las 'cards' o superficies elevadas
    onPrimary: Colors.black,
    onSecondary: Colors.black,
    onSurface: Colors.white,
  ),

  // Estilo de la AppBar
  appBarTheme: const AppBarTheme(
    backgroundColor: Color.fromARGB(255, 56, 99, 255),
    elevation: 0,
    titleTextStyle: TextStyle(
      color: Color.fromARGB(255, 0, 0, 0),
      fontSize: 20,
      fontWeight: FontWeight.bold,
      fontFamily: 'ProductSans',
    ),
    iconTheme: IconThemeData(color: Colors.white),
  ),

  // Estilo de las tarjetas (Corregido a CardThemeData)
  cardTheme: CardThemeData(
    color: const Color(0xFF1E1E1E),
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),

  // Estilo de los campos de texto
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF2C2C2C),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
    labelStyle: const TextStyle(color: Colors.white70),
  ),

  // Estilo de los botones
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  ),
);
