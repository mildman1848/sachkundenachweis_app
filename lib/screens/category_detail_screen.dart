// Pfad: lib/screens/category_detail_screen.dart – Detail-Screen für Kategorien mit Fortschritt und Navigation.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Für State-Management (Best Practice: Asynchrone Daten).
import '../data/questions.dart'; // questionsProvider importieren.
import '../storage/progress_storage.dart'; // Fortschritt-Speicherung.
import '../models/question_model.dart'; // Question-Model.
import 'single_question_screen.dart'; // Einzelne Frage.
import 'category_learning_screen.dart'; // Lernmodus.

// CategoryDetailScreen (ConsumerStatefulWidget für Riverpod, behebt 'questions' undefined).
class CategoryDetailScreen extends ConsumerStatefulWidget {
  final String categoryKey; // Kategorie-Key.
  final String categoryTitle; // Titel.
  final List<int> questionIds; // Frage-IDs.

  const CategoryDetailScreen({
    super.key,
    required this.categoryKey,
    required this.categoryTitle,
    required this.questionIds,
  });

  @override
  ConsumerState<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends ConsumerState<CategoryDetailScreen> {
  late Future<List<_QuestionDetail>> _futureDetails; // Zukunftige Details (asynchron).
  bool refreshRequested = false; // Refresh-Flag.

  @override
  void initState() {
    super.initState();
    _futureDetails = _loadDetails(); // Details laden.
  }

  // Details laden (nutzt questionsProvider, behebt 'questions' undefined).
  Future<List<_QuestionDetail>> _loadDetails() async {
    final questionsData = await ref.read(questionsProvider.future); // Fragen aus Provider laden (Best Practice: Asynchron).
    return Future.wait(widget.questionIds.map((id) async {
      final question = questionsData.firstWhere((q) => q.id == id); // Frage finden.
      final last3 = await ProgressStorage.getLastThreeResults(id); // Letzte Ergebnisse.
      return _QuestionDetail(
        question: question,
        last3: last3,
      );
    }));
  }

  // Einzelne Frage öffnen (Navigation, Refresh bei Rückkehr).
  Future<void> _openSingleQuestionScreen(int questionId) async {
    final refreshed = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SingleQuestionScreen(questionId: questionId),
      ),
    );
    if (refreshed == true) {
      setState(() {
        _futureDetails = _loadDetails(); // Neu laden.
        refreshRequested = true; // Flag setzen.
      });
    }
  }

  // Lernmodus öffnen (analog).
  Future<void> _openCategoryLearningScreen() async {
    final refreshed = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CategoryLearningScreen(
          categoryTitle: widget.categoryTitle,
          questionIds: widget.questionIds,
        ),
      ),
    );
    if (refreshed == true) {
      setState(() {
        _futureDetails = _loadDetails();
        refreshRequested = true;
      });
    }
  }

  // Pop mit Refresh (Best Practice: Navigation-Handling).
  void popWithRefresh() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop(refreshRequested);
    } else {
      Navigator.of(context).maybePop(refreshRequested);
    }
  }

  @override
  Widget build(BuildContext context) {
    // PopScope für Back-Handling (Cross-OS: Android/iOS).
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          popWithRefresh(); // Refresh bei Pop.
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Kategorie: ${widget.categoryTitle}'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: popWithRefresh,
            tooltip: "Zurück",
          ),
        ),
        body: FutureBuilder<List<_QuestionDetail>>(
          future: _futureDetails,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator()); // Loading-Indicator.
            }
            final details = snapshot.data!;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 18, left: 16, right: 16, bottom: 8),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.playlist_play),
                    label: const Text("Lernmodus starten"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _openCategoryLearningScreen,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: details.length,
                    itemBuilder: (context, idx) {
                      final detail = details[idx];
                      return Card(
                        elevation: 1.5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Semantics(  // Accessibility (Best Practice: Screen-Reader-Support).
                          label: 'Frage ${detail.question.id}: ${detail.question.question}',
                          child: ListTile(
                            onTap: () async {
                              await _openSingleQuestionScreen(detail.question.id);
                            },
                            title: Text(
                              'Frage ${detail.question.id}: ${detail.question.question}',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            subtitle: Row(
                              children: List.generate(3, (i) {
                                final state = detail.last3.length > i ? detail.last3[i] : null;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 3),
                                  child: Icon(
                                    Icons.circle,
                                    size: 14,
                                    color: state == true
                                        ? Colors.green
                                        : (state == false
                                            ? Colors.red
                                            : Colors.grey.shade400),
                                  ),
                                );
                              }),
                            ),
                            trailing: const Icon(Icons.chevron_right),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// Interne Klasse für Details (Best Practice: Encapsulation).
class _QuestionDetail {
  final Question question;
  final List<bool> last3;

  _QuestionDetail({
    required this.question,
    required this.last3,
  });
}