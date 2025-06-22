import 'package:flutter/material.dart';
import '../models/question_model.dart';

class QuestionCard extends StatelessWidget {
  final Question question;
  final Set<int> selectedAnswers;
  final bool submitted;
  final void Function(int) onToggle;
  final IconData? Function(int)? feedbackIcon;
  final Color? Function(int)? feedbackColor;

  const QuestionCard({
    super.key,
    required this.question,
    required this.selectedAnswers,
    required this.submitted,
    required this.onToggle,
    this.feedbackIcon,
    this.feedbackColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question.questionText,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        if (question.imageAsset != null)
          Center(
            child: Image.asset(
              question.imageAsset!,
              height: 200,
              fit: BoxFit.contain,
            ),
          ),
        const SizedBox(height: 16),
        ...List.generate(question.options.length, (index) {
          final isSelected = selectedAnswers.contains(index);

          return Card(
            color: feedbackColor != null ? feedbackColor!(index) : null,
            child: ListTile(
              onTap: () => onToggle(index),
              leading: Checkbox(
                value: isSelected,
                onChanged: (_) => onToggle(index),
              ),
              title: Text(question.options[index]),
              trailing: feedbackIcon != null ? Icon(feedbackIcon!(index)) : null,
            ),
          );
        }),
      ],
    );
  }
}
