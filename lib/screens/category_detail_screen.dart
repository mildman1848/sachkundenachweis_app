// lib/screens/category_detail_screen.dart

import 'package:flutter/material.dart';
import '../data/questions.dart';
import '../storage/progress_storage.dart';
import '../models/question_model.dart';
import 'single_question_screen.dart'; // <--- Wichtig!

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          return ListView.builder(
            itemCount: details.length,
            itemBuilder: (context, idx) {
              final detail = details[idx];
              return Card(
                child: ListTile(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => SingleQuestionScreen(
                          questionId: detail.question.id,
                        ),
                      ),
                    );
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
          );
        },
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
