// test/question_model_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:sachkundenachweis/models/question_model.dart';

void main() {
  test('Question model initializes correctly', () {
    final question = Question(
      id: 1,
      question: 'Wie viele Beine hat ein Hund?',
      answers: ['Zwei', 'Drei', 'Vier', 'Fünf'],
      correctAnswers: [2],
      image: 'assets/images/skizzen/1.png',
    );
    expect(question.id, 1);
    expect(question.question, 'Wie viele Beine hat ein Hund?');
    expect(question.answers[2], 'Vier');
    expect(question.correctAnswers, [2]);
    expect(question.image, isNotNull);
  });
}
