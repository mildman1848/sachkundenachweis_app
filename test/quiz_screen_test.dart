// test/quiz_screen_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:sachkundenachweis/screens/quiz_screen.dart';

void main() {
  testWidgets('QuizScreen rendert und zeigt Fragen', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: QuizScreen(toggleTheme: () {})));
    expect(find.byType(QuizScreen), findsOneWidget);
    // Ersten Fragetext prüfen
    expect(find.textContaining('Frage'), findsWidgets); // Annahme: Fragetext enthält das Wort 'Frage'
  });
}
