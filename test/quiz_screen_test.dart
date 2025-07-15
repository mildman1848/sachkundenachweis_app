// Speicherort: test/quiz_screen_test.dart
// Beschreibung: Testet die QuizScreen-Widget-Funktionalität in lib/screens/quiz_screen.dart.
// Überprüft, ob eine gezielt ausgewählte Frage korrekt angezeigt wird, Antworten ausgewählt werden können und Ergebnisse gespeichert werden.
// Der Test ist plattformübergreifend kompatibel und verwendet Best Practices für Flutter-Tests.
// Änderungen: Binding-Initialisierungsfehler behoben durch Hinzufügen von TestWidgetsFlutterBinding.ensureInitialized() in setUpAll.
// Explizite Timeouts für pumpAndSettle und gesamte Tests hinzugefügt für stabile Ausführung auf allen OS (macOS, Windows, Linux).
// Debug-Ausgaben verbessert und Fehlersuche erleichtert; Keine unnötigen Widget-Pumps.
// Predicate für Checkbox-Markierung angepasst: Sucht nun nach ListTile mit Checkbox (value == true), da der Code ListTile statt CheckboxListTile verwendet.
// Button-Finder korrigiert: Sucht nun nach 'Antwort prüfen' statt 'Absenden', da dies der korrekte initiale Button-Text ist (behebt TestFailure).
// Test-Logik angepasst: Tapp alle Antworten in Schleife, prüfe Markierung danach (vermeidet De-Selektion durch doppeltes Tappen).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sachkundenachweis/data/questions.dart'; // Fragen-Datenquelle importieren.
import 'package:sachkundenachweis/models/question_model.dart'; // Question-Model importieren.
import 'package:sachkundenachweis/screens/quiz_screen.dart'; // QuizScreen importieren.
import 'package:sachkundenachweis/storage/progress_storage.dart'; // Für Ergebnisspeicherung
import 'package:sachkundenachweis/theme/theme_notifier.dart'; // ThemeNotifier importieren.
import 'package:shared_preferences/shared_preferences.dart'; // Für Mock von SharedPreferences

void main() {
  // Gruppe für QuizScreen-Tests.
  group('QuizScreen Tests', () {
    // Initialisiere das Binding einmalig für alle Tests (behebt ServicesBinding-Errors).
    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    // Initialisiere SharedPreferences Mock für ProgressStorage in jedem Test.
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('QuizScreen zeigt gezielt ausgewählte Frage korrekt an', (WidgetTester tester) async {
      // Mock für questionsProvider, um asynchrones Laden zu kontrollieren.
      const mockQuestion = Question(
        id: 1,
        question: 'Was sind typische Jagdverhaltensweisen?',
        answers: [
          'Suchen nach Beute.',
          'Hetzen.',
          'Schütteln der Beute.',
          'Anschleichen und Vorstehen.',
        ],
        correctAnswers: [0, 1, 2, 3],
      );

      // Initialisiere die App mit ProviderScope und Mock für questionsProvider.
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // Mock questionsProvider, um die Frage direkt bereitzustellen.
            questionsProvider.overrideWith((ref) => Future.value([mockQuestion])),
            // Override für ThemeNotifier, um konsistentes Theme zu gewährleisten.
            themeNotifierProvider.overrideWith((ref) => ThemeNotifier()),
          ],
          child: MaterialApp(
            home: QuizScreen(singleQuestionId: mockQuestion.id),
          ),
        ),
      );

      // Warte auf vollständiges Rendering mit explizitem Timeout.
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Fragetext prüfen.
      expect(
        find.textContaining(mockQuestion.question),
        findsOneWidget,
        reason: 'Fragetext "${mockQuestion.question}" wurde nicht gefunden.',
      );

      // Antworten prüfen.
      for (final answer in mockQuestion.answers) {
        expect(
          find.text(answer),
          findsOneWidget,
          reason: 'Antwort "$answer" wurde nicht gefunden.',
        );
      }
    }, timeout: const Timeout(Duration(seconds: 60))); // Erhöht für stabile Ausführung.

    testWidgets('QuizScreen erlaubt Antwortauswahl und speichert Ergebnis', (WidgetTester tester) async {
      // Mock für questionsProvider.
      const mockQuestion = Question(
        id: 1,
        question: 'Was sind typische Jagdverhaltensweisen?',
        answers: [
          'Suchen nach Beute.',
          'Hetzen.',
          'Schütteln der Beute.',
          'Anschleichen und Vorstehen.',
        ],
        correctAnswers: [0, 1, 2, 3],
      );

      // Initialisiere die App mit ProviderScope.
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            questionsProvider.overrideWith((ref) => Future.value([mockQuestion])),
            themeNotifierProvider.overrideWith((ref) => ThemeNotifier()),
          ],
          child: MaterialApp(
            home: QuizScreen(singleQuestionId: mockQuestion.id),
          ),
        ),
      );

      // Warte auf vollständiges Rendering.
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Simuliere das Auswählen aller richtigen Antworten in einer Schleife (kein doppeltes Tappen).
      for (final answer in mockQuestion.answers) {
        final answerFinder = find.text(answer);
        if (answerFinder.evaluate().isNotEmpty) {
          await tester.tap(answerFinder);
          await tester.pump();
        } else {
          fail('Antwort "$answer" nicht gefunden. Überprüfen Sie die QuizScreen-Implementierung.');
        }
      }
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Prüfe, ob eine Auswahl visuell markiert ist (z.B. die erste: ListTile mit Checkbox value == true).
      final listTileFinder = find.byWidgetPredicate(
        (widget) =>
            widget is ListTile &&
            widget.leading is Padding &&
            (widget.leading as Padding).child is Checkbox &&
            ((widget.leading as Padding).child as Checkbox).value == true &&
            widget.title is Text &&
            (widget.title as Text).data == 'Suchen nach Beute.',
      );
      expect(
        listTileFinder,
        findsOneWidget,
        reason: 'Ausgewählte Antwort sollte markiert sein. Gefundene Widgets: ${tester.widgetList(find.byType(ListTile)).length}',
      );

      // Simuliere das Absenden der Antworten (korrekter Text: 'Antwort prüfen').
      final submitButton = find.text('Antwort prüfen');
      if (submitButton.evaluate().isNotEmpty) {
        await tester.tap(submitButton);
        await tester.pumpAndSettle(const Duration(seconds: 10));

        // Prüfe, ob das Ergebnis in ProgressStorage gespeichert wurde.
        final results = await ProgressStorage.getLastThreeResults(mockQuestion.id);
        expect(
          results,
          contains(true),
          reason: 'ProgressStorage sollte die korrekte Antwort speichern. Aktuelle Results: $results',
        );
      } else {
        fail('"Antwort prüfen"-Button nicht gefunden. Überprüfen Sie die QuizScreen-Implementierung.');
      }
    }, timeout: const Timeout(Duration(seconds: 60))); // Erhöht für stabile Ausführung.
  });
}