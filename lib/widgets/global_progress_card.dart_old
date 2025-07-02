// lib/widgets/global_progress_card.dart

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class GlobalProgressCard extends StatelessWidget {
  final double percent;
  final int learned;
  final int total;
  final int finishedCategories;
  final int totalCategories;

  const GlobalProgressCard({
    super.key,
    required this.percent,
    required this.learned,
    required this.total,
    required this.finishedCategories,
    required this.totalCategories,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final surface = theme.colorScheme.surface;
    final percentDisplay = (percent * 100).round();
    final isFinished = percent >= 1.0;

    return Card(
      elevation: 7,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      margin: const EdgeInsets.only(bottom: 24),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Headline + Lottie-Trophy
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 40,
                  height: 40,
                  child: Lottie.asset(
                    'assets/animations/trophy.json',
                    repeat: true,
                    animate: true,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  "Dein Lernfortschritt",
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Donut-Chart mit Feuerwerk als Overlay bei 100%
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeOutCubic,
                    tween: Tween<double>(begin: 0, end: percent),
                    builder: (context, value, child) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          // Hintergrundkreis
                          SizedBox(
                            width: 120,
                            height: 120,
                            child: CircularProgressIndicator(
                              value: 1,
                              strokeWidth: 14,
                              valueColor: AlwaysStoppedAnimation(
                                surface.withValues(
                                  alpha: 0.18 * 255.0,
                                  red: surface.r * 255.0,
                                  green: surface.g * 255.0,
                                  blue: surface.b * 255.0,
                                ),
                              ),
                            ),
                          ),
                          // Fortschrittskreis
                          SizedBox(
                            width: 120,
                            height: 120,
                            child: CircularProgressIndicator(
                              value: value,
                              strokeWidth: 14,
                              backgroundColor: Colors.transparent,
                              valueColor: AlwaysStoppedAnimation(
                                isFinished ? Colors.green : primary,
                              ),
                            ),
                          ),
                          // Prozent-Anzeige zentriert
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "$percentDisplay%",
                                style: theme.textTheme.displayMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isFinished ? "Alles geschafft!" : "geschafft",
                                style: theme.textTheme.labelLarge,
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
                if (isFinished)
                  // Feuerwerk-Overlay
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Lottie.asset(
                        'assets/animations/firework.json',
                        repeat: true,
                        animate: true,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              "$learned von $total Fragen gelernt",
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "$finishedCategories / $totalCategories Kategorien abgeschlossen",
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(width: 8),
                Icon(
                  finishedCategories == totalCategories
                      ? Icons.emoji_events_rounded
                      : Icons.category_rounded,
                  color: finishedCategories == totalCategories
                      ? Colors.amber
                      : theme.colorScheme.primary,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
