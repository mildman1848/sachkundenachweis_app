// test/questions_logic_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:sachkundenachweis/data/questions.dart';

void main() {
  test('Fragenliste enthält mindestens eine Frage', () {
    expect(questions.length, greaterThan(0));
  });

  test('Alle Fragen haben mindestens eine richtige Antwort', () {
    for (final q in questions) {
      expect(q.correctOptionIndexes.isNotEmpty, true,
          reason: 'Frage ${q.id} (${q.questionText}) hat keine richtige Antwort.');
    }
  });

  test('Kategorien sind nicht leer', () {
    for (final q in questions) {
      expect(q.category.trim(), isNotEmpty,
          reason: 'Frage ${q.id} hat keine Kategorie.');
    }
  });
}
