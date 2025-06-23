// test/quiz_screen_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:sachkundenachweis/screens/quiz_screen.dart';
import 'package:sachkundenachweis/data/questions.dart';

void main() {
  testWidgets('QuizScreen rendert und zeigt erste Frage', (WidgetTester tester) async {
    // QuizScreen einbinden
    await tester.pumpWidget(MaterialApp(
      home: QuizScreen(toggleTheme: () {}),
    ));

    // Prüfe, ob der Fragetext der ersten Frage angezeigt wird
    expect(find.text(questions[0].questionText), findsOneWidget);

    // (Optional) Prüfe, ob Antwortoptionen angezeigt werden
    for (final option in questions[0].options) {
      expect(find.text(option), findsOneWidget);
    }
  });
}
