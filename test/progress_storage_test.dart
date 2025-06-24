// test/progress_storage_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sachkundenachweis/storage/progress_storage.dart';

void main() {
  // Initialisiert das Flutter Binding (notwendig für SharedPreferences im Test)
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // Setzt einen leeren Speicher (Mock) für jeden Testlauf
    SharedPreferences.setMockInitialValues({});
  });

  test('addAnswerResult trackt nur die letzten 3 Antworten und isLearned erkennt 3x korrekt', () async {
    final questionId = 42;

    // Starte frisch
    await ProgressStorage.resetProgress(questionId);

    // Weniger als 3 mal korrekt -> nicht gelernt
    await ProgressStorage.addAnswerResult(questionId, true);
    await ProgressStorage.addAnswerResult(questionId, false);
    await ProgressStorage.addAnswerResult(questionId, true);
    var results = await ProgressStorage.getLastThreeResults(questionId);
    expect(results, [true, false, true]);
    var learned = await ProgressStorage.isLearned(questionId);
    expect(learned, false);

    // 3 mal in Folge richtig -> gelernt
    await ProgressStorage.addAnswerResult(questionId, true);
    results = await ProgressStorage.getLastThreeResults(questionId);
    expect(results, [true, true, false]); // Nur die letzten 3 bleiben
    await ProgressStorage.addAnswerResult(questionId, true);
    await ProgressStorage.addAnswerResult(questionId, true);
    results = await ProgressStorage.getLastThreeResults(questionId);
    expect(results, [true, true, true]);
    learned = await ProgressStorage.isLearned(questionId);
    expect(learned, true);

    // Reset löscht alles
    await ProgressStorage.resetProgress(questionId);
    results = await ProgressStorage.getLastThreeResults(questionId);
    expect(results, []);
  });
}
