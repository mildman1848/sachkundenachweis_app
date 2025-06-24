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
    expect(find.text(questions[0].question), findsOneWidget);

    // Prüfe, ob Antwortoptionen angezeigt werden
    for (final answer in questions[0].answers) {
      expect(find.text(answer), findsOneWidget);
    }
  });
}
