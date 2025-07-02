// lib/screens/single_question_screen.dart

import 'package:flutter/material.dart';
import '../data/questions.dart';
import '../storage/progress_storage.dart';
import '../models/question_model.dart';

class SingleQuestionScreen extends StatefulWidget {
  final int questionId;

  const SingleQuestionScreen({super.key, required this.questionId});

  @override
  State<SingleQuestionScreen> createState() => _SingleQuestionScreenState();
}

class _SingleQuestionScreenState extends State<SingleQuestionScreen> {
  late Question q;
  Set<int> selectedAnswers = {};
  bool submitted = false;

  @override
  void initState() {
    super.initState();
    q = questions.firstWhere((qq) => qq.id == widget.questionId);
  }

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

  bool isCorrectAnswer(int index) {
    return q.correctAnswers.contains(index);
  }

  bool isSelectionCorrect() {
    return Set.from(q.correctAnswers).containsAll(selectedAnswers) &&
        selectedAnswers.containsAll(q.correctAnswers);
  }

  Future<void> submitAnswer() async {
    setState(() {
      submitted = true;
    });
    await ProgressStorage.addAnswerResult(
        q.id, isSelectionCorrect());
  }

  void popWithRefresh() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop(true);
    } else {
      Navigator.of(context).maybePop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color secondary = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Frage beantworten'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: popWithRefresh,
          tooltip: "Zurück",
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              q.question,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (q.image != null) ...[
              const SizedBox(height: 8),
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.asset(
                    q.image!,
                    height: 160,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8),
            // Antwortmöglichkeiten scrollbar
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: List.generate(q.answers.length, (index) {
                    final isSelected = selectedAnswers.contains(index);
                    final isCorrect = isCorrectAnswer(index);

                    Color? tileColor;
                    IconData? icon;
                    Color? iconColor;

                    if (submitted) {
                      if (isCorrect && isSelected) {
                        tileColor = Colors.green.withValues(
                          alpha: 0.20 * 255.0,
                          red: Colors.green.r * 255.0,
                          green: Colors.green.g * 255.0,
                          blue: Colors.green.b * 255.0,
                        );
                        icon = Icons.check_circle;
                        iconColor = Colors.green;
                      } else if (!isCorrect && isSelected) {
                        tileColor = Colors.red.withValues(
                          alpha: 0.17 * 255.0,
                          red: Colors.red.r * 255.0,
                          green: Colors.red.g * 255.0,
                          blue: Colors.red.b * 255.0,
                        );
                        icon = Icons.cancel;
                        iconColor = Colors.red;
                      } else if (isCorrect && !isSelected) {
                        tileColor = Colors.yellow.withValues(
                          alpha: 0.20 * 255.0,
                          red: Colors.yellow.r * 255.0,
                          green: Colors.yellow.g * 255.0,
                          blue: Colors.yellow.b * 255.0,
                        );
                        icon = Icons.warning_amber_rounded;
                        iconColor = Colors.orange;
                      }
                    } else if (isSelected) {
                      tileColor = secondary.withValues(
                        alpha: 0.14 * 255.0,
                        red: secondary.r * 255.0,
                        green: secondary.g * 255.0,
                        blue: secondary.b * 255.0,
                      );
                    }

                    return Card(
                      elevation: 2,
                      color: tileColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ListTile(
                        onTap: () => toggleAnswer(index),
                        leading: Checkbox(
                          value: isSelected,
                          onChanged: (_) => toggleAnswer(index),
                          activeColor: Theme.of(context).colorScheme.primary,
                        ),
                        title: Text(
                          q.answers[index],
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        trailing: icon != null ? Icon(icon, color: iconColor) : null,
                      ),
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: submitted
                    ? const Icon(Icons.check_circle)
                    : const Icon(Icons.check),
                label: Text(submitted ? "Zurück" : "Antwort prüfen"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
                onPressed: submitted
                    ? popWithRefresh
                    : (selectedAnswers.isEmpty ? null : submitAnswer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}