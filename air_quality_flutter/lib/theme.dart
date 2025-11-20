import 'package:flutter/material.dart';

// --- TEMA CLARO ---
final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  useMaterial3: true,
  fontFamily: 'ProductSans',
  colorScheme: const ColorScheme.light(
    primary: Color(0xFF006A6A), // Deep Teal
    secondary: Color(0xFF4CAF50), // Soft Green
    tertiary: Color(0xFF0288D1), // Ocean Blue
    surface: Colors.white,
    surfaceContainerHighest: Color(0xFFF0F4F8), // Subtle background tint
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: Color(0xFF1A1C1E),
    error: Color(0xFFB00020),
  ),
  scaffoldBackgroundColor: const Color(0xFFF8FAFB),
  appBarTheme: const AppBarTheme(
    centerTitle: false,
    backgroundColor: Colors.white,
    elevation: 0,
    scrolledUnderElevation: 1,
    titleTextStyle: TextStyle(
      color: Color(0xFF1A1C1E),
      fontSize: 22,
      fontWeight: FontWeight.w600,
      fontFamily: 'ProductSans',
      letterSpacing: 0.15,
    ),
    iconTheme: IconThemeData(color: Color(0xFF006A6A)),
  ),
  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 0,
    shadowColor: Colors.black.withOpacity(0.08),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: Colors.black.withOpacity(0.08), width: 1),
    ),
    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      backgroundColor: const Color(0xFF006A6A),
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFFF0F4F8),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF006A6A), width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  ),
);

// --- TEMA OSCURO ---
final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  useMaterial3: true,
  fontFamily: 'ProductSans',
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF4DB6AC), // Lighter Teal for dark mode
    secondary: Color(0xFF66BB6A), // Lighter Green
    tertiary: Color(0xFF42A5F5), // Lighter Blue
    surface: Color(0xFF1A1C1E),
    surfaceContainerHighest: Color(0xFF2C2F33),
    onPrimary: Color(0xFF003737),
    onSecondary: Color(0xFF003300),
    onSurface: Color(0xFFE1E3E5),
    error: Color(0xFFCF6679),
  ),
  scaffoldBackgroundColor: const Color(0xFF121212),
  appBarTheme: const AppBarTheme(
    centerTitle: false,
    backgroundColor: Color(0xFF1A1C1E),
    elevation: 0,
    scrolledUnderElevation: 1,
    titleTextStyle: TextStyle(
      color: Color(0xFFE1E3E5),
      fontSize: 22,
      fontWeight: FontWeight.w600,
      fontFamily: 'ProductSans',
      letterSpacing: 0.15,
    ),
    iconTheme: IconThemeData(color: Color(0xFF4DB6AC)),
  ),
  cardTheme: CardThemeData(
    color: const Color(0xFF1A1C1E),
    elevation: 0,
    shadowColor: Colors.black.withOpacity(0.3),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
    ),
    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      backgroundColor: const Color(0xFF4DB6AC),
      foregroundColor: const Color(0xFF003737),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF2C2F33),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF4DB6AC), width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  ),
);
