import 'package:flutter/material.dart';

abstract final class ArenaColors {
  static const background = Color(0xFF070D1C);
  static const surface = Color(0xFF101A31);
  static const surfaceRaised = Color(0xFF152341);
  static const border = Color(0xFF26395B);
  static const primary = Color(0xFF3C9EFF);
  static const cyan = Color(0xFF49DDF5);
  static const purple = Color(0xFF9675FF);
  static const playerTwo = Color(0xFFC185FF);
  static const success = Color(0xFF63DDA8);
  static const gold = Color(0xFFFFD36E);
  static const textMuted = Color(0xFF9BAAC5);
}

abstract final class ArenaRadii {
  static const card = 20.0;
  static const panel = 16.0;
  static const control = 13.0;
}

abstract final class ArenaSpace {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
}

ThemeData buildArenaTheme() => ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: ArenaColors.background,
  fontFamily: 'Avenir Next',
  colorScheme: const ColorScheme.dark(
    primary: ArenaColors.primary,
    secondary: ArenaColors.purple,
    surface: ArenaColors.surface,
    error: Color(0xFFFF718C),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: ArenaColors.background,
    foregroundColor: Colors.white,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: ArenaColors.surface,
    labelStyle: const TextStyle(color: ArenaColors.textMuted),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(ArenaRadii.control),
      borderSide: const BorderSide(color: ArenaColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(ArenaRadii.control),
      borderSide: const BorderSide(color: ArenaColors.cyan, width: 1.5),
    ),
  ),
);
