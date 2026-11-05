import 'package:flutter/material.dart';

const brandRed = Color(0xFFC51D2A);
const brandBrown = Color(0xFF45180D);
const warmSurface = Color(0xFFFFFCFA);
const softBackground = Color(0xFFF6EAE5);
ThemeData buildTheme() => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(seedColor: brandRed).copyWith(
    primary: brandRed,
    secondary: brandBrown,
    surface: warmSurface,
    onSurface: brandBrown,
    outline: const Color(0xFFB88770),
  ),
  scaffoldBackgroundColor: warmSurface,
  appBarTheme: const AppBarTheme(
    backgroundColor: warmSurface,
    foregroundColor: brandBrown,
    centerTitle: false,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      minimumSize: const Size(0, 52),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      minimumSize: const Size(0, 52),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  ),
);
