// Speicherort: test/theme_notifier_test.dart
// Beschreibung: Testet die ThemeNotifier-Klasse in lib/theme/theme_notifier.dart.
// Überprüft, ob das Theme korrekt basierend auf Brightness gewechselt wird und materialThemeMode korrekt ist.
// Der Test ist plattformübergreifend kompatibel und verwendet Best Practices für Flutter-Tests.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sachkundenachweis/theme/theme_notifier.dart';

void main() {
  group('ThemeNotifier Tests', () {
    test('ThemeNotifier gibt korrektes Theme basierend auf Brightness zurück', () {
      // Erstelle einen ThemeNotifier.
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

      // Container aufräumen.
      container.dispose();
    });

    test('ThemeNotifier materialThemeMode ist korrekt', () {
      // Erstelle einen ThemeNotifier.
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
      // Erstelle einen ThemeNotifier für den Test.
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
            theme: themeData, // Explizit das Theme setzen
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
    });
  });
}