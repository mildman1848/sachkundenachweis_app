// Speicherort: test/questions_integrity_test.dart
// Beschreibung: Testet die Integrität der Fragen in lib/data/questions.dart.
// Überprüft, ob alle 197 Fragen vorhanden sind, keine Duplikate existieren und die IDs lückenlos von 1 bis 197 sind.
// Der Test ist plattformübergreifend kompatibel und verwendet Best Practices für Flutter-Tests.

import 'package:flutter/material.dart'; // Für SizedBox (behebt Undefined name 'SizedBox').
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Für Provider-Tests.
import 'package:sachkundenachweis/data/questions.dart'; // Fragen-Datenquelle importieren.

void main() {
  // Gruppe für Tests der Fallback-Liste (const questionsFallback).
  group('Integrität der Fallback-Fragen (questionsFallback)', () {
    test('Alle Fragen sind eindeutig, lückenlos und komplett', () {
      // IDs aus der statischen Fallback-Liste extrahieren.
      final ids = questionsFallback.map((q) => q.id).toList();

      // Test auf Duplikate.
      final doppel = ids.where((id) => ids.where((i) => i == id).length > 1).toSet();
      expect(doppel.isEmpty, true, reason: 'Doppelte IDs: ${doppel.join(", ")}');

      // Test auf Lücken und ungültige IDs.
      final expected = List.generate(197, (i) => i + 1).toSet(); // Konstante Menge für erwartete IDs (1 bis 197).
      final vorhanden = ids.toSet();
      final fehlend = expected.difference(vorhanden);
      final zuviel = vorhanden.difference(expected);

      expect(fehlend.isEmpty, true, reason: 'Fehlende IDs: ${fehlend.join(", ")}');
      expect(zuviel.isEmpty, true, reason: 'IDs außerhalb von 1–197: ${zuviel.join(", ")}');
      expect(questionsFallback.length, 197, reason: 'Fragenanzahl stimmt nicht: ${questionsFallback.length}/197');
    });
  });

  // Gruppe für Tests des questionsProvider (JSON-basierte Fragen).
  group('Integrität der JSON-Fragen (questionsProvider)', () {
    testWidgets('Alle Fragen sind eindeutig, lückenlos und komplett', (WidgetTester tester) async {
      // ProviderScope für Riverpod-Tests initialisieren (Best Practice).
      await tester.pumpWidget(
        const ProviderScope(
          child: SizedBox.shrink(), // Dummy-Widget für Testumgebung.
        ),
      );

      // Fragen aus dem FutureProvider laden.
      final container = ProviderContainer();
      final questions = await container.read(questionsProvider.future);

      // IDs aus der JSON-Liste extrahieren.
      final ids = questions.map((q) => q.id).toList();

      // Test auf Duplikate.
      final doppel = ids.where((id) => ids.where((i) => i == id).length > 1).toSet();
      expect(doppel.isEmpty, true, reason: 'Doppelte IDs: ${doppel.join(", ")}');

      // Test auf Lücken und ungültige IDs.
      final expected = List.generate(197, (i) => i + 1).toSet(); // Konstante Menge für erwartete IDs (1 bis 197).
      final vorhanden = ids.toSet();
      final fehlend = expected.difference(vorhanden);
      final zuviel = vorhanden.difference(expected);

      expect(fehlend.isEmpty, true, reason: 'Fehlende IDs: ${fehlend.join(", ")}');
      expect(zuviel.isEmpty, true, reason: 'IDs außerhalb von 1–197: ${zuviel.join(", ")}');
      expect(questions.length, 197, reason: 'Fragenanzahl stimmt nicht: ${questions.length}/197');

      // Container aufräumen (Best Practice für Riverpod).
      container.dispose();
    });
  });
}