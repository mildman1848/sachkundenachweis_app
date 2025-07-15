// Speicherort: test/questions_logic_test.dart
// Beschreibung: Testet die logische Integrität der Fragen in lib/data/questions.dart.
// Überprüft, ob die Fragenliste nicht leer ist, jede Frage mindestens eine richtige Antwort hat und jeder Frage mindestens eine Kategorie zugeordnet ist.
// Der Test ist plattformübergreifend kompatibel und verwendet Best Practices für Flutter-Tests.

import 'package:flutter/material.dart'; // Für SizedBox (behebt Undefined name 'SizedBox').
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Für Provider-Tests.
import 'package:sachkundenachweis/data/questions.dart'; // Fragen-Datenquelle importieren.
import 'package:sachkundenachweis/data/question_categories.dart'; // Kategorien-Datenquelle importieren.


void main() {
  // Gruppe für Tests der Fallback-Liste (const questionsFallback).
  group('Logische Integrität der Fallback-Fragen (questionsFallback)', () {
    test('Fragenliste enthält mindestens eine Frage', () {
      expect(
        questionsFallback.length,
        greaterThan(0),
        reason: 'Die Fallback-Fragenliste ist leer.',
      );
    });

    test('Alle Fragen haben mindestens eine richtige Antwort', () {
      for (final q in questionsFallback) {
        expect(
          q.correctAnswers.isNotEmpty,
          true,
          reason: 'Frage ${q.id} (${q.question}) hat keine richtige Antwort.',
        );
      }
    });

    test('Jede Frage ist mindestens einer Kategorie zugeordnet', () {
      // Prüfe für jede Frage, ob sie in questionCategories irgendwo vorkommt.
      for (final q in questionsFallback) {
        final found = questionCategories.values.any((ids) => ids.contains(q.id));
        expect(
          found,
          true,
          reason: 'Frage ${q.id} (${q.question}) ist keiner Kategorie zugeordnet.',
        );
      }
    });
  });

  // Gruppe für Tests des questionsProvider (JSON-basierte Fragen).
  group('Logische Integrität der JSON-Fragen (questionsProvider)', () {
    testWidgets('Fragenliste enthält mindestens eine Frage', (WidgetTester tester) async {
      // ProviderScope für Riverpod-Tests initialisieren (Best Practice).
      await tester.pumpWidget(
        const ProviderScope(
          child: SizedBox.shrink(), // Dummy-Widget mit const für Performance.
        ),
      );
      await tester.pumpAndSettle(); // Warte auf vollständiges Rendering.

      // Fragen aus dem FutureProvider laden.
      final container = ProviderContainer();
      final questions = await container.read(questionsProvider.future);

      expect(
        questions.length,
        greaterThan(0),
        reason: 'Die JSON-Fragenliste ist leer.',
      );

      // Container aufräumen (Best Practice für Riverpod).
      container.dispose();
    });

    testWidgets('Alle Fragen haben mindestens eine richtige Antwort', (WidgetTester tester) async {
      // ProviderScope für Riverpod-Tests initialisieren.
      await tester.pumpWidget(
        const ProviderScope(
          child: SizedBox.shrink(), // Dummy-Widget mit const für Performance.
        ),
      );
      await tester.pumpAndSettle();

      // Fragen aus dem FutureProvider laden.
      final container = ProviderContainer();
      final questions = await container.read(questionsProvider.future);

      for (final q in questions) {
        expect(
          q.correctAnswers.isNotEmpty,
          true,
          reason: 'Frage ${q.id} (${q.question}) hat keine richtige Antwort.',
        );
      }

      // Container aufräumen.
      container.dispose();
    });

    testWidgets('Jede Frage ist mindestens einer Kategorie zugeordnet', (WidgetTester tester) async {
      // ProviderScope für Riverpod-Tests initialisieren.
      await tester.pumpWidget(
        const ProviderScope(
          child: SizedBox.shrink(), // Dummy-Widget mit const für Performance.
        ),
      );
      await tester.pumpAndSettle();

      // Fragen aus dem FutureProvider laden.
      final container = ProviderContainer();
      final questions = await container.read(questionsProvider.future);

      // Prüfe für jede Frage, ob sie in questionCategories irgendwo vorkommt.
      for (final q in questions) {
        final found = questionCategories.values.any((ids) => ids.contains(q.id));
        expect(
          found,
          true,
          reason: 'Frage ${q.id} (${q.question}) ist keiner Kategorie zugeordnet.',
        );
      }

      // Container aufräumen.
      container.dispose();
    });
  });
}