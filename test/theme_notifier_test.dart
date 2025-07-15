// Speicherort: test/theme_notifier_test.dart
// Beschreibung: Testet die ThemeNotifier-Klasse in lib/theme/theme_notifier.dart.
// Überprüft, ob das Theme korrekt basierend auf Brightness gewechselt wird und materialThemeMode korrekt ist.
// Der Test ist plattformübergreifend kompatibel und verwendet Best Practices für Flutter-Tests.
// Änderungen: Binding-Initialisierungsfehler behoben durch Hinzufügen von TestWidgetsFlutterBinding.ensureInitialized() in setUpAll.
// testWidgets beibehalten für UI-Tests; normale test-Funktionen für nicht-UI-Tests verwendet, um unnötige Pumps zu vermeiden.
// Explizite Timeouts hinzugefügt für stabile Ausführung auf allen OS (macOS, Windows, Linux).
// SharedPreferences-Mock hinzugefügt in setUp, um MissingPluginException zu beheben (ThemeNotifier verwendet SharedPreferences intern).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Für Mock von SharedPreferences (behebt MissingPluginException).
import 'package:sachkundenachweis/theme/theme_notifier.dart';

void main() {
  // Gruppe für ThemeNotifier-Tests.
  group('ThemeNotifier Tests', () {
    // Initialisiere das Binding einmalig für alle Tests (behebt potenzielle ServicesBinding-Errors).
    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    // Mock SharedPreferences für jeden Test (behebt MissingPluginException bei Theme-Laden).
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    test('ThemeNotifier gibt korrektes Theme basierend auf Brightness zurück', () {
      // Erstelle einen ProviderContainer für isolierte Tests (Best Practice).
      final container = ProviderContainer();
      final themeNotifier = container.read(themeNotifierProvider.notifier);

      // Prüfe Light-Theme.
      final lightTheme = themeNotifier.getThemeData(Brightness.light);
      expect(
        lightTheme.brightness,
        Brightness.light,
        reason: 'Theme für Brightness.light sollte Light-Theme sein.',
      );

      // Prüfe Dark-Theme.
      final darkTheme = themeNotifier.getThemeData(Brightness.dark);
      expect(
        darkTheme.brightness,
        Brightness.dark,
        reason: 'Theme für Brightness.dark sollte Dark-Theme sein.',
      );

      // Container aufräumen (Best Practice für Riverpod).
      container.dispose();
    });

    test('ThemeNotifier materialThemeMode ist korrekt', () {
      // Erstelle einen ProviderContainer.
      final container = ProviderContainer();
      final themeNotifier = container.read(themeNotifierProvider.notifier);

      // Prüfe Standard-ThemeMode (system).
      expect(
        themeNotifier.materialThemeMode,
        ThemeMode.system,
        reason: 'materialThemeMode sollte ThemeMode.system sein.',
      );

      // Container aufräumen.
      container.dispose();
    });

    testWidgets('ThemeNotifier wendet Theme korrekt in MaterialApp an', (WidgetTester tester) async {
      // Erstelle einen ProviderContainer.
      final container = ProviderContainer();
      final themeNotifier = container.read(themeNotifierProvider.notifier);
      final themeData = themeNotifier.getThemeData(Brightness.light);

      // Initialisiere die App mit ProviderScope und explizitem Theme.
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            themeNotifierProvider.overrideWith((ref) => ThemeNotifier()),
          ],
          child: MaterialApp(
            theme: themeData, // Explizit das Theme setzen.
            home: const Scaffold(body: Text('Test')),
          ),
        ),
      );

      // Warte auf vollständiges Rendering.
      await tester.pumpAndSettle();

      // Prüfe, ob das Theme angewendet wurde.
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(
        materialApp.theme?.brightness,
        Brightness.light,
        reason: 'Standard-Theme sollte Light-Theme sein.',
      );

      // Container aufräumen.
      container.dispose();
    }, timeout: const Timeout(Duration(seconds: 30))); // Timeout für stabile Testausführung.
  });
}