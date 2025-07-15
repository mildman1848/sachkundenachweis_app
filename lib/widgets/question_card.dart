// Pfad: lib/widgets/question_card.dart – Wiederverwendbares Widget für Frage-Darstellung mit interaktiver Auswahl.

import 'package:flutter/material.dart';
import '../models/question_model.dart'; // Question-Model.

// QuestionCard (StatefulWidget für Scroll-Handling bei neuen Fragen).
class QuestionCard extends StatefulWidget {
  final Question question; // Frage-Daten.
  final Set<int> selectedAnswers; // Ausgewählte Antworten.
  final bool submitted; // Abgeschickt-Flag.
  final void Function(int) onToggle; // Toggle-Callback.
  final IconData? Function(int)? feedbackIcon; // Feedback-Icon-Funktion.
  final Color? Function(int)? feedbackColor; // Feedback-Farben-Funktion.

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
  State<QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  final ScrollController _scrollController = ScrollController(); // Scroll-Controller (Best Practice: Wiederverwendung).

  @override
  void didUpdateWidget(covariant QuestionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.id != widget.question.id) {
      _scrollController.jumpTo(0); // Scrollt bei neuer Frage nach oben (Best Practice: UX).
    }
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Cleanup (Best Practice: Ressourcenfreigabe).
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final secondary = Theme.of(context).colorScheme.secondary;

    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Frage ${widget.question.id}: ${widget.question.question}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16), // Const für Lint.
          if (widget.question.image != null)
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(
                  widget.question.image!,
                  height: 200,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          const SizedBox(height: 16), // Const.
          ...List.generate(widget.question.answers.length, (index) {
            final isSelected = widget.selectedAnswers.contains(index);

            Color? tileColor;
            if (widget.feedbackColor != null) {
              tileColor = widget.feedbackColor!(index);
            } else if (isSelected && !widget.submitted) {
              tileColor = secondary.withValues(alpha: 0.13); // Deprecated behoben, alpha angepasst.
            }

            return Semantics(  // Accessibility (Best Practice: Screen-Reader).
              label: widget.question.answers[index],
              child: Card(
                elevation: 2,
                color: tileColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), // Const.
                  onTap: () => widget.onToggle(index),
                  leading: Padding(
                    padding: const EdgeInsets.only(right: 8.0), // Const.
                    child: Checkbox(
                      value: isSelected,
                      onChanged: (_) => widget.onToggle(index),
                      activeColor: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  title: Text(
                    widget.question.answers[index],
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  trailing: widget.feedbackIcon != null ? Icon(widget.feedbackIcon!(index)) : null,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}