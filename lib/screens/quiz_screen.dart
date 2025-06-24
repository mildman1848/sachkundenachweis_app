// lib/screens/quiz_screen.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/questions.dart';
import '../models/question_model.dart';
import '../storage/progress_storage.dart';
import '../data/question_categories.dart';
import '../theme/theme_notifier.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentIndex = 0;
  Set<int> selectedAnswers = {};
  bool submitted = false;
  bool loadingNext = false;

  Question get currentQuestion => questions[currentIndex];

  String? get currentCategoryKey {
    for (final entry in questionCategories.entries) {
      if (entry.value.contains(currentQuestion.id)) return entry.key;
    }
    return null;
  }

  String get currentCategoryTitle =>
      categoryTitles[currentCategoryKey] ?? 'Unbekannt';

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

  Future<void> submitAnswer() async {
    setState(() {
      submitted = true;
    });
    await ProgressStorage.addAnswerResult(
        currentQuestion.id, isSelectionCorrect());
  }

  Future<int> pickNextRandomIndex() async {
    final isLearnedMap = <int, bool>{};
    for (final q in questions) {
      isLearnedMap[q.id] = await ProgressStorage.isLearned(q.id);
    }
    final weighted = <int>[];
    for (var i = 0; i < questions.length; i++) {
      if (isLearnedMap[questions[i].id] == true) {
        weighted.add(i);
      } else {
        weighted.addAll([i, i, i]);
      }
    }
    weighted.removeWhere((i) => i == currentIndex);
    if (weighted.isEmpty) return currentIndex;
    return weighted[Random().nextInt(weighted.length)];
  }

  Future<void> nextQuestion() async {
    setState(() {
      loadingNext = true;
    });
    final nextIdx = await pickNextRandomIndex();
    setState(() {
      currentIndex = nextIdx;
      selectedAnswers.clear();
      submitted = false;
      loadingNext = false;
    });
  }

  bool isCorrectAnswer(int index) {
    return currentQuestion.correctAnswers.contains(index);
  }

  bool isSelectionCorrect() {
    return Set.from(currentQuestion.correctAnswers).containsAll(selectedAnswers) &&
        selectedAnswers.containsAll(currentQuestion.correctAnswers);
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
    final q = currentQuestion;

    return Scaffold(
      appBar: AppBar(
        title: Text("Kategorie: $currentCategoryTitle"),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            tooltip: 'Theme wechseln',
            onPressed: () => _cycleTheme(context),
          )
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isWide ? 700 : double.infinity,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                              height: isWide ? 260 : 200,
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
                            tileColor = Colors.green.withValues(alpha: (0.20 * 255).toDouble());
                            icon = Icons.check_circle;
                            iconColor = Colors.green;
                          } else if (!isCorrect && isSelected) {
                            tileColor = Colors.red.withValues(alpha: (0.17 * 255).toDouble());
                            icon = Icons.cancel;
                            iconColor = Colors.red;
                          } else if (isCorrect && !isSelected) {
                            tileColor = Colors.yellow.withValues(alpha: (0.20 * 255).toDouble());
                            icon = Icons.warning_amber_rounded;
                            iconColor = Colors.orange;
                          }
                        } else if (isSelected) {
                          tileColor = Theme.of(context).colorScheme.secondary.withValues(alpha: (0.14 * 255).toDouble());
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
                            icon: const Icon(Icons.arrow_forward),
                            label: loadingNext
                                ? const Text("Lädt ...")
                                : const Text("Nächste Frage"),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: loadingNext ? null : nextQuestion,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
