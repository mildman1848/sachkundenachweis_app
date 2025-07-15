// Pfad: lib/screens/category_learning_screen.dart – Screen für Lernmodus in Kategorien mit interaktiven Fragen.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Für State-Management (Best Practice: Riverpod statt Provider).
import 'package:vibration/vibration.dart'; // Für Haptic-Feedback (Cross-OS: Check mit hasVibrator).
import '../data/questions.dart'; // questionsProvider importieren (behebt 'questions' undefined).
import '../storage/progress_storage.dart'; // Fortschritt-Speicherung.
import '../models/question_model.dart'; // Question-Model.
import '../theme/theme_notifier.dart'; // Theme-Notifier (Riverpod).

// CategoryLearningScreen (ConsumerStatefulWidget für Riverpod, behebt Provider.of).
class CategoryLearningScreen extends ConsumerStatefulWidget {
  final String categoryTitle; // Kategorie-Titel.
  final List<int> questionIds; // Frage-IDs.

  const CategoryLearningScreen({
    super.key,
    required this.categoryTitle,
    required this.questionIds,
  });

  @override
  ConsumerState<CategoryLearningScreen> createState() => _CategoryLearningScreenState();
}

class _CategoryLearningScreenState extends ConsumerState<CategoryLearningScreen> {
  int currentIdx = 0; // Aktueller Index.
  Set<int> selectedAnswers = {}; // Ausgewählte Antworten.
  bool submitted = false; // Abgeschickt-Flag.
  bool finished = false; // Abgeschlossen-Flag.

  // Aktuelle Frage abrufen (nutzt Provider, Best Practice: Asynchron).
  Future<Question> getCurrentQuestion() async {
    final questionsData = await ref.read(questionsProvider.future); // Fragen laden.
    return questionsData.firstWhere((q) => q.id == widget.questionIds[currentIdx]);
  }

  // Antwort toggeln (mit Haptic-Feedback, Cross-OS).
  void toggleAnswer(int index) {
    if (submitted) return;
    setState(() {
      if (selectedAnswers.contains(index)) {
        selectedAnswers.remove(index);
      } else {
        selectedAnswers.add(index);
      }
    });
    Vibration.vibrate(duration: 50); // Feedback (check if available).
  }

  // Prüfen, ob Antwort korrekt.
  bool isCorrectAnswer(int index, List<int> correct) {
    return correct.contains(index);
  }

  // Prüfen, ob Auswahl korrekt.
  bool isSelectionCorrect(Set<int> selected, List<int> correct) {
    return Set.from(correct).containsAll(selected) && selected.containsAll(Set.from(correct));
  }

  // Antwort abschicken (async, speichert Fortschritt).
  Future<void> submitAnswer() async {
    final question = await getCurrentQuestion();
    final correct = isSelectionCorrect(selectedAnswers, question.correctAnswers);
    setState(() {
      submitted = true;
    });
    await ProgressStorage.addAnswerResult(question.id, correct); // Speichern.
    Vibration.vibrate(pattern: correct ? [0, 100] : [0, 500]); // Feedback.
  }

  // Nächste Frage (mit Refresh).
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

  // Theme wechseln (Riverpod, behebt Provider.of).
  void _cycleTheme() {
    final themeNotifier = ref.read(themeNotifierProvider.notifier); // Riverpod-Notifier.
    final current = ref.read(themeNotifierProvider).mode; // Aktueller Mode.
    const values = AppThemeMode.values; // Const für konstante Initialisierung (behebt Lint-Warnung).
    final next = values[(current.index + 1) % values.length];
    themeNotifier.setThemeMode(next); // Setzen.
  }

  // Pop mit Refresh (Navigation-Handling).
  void popWithRefresh() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop(true);
    } else {
      Navigator.of(context).maybePop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (finished) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Lernmodus: ${widget.categoryTitle}"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: popWithRefresh,
            tooltip: "Zurück",
          ),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 70),
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
                onPressed: popWithRefresh,
              ),
            ],
          ),
        ),
      );
    }

    // FutureBuilder für asynchrone Frage (Best Practice: Loading-Handling).
    return FutureBuilder<Question>(
      future: getCurrentQuestion(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator()); // Loading.
        }
        final q = snapshot.data!;
        final Color secondary = Theme.of(context).colorScheme.secondary;

        return Scaffold(
          appBar: AppBar(
            title: Text("Lernmodus: ${widget.categoryTitle}"),
            actions: [
              IconButton(
                icon: const Icon(Icons.brightness_6),
                tooltip: 'Theme wechseln',
                onPressed: _cycleTheme, // Riverpod-Cycle.
              )
            ],
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
                LinearProgressIndicator(
                  value: (currentIdx + 1) / widget.questionIds.length,
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(5),
                ),
                const SizedBox(height: 8),
                Text(
                  "Frage ${currentIdx + 1} von ${widget.questionIds.length}",
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Frage ${q.id}: ${q.question}',
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
                            tileColor = Colors.green.withValues(alpha: 0.2); // Deprecated withOpacity ersetzt (Best Practice: Precision).
                            icon = Icons.check_circle;
                            iconColor = Colors.green;
                          } else if (!isCorrect && isSelected) {
                            tileColor = Colors.red.withValues(alpha: 0.2); // Deprecated ersetzt.
                            icon = Icons.cancel;
                            iconColor = Colors.red;
                          } else if (isCorrect && !isSelected) {
                            tileColor = Colors.yellow.withValues(alpha: 0.2); // Deprecated ersetzt.
                            icon = Icons.warning_amber_rounded;
                            iconColor = Colors.orange;
                          }
                        } else if (isSelected) {
                          tileColor = secondary.withValues(alpha: 0.2); // Deprecated ersetzt.
                        }

                        return Semantics(  // Accessibility (Best Practice: Screen-Reader).
                          label: q.answers[index],
                          child: Card(
                            elevation: 2,
                            color: tileColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: ListTile(
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              onTap: () => toggleAnswer(index),
                              leading: Padding(
                                padding: const EdgeInsets.only(right: 8.0),
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
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: Icon(
                      finished
                          ? Icons.check_circle
                          : (submitted ? Icons.arrow_forward : Icons.check),
                    ),
                    label: finished
                        ? const Text("Fertig")
                        : (submitted
                            ? const Text("Nächste Frage")
                            : const Text("Antwort prüfen")),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: finished
                        ? popWithRefresh
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
  }
}