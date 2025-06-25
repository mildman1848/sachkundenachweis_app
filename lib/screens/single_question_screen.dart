// lib/screens/single_question_screen.dart

import 'package:flutter/material.dart';
import '../models/question_model.dart';
import '../data/questions.dart';
import '../storage/progress_storage.dart';
import '../data/question_categories.dart';
import '../theme/theme_notifier.dart';
import 'package:provider/provider.dart';

class SingleQuestionScreen extends StatefulWidget {
  final int questionId;

  const SingleQuestionScreen({super.key, required this.questionId});

  @override
  State<SingleQuestionScreen> createState() => _SingleQuestionScreenState();
}

class _SingleQuestionScreenState extends State<SingleQuestionScreen> {
  late Question question;
  Set<int> selectedAnswers = {};
  bool submitted = false;
  List<bool> last3 = [];
  bool loading = true;

  String? get currentCategoryKey {
    for (final entry in questionCategories.entries) {
      if (entry.value.contains(question.id)) return entry.key;
    }
    return null;
  }

  String get currentCategoryTitle =>
      categoryTitles[currentCategoryKey] ?? 'Unbekannt';

  @override
  void initState() {
    super.initState();
    question = questions.firstWhere((q) => q.id == widget.questionId);
    _loadLast3();
  }

  Future<void> _loadLast3() async {
    final res = await ProgressStorage.getLastThreeResults(widget.questionId);
    setState(() {
      last3 = res;
      loading = false;
    });
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
    return question.correctAnswers.contains(index);
  }

  bool isSelectionCorrect() {
    return Set.from(question.correctAnswers).containsAll(selectedAnswers) &&
        selectedAnswers.containsAll(question.correctAnswers);
  }

  Future<void> submitAnswer() async {
    setState(() {
      submitted = true;
    });
    await ProgressStorage.addAnswerResult(
        question.id, isSelectionCorrect());
    await _loadLast3(); // Indikatoren neu laden
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
    final Color secondary = Theme.of(context).colorScheme.secondary;

    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Kategorie: $currentCategoryTitle"),
        actions: [
          Row(
            children: List.generate(3, (i) {
              final state = last3.length > i ? last3[i] : null;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Icon(
                  Icons.circle,
                  size: 16,
                  color: state == true
                      ? Colors.green
                      : (state == false
                          ? Colors.red
                          : Colors.grey.shade400),
                ),
              );
            }),
          ),
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
                        question.question,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 18),
                      if (question.image != null)
                        Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.asset(
                              question.image!,
                              height: isWide ? 260 : 200,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      const SizedBox(height: 18),
                      ...List.generate(question.answers.length, (index) {
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
                              question.answers[index],
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
                            icon: const Icon(Icons.arrow_back),
                            label: const Text("Zurück"),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => Navigator.of(context).pop(),
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
