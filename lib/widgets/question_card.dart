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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                question.imageAsset!,
                height: 200,
                fit: BoxFit.contain,
              ),
            ),
          ),
        const SizedBox(height: 16),
        ...List.generate(question.options.length, (index) {
          final isSelected = selectedAnswers.contains(index);

          Color? tileColor;
          if (feedbackColor != null) {
            tileColor = feedbackColor!(index);
          } else if (isSelected && !submitted) {
            // Nutze Theme Secondary für Auswahl
            tileColor = Theme.of(context).colorScheme.secondary.withOpacity(0.13);
          }

          return Card(
            elevation: 2,
            color: tileColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(13),
            ),
            child: ListTile(
              onTap: () => onToggle(index),
              leading: Checkbox(
                value: isSelected,
                onChanged: (_) => onToggle(index),
                activeColor: Theme.of(context).colorScheme.primary,
              ),
              title: Text(
                question.options[index],
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              trailing: feedbackIcon != null ? Icon(feedbackIcon!(index)) : null,
            ),
          );
        }),
      ],
    );
  }
}
