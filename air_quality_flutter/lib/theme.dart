import 'package:flutter/material.dart';

// --- LIGHT THEME (Monochromatic Black & White) ---
final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  useMaterial3: true,
  fontFamily: 'ProductSans',
  colorScheme: const ColorScheme.light(
    primary: Color(0xFF000000), // Pure Black
    secondary: Color(0xFF333333), // Dark Gray
    tertiary: Color(0xFF666666), // Medium Gray
    surface: Color(0xFFFFFFFF), // Pure White
    surfaceContainerHighest: Color(0xFFF5F5F5), // Very Light Gray
    onPrimary: Color(0xFFFFFFFF), // White on black
    onSecondary: Color(0xFFFFFFFF), // White on dark gray
    onSurface: Color(0xFF1A1A1A), // Near-black text
    onSurfaceVariant: Color(0xFF666666), // Medium gray text
    error: Color(0xFF000000), // Black for errors (monochromatic)
    outline: Color(0xFFE5E5E5), // Very light gray for borders
  ),
  scaffoldBackgroundColor: const Color(0xFFFAFAFA), // Off-white
  appBarTheme: const AppBarTheme(
    centerTitle: false,
    backgroundColor: Color(0xFFFFFFFF), // Pure White
    elevation: 0,
    scrolledUnderElevation: 0.5,
    shadowColor: Color(0x0A000000), // Subtle black shadow
    titleTextStyle: TextStyle(
      color: Color(0xFF000000), // Black
      fontSize: 24,
      fontWeight: FontWeight.w700,
      fontFamily: 'ProductSans',
      letterSpacing: -0.5,
    ),
    iconTheme: IconThemeData(color: Color(0xFF000000)), // Black
  ),
  cardTheme: CardThemeData(
    color: const Color(0xFFFFFFFF), // Pure White
    elevation: 0,
    shadowColor: Colors.black.withOpacity(0.04),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: const BorderSide(color: Color(0xFFE5E5E5), width: 1),
    ),
    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      backgroundColor: const Color(0xFF000000), // Black
      foregroundColor: const Color(0xFFFFFFFF), // White
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
      ),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: const Color(0xFF000000), // Black
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      textStyle: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFFF5F5F5), // Very Light Gray
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFE5E5E5), width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFF000000), width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    hintStyle: const TextStyle(
      color: Color(0xFF999999), // Light gray
      fontWeight: FontWeight.w400,
    ),
  ),
  dividerTheme: const DividerThemeData(
    color: Color(0xFFE5E5E5),
    thickness: 1,
    space: 1,
  ),
  iconTheme: const IconThemeData(
    color: Color(0xFF000000), // Black
    size: 24,
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: Color(0xFF000000),
      letterSpacing: -0.5,
    ),
    displayMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: Color(0xFF000000),
      letterSpacing: -0.5,
    ),
    displaySmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: Color(0xFF000000),
      letterSpacing: -0.3,
    ),
    headlineMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: Color(0xFF000000),
      letterSpacing: -0.2,
    ),
    titleLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Color(0xFF1A1A1A),
      letterSpacing: 0,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Color(0xFF1A1A1A),
      letterSpacing: 0.1,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Color(0xFF1A1A1A),
      letterSpacing: 0.1,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: Color(0xFF333333),
      height: 1.5,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: Color(0xFF666666),
      height: 1.5,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: Color(0xFF999999),
      height: 1.4,
    ),
  ),
);

// --- DARK THEME (Monochromatic Black & White) ---
final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  useMaterial3: true,
  fontFamily: 'ProductSans',
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFFFFFFFF), // Pure White
    secondary: Color(0xFFE0E0E0), // Light Gray
    tertiary: Color(0xFFCCCCCC), // Medium-Light Gray
    surface: Color(0xFF1A1A1A), // Very Dark Gray
    surfaceContainerHighest: Color(0xFF252525), // Lighter Dark Gray
    onPrimary: Color(0xFF000000), // Black on white
    onSecondary: Color(0xFF000000), // Black on light gray
    onSurface: Color(0xFFFFFFFF), // White text
    onSurfaceVariant: Color(0xFFCCCCCC), // Light gray text
    error: Color(0xFFFFFFFF), // White for errors (monochromatic)
    outline: Color(0xFF333333), // Dark gray for borders
  ),
  scaffoldBackgroundColor: const Color(0xFF0A0A0A), // Near-black
  appBarTheme: const AppBarTheme(
    centerTitle: false,
    backgroundColor: Color(0xFF1A1A1A), // Very Dark Gray
    elevation: 0,
    scrolledUnderElevation: 0.5,
    shadowColor: Color(0x33000000), // Medium black shadow
    titleTextStyle: TextStyle(
      color: Color(0xFFFFFFFF), // White
      fontSize: 24,
      fontWeight: FontWeight.w700,
      fontFamily: 'ProductSans',
      letterSpacing: -0.5,
    ),
    iconTheme: IconThemeData(color: Color(0xFFFFFFFF)), // White
  ),
  cardTheme: CardThemeData(
    color: const Color(0xFF1A1A1A), // Very Dark Gray
    elevation: 0,
    shadowColor: Colors.black.withOpacity(0.3),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: const BorderSide(color: Color(0xFF333333), width: 1),
    ),
    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      backgroundColor: const Color(0xFFFFFFFF), // White
      foregroundColor: const Color(0xFF000000), // Black
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
      ),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: const Color(0xFFFFFFFF), // White
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      textStyle: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF252525), // Lighter Dark Gray
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFF333333), width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFFFFFFF), width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    hintStyle: const TextStyle(
      color: Color(0xFF808080), // Medium gray
      fontWeight: FontWeight.w400,
    ),
  ),
  dividerTheme: const DividerThemeData(
    color: Color(0xFF333333),
    thickness: 1,
    space: 1,
  ),
  iconTheme: const IconThemeData(
    color: Color(0xFFFFFFFF), // White
    size: 24,
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: Color(0xFFFFFFFF),
      letterSpacing: -0.5,
    ),
    displayMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: Color(0xFFFFFFFF),
      letterSpacing: -0.5,
    ),
    displaySmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: Color(0xFFFFFFFF),
      letterSpacing: -0.3,
    ),
    headlineMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: Color(0xFFFFFFFF),
      letterSpacing: -0.2,
    ),
    titleLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Color(0xFFFFFFFF),
      letterSpacing: 0,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Color(0xFFFFFFFF),
      letterSpacing: 0.1,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Color(0xFFFFFFFF),
      letterSpacing: 0.1,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: Color(0xFFE0E0E0),
      height: 1.5,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: Color(0xFFCCCCCC),
      height: 1.5,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: Color(0xFF999999),
      height: 1.4,
    ),
  ),
);
