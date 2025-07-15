// Speicherort: test/question_model_test.dart
// Beschreibung: Testet die Initialisierung der Question-Klasse in lib/models/question_model.dart.
// Überprüft, ob die Question-Klasse korrekt mit ID, Fragetext, Antworten, korrekten Antworten und Bild initialisiert wird.
// Der Test ist plattformübergreifend kompatibel und verwendet Best Practices für Flutter-Tests.

import 'package:flutter_test/flutter_test.dart';
import 'package:sachkundenachweis/models/question_model.dart'; // Question-Model importieren.

void main() {
  group('Question Model Tests', () {
    test('Question model initialisiert korrekt', () {
      // Initialisiere eine Question-Instanz mit konstanten Werten (const für Performance).
      const question = Question(
        id: 1,
        question: 'Wie viele Beine hat ein Hund?',
        answers: ['Zwei', 'Drei', 'Vier', 'Fünf'],
        correctAnswers: [2],
        image: 'assets/images/skizzen/1.png',
      );

      // Prüfe die Eigenschaften der Question-Instanz.
      expect(question.id, 1, reason: 'ID sollte 1 sein.');
      expect(question.question, 'Wie viele Beine hat ein Hund?', reason: 'Fragetext sollte korrekt sein.');
      expect(question.answers[2], 'Vier', reason: 'Antwort an Index 2 sollte "Vier" sein.');
      expect(question.correctAnswers, [2], reason: 'Korrekte Antworten sollten [2] sein.');
      expect(question.image, isNotNull, reason: 'Bildpfad sollte nicht null sein.');
    });
  });
}