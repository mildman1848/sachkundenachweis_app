// test/question_model_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:sachkundenachweis/models/question_model.dart';

void main() {
  test('Question model initializes correctly', () {
    final question = Question(
      id: 1,
      category: 'Test',
      questionText: 'Wie viele Beine hat ein Hund?',
      options: ['Zwei', 'Drei', 'Vier', 'Fünf'],
      correctOptionIndexes: [2],
      explanation: 'Vier ist korrekt.',
      imageAsset: 'assets/images/skizze_1.webp',
    );
    expect(question.id, 1);
    expect(question.options[2], 'Vier');
    expect(question.correctOptionIndexes, [2]);
    expect(question.explanation, isA<String>());
    expect(question.imageAsset, isNotNull);
  });
}
