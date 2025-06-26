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
  const QuizScreen({super.key, this.singleQuestionId});
  final int? singleQuestionId; // für Einzelmodus, sonst null für Shuffle

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late List<Question> _shuffledQuestions;
  int currentIndex = 0;
  Set<int> selectedAnswers = {};
  bool submitted = false;
  bool loadingNext = false;

  @override
  void initState() {
    super.initState();
    _initQuiz();
  }

  void _initQuiz() {
    if (widget.singleQuestionId != null) {
      // Einzelmodus
      _shuffledQuestions = [
        questions.firstWhere((q) => q.id == widget.singleQuestionId)
      ];
    } else {
      // Normales Quiz: gewichtet und gemischt
      _shuffledQuestions = _buildPrioritizedShuffledQuestions();
    }
    currentIndex = 0;
    selectedAnswers.clear();
    submitted = false;
    loadingNext = false;
  }

  List<Question> _buildPrioritizedShuffledQuestions() {
    // Ungelernte Fragen 3x, gelernte 1x
    final weighted = <Question>[];
    for (final q in questions) {
      weighted.addAll([q, q, q]);
    }
    weighted.shuffle(Random());
    // Keine doppelten IDs
    final ids = <int>{};
    final result = <Question>[];
    for (final q in weighted) {
      if (!ids.contains(q.id)) {
        ids.add(q.id);
        result.add(q);
      }
    }
    return result;
  }

  Question get currentQuestion => _shuffledQuestions[currentIndex];

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

  Future<void> nextQuestion() async {
    setState(() {
      loadingNext = true;
    });
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    if (currentIndex < _shuffledQuestions.length - 1) {
      setState(() {
        currentIndex++;
        selectedAnswers.clear();
        submitted = false;
        loadingNext = false;
      });
    } else {
      setState(() {
        loadingNext = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Du hast alle Fragen durchgespielt!")),
      );
      Navigator.of(context).pop(true);
    }
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

  void popWithRefresh() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop(true);
    } else {
      Navigator.of(context).maybePop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = currentQuestion;
    final Color secondary = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      appBar: AppBar(
        title: Text("Kategorie: $currentCategoryTitle"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: popWithRefresh,
          tooltip: "Zurück",
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            tooltip: 'Theme wechseln',
            onPressed: () => _cycleTheme(context),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Fortschritt nur im normalen Quiz-Modus
            if (widget.singleQuestionId == null) ...[
              LinearProgressIndicator(
                value: (_shuffledQuestions.length <= 1)
                    ? 1.0
                    : (currentIndex + 1) / _shuffledQuestions.length,
                minHeight: 10,
                borderRadius: BorderRadius.circular(5),
              ),
              const SizedBox(height: 8),
              Text(
                "Frage ${currentIndex + 1} von ${_shuffledQuestions.length}",
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
            ],
            Text(
              q.question,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (q.image != null) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(
                  q.image!,
                  height: 160,
                  fit: BoxFit.contain,
                ),
              ),
            ],
            const SizedBox(height: 8),
            // Nur die Antwortmöglichkeiten sind scrollbar!
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
                    ? const Icon(Icons.arrow_forward)
                    : const Icon(Icons.check),
                label: loadingNext
                    ? const Text("Lädt ...")
                    : (submitted ? const Text("Nächste Frage") : const Text("Antwort prüfen")),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
                onPressed: loadingNext
                    ? null
                    : (submitted
                        ? nextQuestion
                        : (selectedAnswers.isEmpty ? null : submitAnswer)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}