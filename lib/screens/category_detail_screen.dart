// lib/screens/category_detail_screen.dart

import 'package:flutter/material.dart';
import '../data/questions.dart';
import '../storage/progress_storage.dart';
import '../models/question_model.dart';
import 'single_question_screen.dart';
import 'category_learning_screen.dart';

class CategoryDetailScreen extends StatefulWidget {
  final String categoryKey;
  final String categoryTitle;
  final List<int> questionIds;

  const CategoryDetailScreen({
    super.key,
    required this.categoryKey,
    required this.categoryTitle,
    required this.questionIds,
  });

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  late Future<List<_QuestionDetail>> _futureDetails;
  bool refreshRequested = false;

  @override
  void initState() {
    super.initState();
    _futureDetails = _loadDetails();
  }

  Future<List<_QuestionDetail>> _loadDetails() async {
    return Future.wait(widget.questionIds.map((id) async {
      final question = questions.firstWhere((q) => q.id == id);
      final last3 = await ProgressStorage.getLastThreeResults(id);
      return _QuestionDetail(
        question: question,
        last3: last3,
      );
    }));
  }

  Future<void> _openSingleQuestionScreen(int questionId) async {
    final refreshed = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SingleQuestionScreen(questionId: questionId),
      ),
    );
    if (refreshed == true) {
      setState(() {
        _futureDetails = _loadDetails();
        refreshRequested = true;
      });
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          Navigator.of(context).pop(refreshRequested);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Kategorie: ${widget.categoryTitle}'),
        ),
        body: FutureBuilder<List<_QuestionDetail>>(
          future: _futureDetails,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                        child: ListTile(
                          onTap: () async {
                            await _openSingleQuestionScreen(detail.question.id);
                          },
                          title: Text(detail.question.question),
                          subtitle: Row(
                            children: List.generate(3, (i) {
                              final state = detail.last3.length > i
                                  ? detail.last3[i]
                                  : null;
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

class _QuestionDetail {
  final Question question;
  final List<bool> last3;
  _QuestionDetail({
    required this.question,
    required this.last3,
  });
}
