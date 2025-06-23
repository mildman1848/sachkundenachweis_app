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

  test('Increment and get correct count', () async {
    final questionId = 42;

    await ProgressStorage.resetProgress(questionId);
    await ProgressStorage.incrementCorrect(questionId);
    await ProgressStorage.incrementCorrect(questionId);

    final count = await ProgressStorage.getCorrectCount(questionId);
    expect(count, 2);

    final isLearned = await ProgressStorage.isLearned(questionId, threshold: 2);
    expect(isLearned, true);

    await ProgressStorage.resetProgress(questionId);
    final resetCount = await ProgressStorage.getCorrectCount(questionId);
    expect(resetCount, 0);
  });
}
