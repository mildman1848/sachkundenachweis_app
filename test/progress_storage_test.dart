// Speicherort: test/progress_storage_test.dart
// Beschreibung: Testet die Funktionalität der ProgressStorage-Klasse in lib/storage/progress_storage.dart.
// Überprüft, ob Antwortverläufe korrekt gespeichert werden, nur die letzten drei Antworten getrackt werden, isLearned bei dreimal korrekt funktioniert und Edge-Cases korrekt behandelt werden.
// Der Test ist plattformübergreifend kompatibel und verwendet Best Practices für Flutter-Tests.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Für Mock von SharedPreferences.
import 'package:sachkundenachweis/storage/progress_storage.dart'; // ProgressStorage-Klasse importieren.

void main() {
  // Initialisiert das Flutter Binding (notwendig für SharedPreferences im Test).
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // Setzt einen leeren Speicher (Mock) für jeden Testlauf.
    SharedPreferences.setMockInitialValues({});
  });

  group('ProgressStorage Tests', () {
    test('addAnswerResult trackt nur die letzten 3 Antworten und isLearned erkennt 3x korrekt', () async {
      const questionId = 42;

      // Starte frisch.
      await ProgressStorage.resetProgress(questionId);

      // Weniger als 3 mal korrekt -> nicht gelernt.
      await ProgressStorage.addAnswerResult(questionId, true);
      await ProgressStorage.addAnswerResult(questionId, false);
      await ProgressStorage.addAnswerResult(questionId, true);
      var results = await ProgressStorage.getLastThreeResults(questionId);
      expect(results, [true, false, true], reason: 'Erwartete Ergebnisse: [true, false, true]');
      var learned = await ProgressStorage.isLearned(questionId);
      expect(learned, false, reason: 'Frage sollte nicht als gelernt markiert sein.');

      // 3 mal in Folge richtig -> gelernt.
      await ProgressStorage.addAnswerResult(questionId, true);
      results = await ProgressStorage.getLastThreeResults(questionId);
      expect(results, [true, true, false], reason: 'Erwartete Ergebnisse: [true, true, false]');
      await ProgressStorage.addAnswerResult(questionId, true);
      await ProgressStorage.addAnswerResult(questionId, true);
      results = await ProgressStorage.getLastThreeResults(questionId);
      expect(results, [true, true, true], reason: 'Erwartete Ergebnisse: [true, true, true]');
      learned = await ProgressStorage.isLearned(questionId);
      expect(learned, true, reason: 'Frage sollte als gelernt markiert sein.');

      // Reset löscht alles.
      await ProgressStorage.resetProgress(questionId);
      results = await ProgressStorage.getLastThreeResults(questionId);
      expect(results, [], reason: 'Ergebnisse sollten nach Reset leer sein.');
    });

    test('ProgressStorage handhabt mehrere Fragen korrekt', () async {
      const questionId1 = 42;
      const questionId2 = 43;

      // Starte frisch für beide Fragen.
      await ProgressStorage.resetProgress(questionId1);
      await ProgressStorage.resetProgress(questionId2);

      // Füge Antworten für beide Fragen hinzu.
      await ProgressStorage.addAnswerResult(questionId1, true);
      await ProgressStorage.addAnswerResult(questionId1, true);
      await ProgressStorage.addAnswerResult(questionId2, false);

      // Prüfe Ergebnisse für questionId1.
      var results1 = await ProgressStorage.getLastThreeResults(questionId1);
      expect(results1, [true, true], reason: 'Erwartete Ergebnisse für ID 42: [true, true]');

      // Prüfe Ergebnisse für questionId2.
      var results2 = await ProgressStorage.getLastThreeResults(questionId2);
      expect(results2, [false], reason: 'Erwartete Ergebnisse für ID 43: [false]');

      // Prüfe isLearned für beide Fragen.
      var learned1 = await ProgressStorage.isLearned(questionId1);
      expect(learned1, false, reason: 'Frage 42 sollte nicht als gelernt markiert sein.');
      var learned2 = await ProgressStorage.isLearned(questionId2);
      expect(learned2, false, reason: 'Frage 43 sollte nicht als gelernt markiert sein.');
    });
  });
}