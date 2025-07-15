// Pfad: lib/screens/single_question_screen.dart – Screen für einzelne Frage mit interaktiver Beantwortung und Feedback.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Für State-Management (Best Practice: Riverpod).
import 'package:vibration/vibration.dart'; // Für Haptic-Feedback (Cross-OS: hasVibrator-Check).
import '../data/questions.dart'; // questionsProvider importieren (behebt 'questions' undefined).
import '../storage/progress_storage.dart'; // Fortschritt-Speicherung.
import '../models/question_model.dart'; // Question-Model.

// SingleQuestionScreen (ConsumerStatefulWidget für Riverpod).
class SingleQuestionScreen extends ConsumerStatefulWidget {
  final int questionId; // Frage-ID.

  const SingleQuestionScreen({super.key, required this.questionId});

  @override
  ConsumerState<SingleQuestionScreen> createState() => _SingleQuestionScreenState();
}

class _SingleQuestionScreenState extends ConsumerState<SingleQuestionScreen> {
  late Future<Question> _questionFuture; // Asynchrone Frage (behebt 'questions' undefined).
  Set<int> selectedAnswers = {}; // Ausgewählte Antworten.
  bool submitted = false; // Abgeschickt-Flag.

  @override
  void initState() {
    super.initState();
    _questionFuture = _loadQuestion(); // Frage laden.
  }

  // Frage laden (asynchron mit Provider).
  Future<Question> _loadQuestion() async {
    final questionsData = await ref.read(questionsProvider.future); // Fragen laden.
    return questionsData.firstWhere((qq) => qq.id == widget.questionId);
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

  // Korrekte prüfen.
  bool isCorrectAnswer(int index, List<int> correct) {
    return correct.contains(index);
  }

  // Auswahl korrekt.
  bool isSelectionCorrect(Set<int> selected, List<int> correct) {
    return Set.from(correct).containsAll(selected) && selected.containsAll(Set.from(correct));
  }

  // Abschicken (async, speichert).
  Future<void> submitAnswer(Question q) async {
    setState(() {
      submitted = true;
    });
    await ProgressStorage.addAnswerResult(q.id, isSelectionCorrect(selectedAnswers, q.correctAnswers));
    Vibration.vibrate(pattern: isSelectionCorrect(selectedAnswers, q.correctAnswers) ? [0, 100] : [0, 500]);
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
    final secondary = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Frage beantworten'), // Const.
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // Const.
          onPressed: popWithRefresh,
          tooltip: "Zurück",
        ),
      ),
      body: FutureBuilder<Question>(
        future: _questionFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator()); // Const.
          }
          final q = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(12), // Const.
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                        ? const Icon(Icons.check_circle) // Const.
                        : const Icon(Icons.check), // Const.
                    label: Text(submitted ? "Zurück" : "Antwort prüfen"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14), // Const.
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                    onPressed: submitted
                        ? popWithRefresh
                        : (selectedAnswers.isEmpty ? null : () => submitAnswer(q)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}