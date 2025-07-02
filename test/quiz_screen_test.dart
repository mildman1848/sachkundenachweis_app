// test/quiz_screen_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sachkundenachweis/screens/quiz_screen.dart';
import 'package:sachkundenachweis/data/questions.dart';
import 'package:sachkundenachweis/theme/theme_notifier.dart';

void main() {
  testWidgets('QuizScreen zeigt gezielt ausgewählte Frage korrekt an', (WidgetTester tester) async {
    final question = questions[0];

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeNotifier(),
        child: MaterialApp(
          home: QuizScreen(singleQuestionId: question.id),
        ),
      ),
    );

    // warte auf vollständiges Rendering
    await tester.pumpAndSettle();

    // Fragetext prüfen
    expect(find.textContaining(question.question), findsOneWidget);

    // Antworten prüfen
    for (final answer in question.answers) {
      expect(find.text(answer), findsOneWidget);
    }
  });
}
