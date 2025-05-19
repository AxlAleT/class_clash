import 'package:flutter/material.dart';

final appTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFFE65100), // Warm orange as the primary seed color
    brightness: Brightness.light,
    secondary: const Color(0xFFD84315), // Deep orange as secondary
    tertiary: const Color(0xFFFF6F00), // Amber accent
  ),
  fontFamily: 'Roboto',
  appBarTheme: const AppBarTheme(
    centerTitle: true,
    elevation: 0,
    backgroundColor: Color(0xFFE65100), // Warm orange background
    foregroundColor: Colors.white,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      backgroundColor: const Color(0xFFE65100), // Warm orange buttons
      foregroundColor: Colors.white,
    ),
  ),
  cardTheme: CardTheme(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    color: Colors.white,
    shadowColor: const Color(0xFFF9A825).withOpacity(0.3), // Warm shadow
  ),
  scaffoldBackgroundColor: const Color(0xFFFFFBE6),
  // Warm off-white background
  textTheme: const TextTheme(
    titleLarge: TextStyle(color: Color(0xFF5D4037)), // Warm brown text
    titleMedium: TextStyle(color: Color(0xFF5D4037)),
    bodyLarge: TextStyle(color: Color(0xFF795548)), // Brown text
    bodyMedium: TextStyle(color: Color(0xFF795548)),
  ),
  chipTheme: ChipThemeData(
    backgroundColor: const Color(0xFFFFECB3), // Light amber chip background
    labelStyle: const TextStyle(color: Color(0xFF5D4037)),
    side: BorderSide.none,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
);
