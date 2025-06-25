// lib/screens/category_learning_screen.dart

import 'package:flutter/material.dart';
import '../models/question_model.dart';
import '../data/questions.dart';
import '../storage/progress_storage.dart';
import '../theme/theme_notifier.dart';
import 'package:provider/provider.dart';

class CategoryLearningScreen extends StatefulWidget {
  final String categoryTitle;
  final List<int> questionIds;

  const CategoryLearningScreen({
    super.key,
    required this.categoryTitle,
    required this.questionIds,
  });

  @override
  State<CategoryLearningScreen> createState() => _CategoryLearningScreenState();
}

class _CategoryLearningScreenState extends State<CategoryLearningScreen> {
  int currentIdx = 0;
  Set<int> selectedAnswers = {};
  bool submitted = false;
  bool loadingNext = false;
  bool finished = false;

  Question get currentQuestion =>
      questions.firstWhere((q) => q.id == widget.questionIds[currentIdx]);

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
    return currentQuestion.correctAnswers.contains(index);
  }

  bool isSelectionCorrect() {
    return Set.from(currentQuestion.correctAnswers).containsAll(selectedAnswers) &&
        selectedAnswers.containsAll(currentQuestion.correctAnswers);
  }

  Future<void> submitAnswer() async {
    setState(() {
      submitted = true;
    });
    await ProgressStorage.addAnswerResult(
        currentQuestion.id, isSelectionCorrect());
  }

  Future<void> nextQuestion() async {
    if (currentIdx < widget.questionIds.length - 1) {
      setState(() {
        currentIdx++;
        selectedAnswers.clear();
        submitted = false;
      });
    } else {
      setState(() {
        finished = true;
      });
    }
  }

  void _cycleTheme(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    final current = themeNotifier.themeMode;
    final values = AppThemeMode.values;
    final next = values[(current.index + 1) % values.length];
    themeNotifier.themeMode = next;
  }

  @override
  Widget build(BuildContext context) {
    if (finished) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Lernmodus: ${widget.categoryTitle}"),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 70),
              const SizedBox(height: 18),
              Text(
                "Super, du hast alle Fragen dieser Kategorie durchgearbeitet!",
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.arrow_back),
                label: const Text("Zurück zur Kategorie"),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        ),
      );
    }

    final q = currentQuestion;
    final Color secondary = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      appBar: AppBar(
        title: Text("Lernmodus: ${widget.categoryTitle}"),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            tooltip: 'Theme wechseln',
            onPressed: () => _cycleTheme(context),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 700),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearProgressIndicator(
                  value: (currentIdx + 1) / widget.questionIds.length,
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(5),
                ),
                const SizedBox(height: 16),
                Text(
                  "Frage ${currentIdx + 1} von ${widget.questionIds.length}",
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 16),
                Text(
                  q.question,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 18),
                if (q.image != null)
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset(
                        q.image!,
                        height: 200,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                const SizedBox(height: 18),
                ...List.generate(q.answers.length, (index) {
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
                const SizedBox(height: 20),
                if (!submitted)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check),
                      label: const Text("Antwort prüfen"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                      onPressed: selectedAnswers.isEmpty ? null : submitAnswer,
                    ),
                  )
                else ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: Icon(currentIdx < widget.questionIds.length - 1
                          ? Icons.arrow_forward
                          : Icons.check_circle),
                      label: currentIdx < widget.questionIds.length - 1
                          ? const Text("Nächste Frage")
                          : const Text("Fertig"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: nextQuestion,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
