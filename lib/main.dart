// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/theme_notifier.dart';
import 'screens/dashboard_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeNotifier = ThemeNotifier();
  await themeNotifier.loadThemeMode();
  runApp(
    ChangeNotifierProvider<ThemeNotifier>.value(
      value: themeNotifier,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return MaterialApp(
      title: 'Sachkundenachweis',
      debugShowCheckedModeBanner: false,
      theme: AppThemes.calmNatureLight,
      darkTheme: AppThemes.calmNatureDark,
      themeMode: themeNotifier.materialThemeMode,
      home: const MainNavigation(),
      builder: (context, child) {
        final brightness = MediaQuery.platformBrightnessOf(context);
        final themeData = themeNotifier.getThemeData(
          themeNotifier.themeMode == AppThemeMode.system
              ? brightness
              : Brightness.light,
        );
        return Theme(
          data: themeData,
          child: child!,
        );
      },
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});
  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  final _dashboard = const DashboardScreen();
  final _settings = const SettingsScreen();

  Widget? _currentQuizScreen;
  bool _quizLoading = false;

  Future<void> _loadQuizScreen() async {
    setState(() {
      _quizLoading = true;
    });
    // Kein Shuffling mehr hier nötig! QuizScreen erledigt das selbst.
    setState(() {
      _currentQuizScreen = const QuizScreen();
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
        // Wenn noch nie geöffnet: Lade QuizScreen
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
            // QuizTab: immer neu laden!
            await _loadQuizScreen();
            setState(() {
              _selectedIndex = idx;
            });
          } else {
            setState(() {
              _selectedIndex = idx;
            });
          }
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
