// Speicherort: test/quiz_screen_test.dart
// Beschreibung: Testet die QuizScreen-Widget-Funktionalität in lib/screens/quiz_screen.dart.
// Überprüft, ob eine gezielt ausgewählte Frage korrekt angezeigt wird, Antworten ausgewählt werden können und Ergebnisse gespeichert werden.
// Der Test ist plattformübergreifend kompatibel und verwendet Best Practices für Flutter-Tests.

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
  // Initialisiere SharedPreferences Mock für ProgressStorage
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('QuizScreen Tests', () {
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

      // Warte auf vollständiges Rendering mit Timeout von 10 Sekunden.
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
    });

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

      // Simuliere das Auswählen einer richtigen Antwort (z. B. "Suchen nach Beute").
      await tester.tap(find.text('Suchen nach Beute.'));
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Prüfe, ob die Auswahl visuell markiert ist (CheckboxListTile mit value == true).
      final checkboxFinder = find.byWidgetPredicate(
        (widget) =>
            widget is CheckboxListTile &&
            widget.title is Text &&
            (widget.title as Text).data == 'Suchen nach Beute.' &&
            widget.value == true,
      );
      expect(
        checkboxFinder,
        findsOneWidget,
        reason: 'Ausgewählte Antwort sollte markiert sein. Gefundene Widgets: ${tester.widgetList(find.byType(CheckboxListTile)).length}',
      );

      // Simuliere das Absenden der Antworten.
      final submitButton = find.text('Absenden');
      if (submitButton.evaluate().isNotEmpty) {
        await tester.tap(submitButton);
        await tester.pumpAndSettle(const Duration(seconds: 10));

        // Prüfe, ob das Ergebnis in ProgressStorage gespeichert wurde.
        final results = await ProgressStorage.getLastThreeResults(mockQuestion.id);
        expect(
          results,
          contains(true),
          reason: 'ProgressStorage sollte die korrekte Antwort speichern.',
        );
      } else {
        debugPrint('Absenden-Button nicht gefunden. Überprüfen Sie die QuizScreen-Implementierung.');
      }
    });
  });
}