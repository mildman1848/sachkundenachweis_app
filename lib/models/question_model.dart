class Question {
  final int id;
  final String category;
  final String questionText;
  final List<String> options;
  final List<int> correctOptionIndexes;
  final String explanation;
  final String? imageAsset;

  Question({
    required this.id,
    required this.category,
    required this.questionText,
    required this.options,
    required this.correctOptionIndexes,
    required this.explanation,
    this.imageAsset,
  });
}
