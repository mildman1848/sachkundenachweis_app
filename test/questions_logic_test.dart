// test/questions_logic_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:sachkundenachweis/data/questions.dart';
import 'package:sachkundenachweis/data/question_categories.dart';

void main() {
  test('Fragenliste enthält mindestens eine Frage', () {
    expect(questions.length, greaterThan(0));
  });

  test('Alle Fragen haben mindestens eine richtige Antwort', () {
    for (final q in questions) {
      expect(q.correctAnswers.isNotEmpty, true,
          reason: 'Frage ${q.id} (${q.question}) hat keine richtige Antwort.');
    }
  });

  test('Jede Frage ist mindestens einer Kategorie zugeordnet', () {
    // Prüfe für jede Frage, ob sie in questionCategories irgendwo vorkommt
    for (final q in questions) {
      final found = questionCategories.values.any((ids) => ids.contains(q.id));
      expect(found, true, reason: 'Frage ${q.id} ist keiner Kategorie zugeordnet.');
    }
  });
}
