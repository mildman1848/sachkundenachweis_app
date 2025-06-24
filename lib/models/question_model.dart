// lib/models/question_model.dart

class Question {
  final int id;
  final String question;
  final List<String> answers;
  final List<int> correctAnswers;
  final String? image;

  const Question({
    required this.id,
    required this.question,
    required this.answers,
    required this.correctAnswers,
    this.image,
  });
}
