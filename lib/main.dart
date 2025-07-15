// Speicherort: lib/main.dart
// Beschreibung: Haupteinstiegspunkt der Sachkundenachweis-App.
// Diese Datei definiert die Hauptfunktion und die Navigation der App mit Riverpod für State-Management.
// Der Code ist plattformübergreifend kompatibel (iOS, Android, Web) und folgt Best Practices für Flutter.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Korrigierter Import für Flutter-Riverpod.
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb; // Für Debugging und Web-Checks (Cross-OS).
import 'dart:io' show Platform; // Plattform-spezifische Anpassungen (Cross-OS).

import 'theme/theme_notifier.dart'; // Theme-Management importieren.
import 'screens/dashboard_screen.dart'; // Dashboard-Screen importieren.
import 'screens/quiz_screen.dart'; // Quiz-Screen importieren.
import 'screens/settings_screen.dart'; // Settings-Screen importieren.

// Hauptfunktion, die die App startet.
/// Initialisiert die App und konfiguriert Error-Handling sowie plattformspezifische UI-Modi.
/// Startet die App mit ProviderScope für Riverpod.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Error-Handling initialisieren (Best Practice für stabile App auf allen OS).
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    if (kDebugMode) {
      // Logging statt print für Production (behebt Lint-Warnung).
      debugPrint(details.toString());
    }
  };

  // Android-spezifisch: immersive Sticky Vollbild (Cross-OS: Nur auf Android anwenden).
  if (Platform.isAndroid && !kIsWeb) {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  // App mit ProviderScope für Riverpod starten (Best Practice für State).
  runApp(const ProviderScope(child: MyApp()));
}

// Haupt-Widget der App.
/// ConsumerWidget für Riverpod-Zugriff, verwendet Theme-Notifier für dynamisches Theme.
/// @param context Der BuildContext für das Rendering.
/// @param ref Der WidgetRef für Riverpod-Zugriff.
/// @return Widget Die MaterialApp mit Navigation und Theme.
class MyApp extends ConsumerWidget {
  const MyApp({super.key}); // Key-Parameter hinzugefügt (behebt Konstruktor-Warnung).

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Theme-Notifier holen (behebt 'getThemeData' und 'materialThemeMode' nicht definiert).
    final themeNotifier = ref.watch(themeNotifierProvider.notifier);
    final brightness = MediaQuery.platformBrightnessOf(context); // Brightness für getThemeData.
    final currentTheme = themeNotifier.getThemeData(brightness); // Aktuelles Theme basierend auf Brightness.
    final darkTheme = themeNotifier.getThemeData(Brightness.dark); // Dark-Theme separat für MaterialApp.

    // Plattform-Check für Cross-OS-Anpassungen (z.B. keine Android-spezifischen UI-Modes auf iOS/Web).
    if (Platform.isIOS || kIsWeb) {
      // iOS/Web-Optimierungen, z.B. Brightness.system statt immersiveSticky.
    }

    return MaterialApp(
      title: 'Sachkundenachweis',
      debugShowCheckedModeBanner: false,
      theme: currentTheme, // Aktuelles Theme.
      darkTheme: darkTheme, // Dark Mode.
      themeMode: themeNotifier.materialThemeMode, // System- oder manuell (Cross-OS Sync).
      home: const MainNavigation(), // Start-Screen mit Navigation.
      // Accessibility: Semantics für Screen-Reader (Best Practice für Inklusion).
      builder: (context, child) => Semantics(child: child),
    );
  }
}

// Haupt-Navigations-Widget.
/// ConsumerStatefulWidget für Riverpod-Zugriff und State-Management der Navigation.
/// Verwaltet BottomNavigationBar und lädt Screens dynamisch.
class MainNavigation extends ConsumerStatefulWidget {
  const MainNavigation({super.key}); // Key-Parameter hinzugefügt.

  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends ConsumerState<MainNavigation> {
  int _selectedIndex = 0;
  final _dashboard = const DashboardScreen();
  final _settings = const SettingsScreen();
  Widget? _currentQuizScreen;
  bool _quizLoading = false;

  /// Lädt den Quiz-Screen asynchron und aktualisiert den State.
  Future<void> _loadQuizScreen() async {
    setState(() {
      _quizLoading = true;
    });

    _currentQuizScreen = const QuizScreen();

    setState(() {
      _quizLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _currentQuizScreen = null;
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (_selectedIndex == 0) {
      content = _dashboard;
    } else if (_selectedIndex == 1) {
      if (_quizLoading) {
        content = const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      } else if (_currentQuizScreen != null) {
        content = _currentQuizScreen!;
      } else {
        _loadQuizScreen();
        content = const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }
    } else {
      content = _settings;
    }

    return Scaffold(
      body: content,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (idx) async {
          if (idx == 1) {
            await _loadQuizScreen();
          }
          setState(() {
            _selectedIndex = idx;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.quiz), label: 'Quiz'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Einstellungen'),
        ],
      ),
    );
  }
}