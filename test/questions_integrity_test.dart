// Speicherort: test/questions_integrity_test.dart
// Beschreibung: Testet die Integrität der Fragen in lib/data/questions.dart.
// Überprüft, ob alle 197 Fragen vorhanden sind, keine Duplikate existieren und die IDs lückenlos von 1 bis 197 sind.
// Der Test ist plattformübergreifend kompatibel und verwendet Best Practices für Flutter-Tests.
// Änderungen: Binding-Initialisierungsfehler behoben durch Hinzufügen von TestWidgetsFlutterBinding.ensureInitialized() in setUpAll.
// testWidgets durch normale test-Funktionen ersetzt, da kein UI getestet wird, um unnötige Widget-Pumps zu vermeiden.
// Explizite Timeouts hinzugefügt für stabile Ausführung auf allen OS (macOS, Windows, Linux).

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
    // Initialisiere das Binding einmalig für alle Tests in dieser Gruppe (behebt ServicesBinding-Error).
    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    test('Alle Fragen sind eindeutig, lückenlos und komplett', () async {
      // ProviderContainer für Riverpod-Tests initialisieren (Best Practice).
      final container = ProviderContainer();

      // Fragen aus dem FutureProvider laden, mit Timeout für stabile Ausführung.
      final questions = await container.read(questionsProvider.future).timeout(
        const Duration(seconds: 60), // Timeout für JSON-Ladung (anpassbar bei großen Dateien).
        onTimeout: () => throw Exception('Timeout beim Laden der JSON-Fragen – überprüfe die JSON-Datei oder den Provider.'),
      );

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
    }, timeout: const Timeout(Duration(seconds: 90))); // Gesamter Test-Timeout erhöht für Kompatibilität.
  });
}