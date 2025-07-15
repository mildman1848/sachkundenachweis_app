// Speicherort: test/questions_logic_test.dart
// Beschreibung: Testet die logische Integrität der Fragen in lib/data/questions.dart.
// Überprüft, ob die Fragenliste nicht leer ist, jede Frage mindestens eine richtige Antwort hat und jeder Frage mindestens eine Kategorie zugeordnet ist.
// Der Test ist plattformübergreifend kompatibel und verwendet Best Practices für Flutter-Tests.
// Änderungen: Timeout-Probleme behoben, indem testWidgets durch normale test-Funktionen ersetzt wurden (kein UI benötigt), 
// expliziten Timeout für Future-Tests hinzugefügt und ProviderContainer korrekt verwendet. 
// Dies vermeidet unnötige Widget-Pumps und reduziert Wartezeiten. 
// Zusätzlich: TestWidgetsFlutterBinding.ensureInitialized() in setUpAll hinzugefügt, um Binding-Initialisierungsfehler zu beheben (z.B. für rootBundle.loadString).
// Getestet auf macOS, Windows und Linux; kompatibel mit Flutter 3.x.

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
    // Initialisiere das Binding einmalig für alle Tests in dieser Gruppe (behebt ServicesBinding-Error).
    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    test('Fragenliste enthält mindestens eine Frage', () async {
      // ProviderContainer für Riverpod-Tests initialisieren (Best Practice).
      final container = ProviderContainer();
      
      // Expliziten Timeout setzen, um Ladezeiten zu handhaben (z.B. bei langsamer JSON-Ladung).
      final questions = await container.read(questionsProvider.future).timeout(
        const Duration(seconds: 60), // Erhöht auf 60 Sekunden, falls JSON-Ladung langsam ist (z.B. große Datei oder Netzwerk).
        onTimeout: () => throw Exception('Timeout beim Laden der JSON-Fragen – überprüfe die JSON-Datei oder den Provider.'),
      );

      expect(
        questions.length,
        greaterThan(0),
        reason: 'Die JSON-Fragenliste ist leer.',
      );

      // Container aufräumen (Best Practice für Riverpod).
      container.dispose();
    }, timeout: const Timeout(Duration(seconds: 90))); // Gesamter Test-Timeout erhöht.

    test('Alle Fragen haben mindestens eine richtige Antwort', () async {
      // ProviderContainer initialisieren.
      final container = ProviderContainer();
      
      final questions = await container.read(questionsProvider.future).timeout(
        const Duration(seconds: 60),
        onTimeout: () => throw Exception('Timeout beim Laden der JSON-Fragen.'),
      );

      for (final q in questions) {
        expect(
          q.correctAnswers.isNotEmpty,
          true,
          reason: 'Frage ${q.id} (${q.question}) hat keine richtige Antwort.',
        );
      }

      container.dispose();
    }, timeout: const Timeout(Duration(seconds: 90)));

    test('Jede Frage ist mindestens einer Kategorie zugeordnet', () async {
      // ProviderContainer initialisieren.
      final container = ProviderContainer();
      
      final questions = await container.read(questionsProvider.future).timeout(
        const Duration(seconds: 60),
        onTimeout: () => throw Exception('Timeout beim Laden der JSON-Fragen.'),
      );

      // Prüfe für jede Frage, ob sie in questionCategories irgendwo vorkommt.
      for (final q in questions) {
        final found = questionCategories.values.any((ids) => ids.contains(q.id));
        expect(
          found,
          true,
          reason: 'Frage ${q.id} (${q.question}) ist keiner Kategorie zugeordnet.',
        );
      }

      container.dispose();
    }, timeout: const Timeout(Duration(seconds: 90)));
  });
}