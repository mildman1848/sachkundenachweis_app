// lib/theme/theme_notifier.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode {
  system,
  calmNature,
  brightMinimal,
  darkElegant,
}

class ThemeNotifier extends ChangeNotifier {
  AppThemeMode _themeMode = AppThemeMode.system;

  AppThemeMode get themeMode => _themeMode;

  set themeMode(AppThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      _saveThemeMode();
      notifyListeners();
    }
  }

  // Für MaterialApp
  ThemeMode get materialThemeMode {
    switch (_themeMode) {
      case AppThemeMode.system:
        return ThemeMode.system;
      case AppThemeMode.calmNature:
      case AppThemeMode.brightMinimal:
      case AppThemeMode.darkElegant:
        // User-spezifisch: Wir liefern das eigentliche Theme später per getThemeData, daher immer light nehmen (ansonsten wird das Theme überschrieben).
        return ThemeMode.light;
    }
  }

  /// Holt das passende ThemeData – je nach Theme-Auswahl und Brightness
  ThemeData getThemeData(Brightness platformBrightness) {
    switch (_themeMode) {
      case AppThemeMode.calmNature:
        return platformBrightness == Brightness.dark
            ? AppThemes.calmNatureDark
            : AppThemes.calmNatureLight;
      case AppThemeMode.brightMinimal:
        return platformBrightness == Brightness.dark
            ? AppThemes.brightMinimalDark
            : AppThemes.brightMinimalLight;
      case AppThemeMode.darkElegant:
        return platformBrightness == Brightness.dark
            ? AppThemes.darkElegantDark
            : AppThemes.darkElegantLight;
      case AppThemeMode.system:
        // System-Theme: Immer das passende CalmNature-Theme nehmen (das ist das Default-Design)
        return platformBrightness == Brightness.dark
            ? AppThemes.calmNatureDark
            : AppThemes.calmNatureLight;
    }
  }

  /// Initialisiert das gespeicherte Theme beim Start der App
  Future<void> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getInt('theme_mode');
    if (value != null && value >= 0 && value < AppThemeMode.values.length) {
      _themeMode = AppThemeMode.values[value];
    } else {
      _themeMode = AppThemeMode.system;
    }
    notifyListeners();
  }

  /// Speichert die Theme-Auswahl persistent
  Future<void> _saveThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', _themeMode.index);
  }
}

// ---------- Themes ----------
class AppThemes {
  // Calm Nature – Light
  static final ThemeData calmNatureLight = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF388E3C),
    scaffoldBackgroundColor: const Color(0xFFFFF8E1),
    cardColor: Colors.white,
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF388E3C),
      secondary: Color(0xFFA5D6A7),
      surface: Color(0xFFFFF8E1),
    ),
    fontFamily: 'Montserrat',
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF388E3C),
      foregroundColor: Colors.white,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF388E3C),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: Color(0xFF388E3C),
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.white,
    ),
  );

  // Calm Nature – Dark
  static final ThemeData calmNatureDark = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF29602E),
    scaffoldBackgroundColor: const Color(0xFF1B1B1B),
    cardColor: const Color(0xFF23272A),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF66BB6A),
      secondary: Color(0xFFA5D6A7),
      surface: Color(0xFF23272A),
    ),
    fontFamily: 'Montserrat',
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF29602E),
      foregroundColor: Colors.white,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF388E3C),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: Color(0xFF66BB6A),
      unselectedItemColor: Colors.white70,
      backgroundColor: Color(0xFF23272A),
    ),
  );

  // Bright Minimal – Light
  static final ThemeData brightMinimalLight = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF00B8D4),
    scaffoldBackgroundColor: Colors.white,
    cardColor: Colors.white,
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF00B8D4),
      secondary: Color(0xFFFFB300),
      surface: Colors.white,
      tertiary: Color(0xFFD1C4E9),
    ),
    fontFamily: 'Inter',
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF00B8D4),
      foregroundColor: Colors.white,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF00B8D4),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: Color(0xFF00B8D4),
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.white,
    ),
  );

  // Bright Minimal – Dark
  static final ThemeData brightMinimalDark = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF0097A7),
    scaffoldBackgroundColor: const Color(0xFF181A20),
    cardColor: const Color(0xFF23272A),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF00B8D4),
      secondary: Color(0xFFFFB300),
      surface: Color(0xFF23272A),
      tertiary: Color(0xFFD1C4E9),
    ),
    fontFamily: 'Inter',
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0097A7),
      foregroundColor: Colors.white,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF00B8D4),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: Color(0xFF00B8D4),
      unselectedItemColor: Colors.white70,
      backgroundColor: Color(0xFF23272A),
    ),
  );

  // Dark Elegant – Light
  static final ThemeData darkElegantLight = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF23272A),
    scaffoldBackgroundColor: const Color(0xFFF5F6FA),
    cardColor: Colors.white,
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF23272A),
      secondary: Color(0xFF1ABC9C),
      surface: Color(0xFFF5F6FA),
      tertiary: Color(0xFF00E676),
      error: Color(0xFFFFD600),
    ),
    fontFamily: 'Nunito',
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF23272A),
      foregroundColor: Colors.white,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF1ABC9C),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: Color(0xFF1ABC9C),
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.white,
    ),
  );

  // Dark Elegant – Dark
  static final ThemeData darkElegantDark = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF23272A),
    scaffoldBackgroundColor: const Color(0xFF181A20),
    cardColor: const Color(0xFF23272A),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF1ABC9C),
      secondary: Color(0xFF00E676),
      surface: Color(0xFF181A20),
      tertiary: Color(0xFFFFD600),
      error: Color(0xFFFFD600),
    ),
    fontFamily: 'Nunito',
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF23272A),
      foregroundColor: Colors.white,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF1ABC9C),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: Color(0xFF00E676),
      unselectedItemColor: Colors.white70,
      backgroundColor: Color(0xFF23272A),
    ),
  );
}
