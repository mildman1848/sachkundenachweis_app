import 'package:flutter/material.dart';
import '../data/questions.dart';
import '../models/question_model.dart';
import '../storage/progress_storage.dart';

class QuizScreen extends StatefulWidget {
  final VoidCallback toggleTheme;

  const QuizScreen({super.key, required this.toggleTheme});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentIndex = 0;
  Set<int> selectedAnswers = {};
  bool submitted = false;

  Question get currentQuestion => questions[currentIndex];

  void toggleAnswer(int index) {
    if (submitted) return;
    setState(() {
      if (selectedAnswers.contains(index)) {
        selectedAnswers.remove(index);
      } else {
        selectedAnswers.add(index);
      }
    });
  }

  void submitAnswer() async {
    setState(() {
      submitted = true;
    });

    if (isSelectionCorrect()) {
      await ProgressStorage.incrementCorrect(currentQuestion.id);
    }
  }

  void nextQuestion() {
    setState(() {
      currentIndex = (currentIndex + 1) % questions.length;
      selectedAnswers.clear();
      submitted = false;
    });
  }

  bool isCorrectAnswer(int index) {
    return currentQuestion.correctOptionIndexes.contains(index);
  }

  bool isSelectionCorrect() {
    return Set.from(currentQuestion.correctOptionIndexes).containsAll(selectedAnswers) &&
           selectedAnswers.containsAll(currentQuestion.correctOptionIndexes);
  }

  @override
  Widget build(BuildContext context) {
    final q = currentQuestion;

    return Scaffold(
      appBar: AppBar(
        title: Text("Kategorie: ${q.category}"),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: widget.toggleTheme,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              q.questionText,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            if (q.imageAsset != null)
              Center(
                child: Image.asset(
                  q.imageAsset!,
                  height: 200,
                  fit: BoxFit.contain,
                ),
              ),
            const SizedBox(height: 16),
            ...List.generate(q.options.length, (index) {
              final isSelected = selectedAnswers.contains(index);
              final isCorrect = isCorrectAnswer(index);

              Color? tileColor;
              IconData? icon;

              if (submitted) {
                if (isCorrect && isSelected) {
                  tileColor = Colors.green.shade100;
                  icon = Icons.check_circle;
                } else if (!isCorrect && isSelected) {
                  tileColor = Colors.red.shade100;
                  icon = Icons.cancel;
                } else if (isCorrect && !isSelected) {
                  tileColor = Colors.yellow.shade100;
                  icon = Icons.warning;
                }
              }

              return Card(
                color: tileColor,
                child: ListTile(
                  onTap: () => toggleAnswer(index),
                  leading: Checkbox(
                    value: isSelected,
                    onChanged: (_) => toggleAnswer(index),
                  ),
                  title: Text(q.options[index]),
                  trailing: icon != null ? Icon(icon) : null,
                ),
              );
            }),
            const SizedBox(height: 16),
            if (!submitted)
              ElevatedButton(
                onPressed: selectedAnswers.isEmpty ? null : submitAnswer,
                child: const Text("Weiter"),
              )
            else ...[
              if (!isSelectionCorrect())
                Text(
                  "Erklärung: ${q.explanation}",
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: nextQuestion,
                child: const Text("Nächste Frage"),
              )
            ]
          ],
        ),
      ),
    );
  }
}
