// Pfad: lib/screens/quiz_screen.dart – Screen für Quiz-Modus mit randomisierten Fragen und Feedback.

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Für State-Management (Best Practice: Riverpod).
import 'package:vibration/vibration.dart'; // Für Haptic-Feedback (Cross-OS: hasVibrator-Check).
import '../data/questions.dart'; // questionsProvider importieren (behebt 'questions' undefined).
import '../models/question_model.dart'; // Question-Model.
import '../storage/progress_storage.dart'; // Fortschritt-Speicherung.
import '../data/question_categories.dart'; // Kategorien für Titel.
import '../theme/theme_notifier.dart'; // Theme-Notifier.

// QuizScreen (ConsumerStatefulWidget für Riverpod).
class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key, this.singleQuestionId});
  final int? singleQuestionId; // Optionale ID für Single-Mode.

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  late Future<List<Question>> _shuffledQuestionsFuture; // Asynchrone Shuffled-Liste (behebt 'questions' undefined).
  int currentIndex = 0; // Aktueller Index.
  Set<int> selectedAnswers = {}; // Ausgewählte Antworten.
  bool submitted = false; // Abgeschickt-Flag.
  bool loadingNext = false; // Lade-Flag für Next.

  @override
  void initState() {
    super.initState();
    _shuffledQuestionsFuture = _initQuiz(); // Asynch Init.
  }

  // Quiz initialisieren (asynchron, nutzt Provider).
  Future<List<Question>> _initQuiz() async {
    final questionsData = await ref.read(questionsProvider.future); // Fragen laden (behebt undefined).
    if (widget.singleQuestionId != null) {
      return [questionsData.firstWhere((q) => q.id == widget.singleQuestionId)];
    } else {
      return _buildPrioritizedShuffledQuestions(questionsData); // Shuffled.
    }
  }

  // Priorisierte Shuffled-Liste (Best Practice: Random mit Weighting).
  List<Question> _buildPrioritizedShuffledQuestions(List<Question> data) {
    final weighted = <Question>[];
    for (final q in data) {
      weighted.addAll([q, q, q]); // Weighting.
    }
    weighted.shuffle(Random());
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

  // Aktuelle Frage abrufen (FutureBuilder im Build).
  Future<Question> getCurrentQuestion() async {
    final shuffled = await _shuffledQuestionsFuture;
    return shuffled[currentIndex];
  }

  // Kategorie-Key abrufen (für Titel).
  Future<String?> getCurrentCategoryKey(Question q) async {
    for (final entry in questionCategories.entries) {
      if (entry.value.contains(q.id)) return entry.key;
    }
    return null;
  }

  // Kategorie-Titel.
  Future<String> getCurrentCategoryTitle(Question q) async {
    final key = await getCurrentCategoryKey(q);
    return categoryTitles[key] ?? 'Unbekannt';
  }

  // Antwort toggeln (mit Feedback).
  void toggleAnswer(int index) {
    if (submitted) return;
    setState(() {
      if (selectedAnswers.contains(index)) {
        selectedAnswers.remove(index);
      } else {
        selectedAnswers.add(index);
      }
    });
    Vibration.vibrate(duration: 50); // Haptic.
  }

  // Abschicken (async, speichert).
  Future<void> submitAnswer() async {
    final question = await getCurrentQuestion();
    setState(() {
      submitted = true;
    });
    await ProgressStorage.addAnswerResult(question.id, isSelectionCorrect(question));
    Vibration.vibrate(pattern: isSelectionCorrect(question) ? [0, 100] : [0, 500]);
  }

  // Nächste Frage (mit Delay für UX).
  Future<void> nextQuestion() async {
    setState(() {
      loadingNext = true;
    });
    await Future.delayed(const Duration(milliseconds: 200)); // Const für Lint.
    if (!mounted) return;
    final shuffled = await _shuffledQuestionsFuture;
    if (currentIndex < shuffled.length - 1) {
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
    }
  }

  // Korrekte prüfen.
  bool isCorrectAnswer(int index, List<int> correct) {
    return correct.contains(index);
  }

  // Auswahl korrekt.
  bool isSelectionCorrect(Question q) {
    return Set.from(q.correctAnswers).containsAll(selectedAnswers) &&
        selectedAnswers.containsAll(Set.from(q.correctAnswers));
  }

  // Theme wechseln (Riverpod).
  void _cycleTheme() {
    final themeNotifier = ref.read(themeNotifierProvider.notifier);
    final current = ref.read(themeNotifierProvider).mode;
    const values = AppThemeMode.values; // Const für Lint.
    final next = values[(current.index + 1) % values.length];
    themeNotifier.setThemeMode(next);
  }

  @override
  Widget build(BuildContext context) {
    // Gesamter Body in FutureBuilder für shuffledQuestionsFuture (behebt Future<double> für value).
    return FutureBuilder<List<Question>>(
      future: _shuffledQuestionsFuture,
      builder: (context, shuffledSnapshot) {
        if (!shuffledSnapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator())); // Const.
        }
        final shuffled = shuffledSnapshot.data!;
        return FutureBuilder<Question>(
          future: getCurrentQuestion(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Scaffold(body: Center(child: CircularProgressIndicator())); // Const.
            }
            final q = snapshot.data!;
            final secondary = Theme.of(context).colorScheme.secondary;

            return Scaffold(
              appBar: AppBar(
                title: FutureBuilder<String>(
                  future: getCurrentCategoryTitle(q),
                  builder: (context, titleSnapshot) {
                    return Text("Kategorie: ${titleSnapshot.data ?? 'Laden...'}");
                  },
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.brightness_6), // Const.
                    tooltip: 'Theme wechseln',
                    onPressed: _cycleTheme,
                  )
                ],
              ),
              body: Padding(
                padding: const EdgeInsets.all(12), // Const.
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (widget.singleQuestionId == null) ...[
                      LinearProgressIndicator(
                        value: (currentIndex + 1) / shuffled.length, // Nun double (kein Future, behebt Typ-Fehler).
                        minHeight: 10,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      const SizedBox(height: 8), // Const.
                      Text(
                        "Frage ${currentIndex + 1} von ${shuffled.length}",
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8), // Const.
                    ],
                    Text(
                      'Frage ${q.id}: ${q.question}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (q.image != null) ...[
                      const SizedBox(height: 8), // Const.
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
                    const SizedBox(height: 8), // Const.
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: List.generate(q.answers.length, (index) {
                            final isSelected = selectedAnswers.contains(index);
                            final isCorrect = isCorrectAnswer(index, q.correctAnswers);

                            Color? tileColor;
                            IconData? icon;
                            Color? iconColor;

                            if (submitted) {
                              if (isCorrect && isSelected) {
                                tileColor = Colors.green.withValues(alpha: 0.2); // Deprecated behoben.
                                icon = Icons.check_circle;
                                iconColor = Colors.green;
                              } else if (!isCorrect && isSelected) {
                                tileColor = Colors.red.withValues(alpha: 0.2);
                                icon = Icons.cancel;
                                iconColor = Colors.red;
                              } else if (isCorrect && !isSelected) {
                                tileColor = Colors.yellow.withValues(alpha: 0.2);
                                icon = Icons.warning_amber_rounded;
                                iconColor = Colors.orange;
                              }
                            } else if (isSelected) {
                              tileColor = secondary.withValues(alpha: 0.2);
                            }

                            return Semantics(  // Accessibility.
                              label: q.answers[index],
                              child: Card(
                                elevation: 2,
                                color: tileColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: ListTile(
                                  contentPadding:
                                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4), // Const.
                                  onTap: () => toggleAnswer(index),
                                  leading: Padding(
                                    padding: const EdgeInsets.only(right: 8.0), // Const.
                                    child: Checkbox(
                                      value: isSelected,
                                      onChanged: (_) => toggleAnswer(index),
                                      activeColor: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                  title: Text(
                                    q.answers[index],
                                    style: Theme.of(context).textTheme.bodyLarge,
                                  ),
                                  trailing: icon != null ? Icon(icon, color: iconColor) : null,
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8), // Const.
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: submitted
                            ? const Icon(Icons.arrow_forward) // Const.
                            : const Icon(Icons.check), // Const.
                        label: loadingNext
                            ? const Text("Lädt ...") // Const.
                            : (submitted
                                ? const Text("Nächste Frage") // Const.
                                : const Text("Antwort prüfen")), // Const.
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14), // Const.
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
          },
        );
      },
    );
  }
}