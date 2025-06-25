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

  final int? singleQuestionId;

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
      _shuffledQuestions = [
        questions.firstWhere((q) => q.id == widget.singleQuestionId)
      ];
    } else {
      _shuffledQuestions = _buildPrioritizedShuffledQuestions();
    }
    currentIndex = 0;
    selectedAnswers.clear();
    submitted = false;
    loadingNext = false;
  }

  List<Question> _buildPrioritizedShuffledQuestions() {
    final learnedMap = <int, bool>{};
    final weighted = <Question>[];

    for (final q in questions) {
      learnedMap[q.id] = false;
    }

    for (var q in questions) {
      weighted.addAll([q, q, q]);
    }

    weighted.shuffle(Random());
    return weighted.toSet().toList();
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Du hast alle Fragen durchgespielt!")),
      );
      popWithRefresh();
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
          onPressed: popWithRefresh