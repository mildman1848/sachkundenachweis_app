// Pfad: lib/widgets/global_progress_card.dart – Widget für globale Fortschrittsanzeige mit Animationen.

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; // Für Lottie-Animationen (Cross-OS: Assets).

class GlobalProgressCard extends StatelessWidget {
  final double percent; // Fortschrittsprozentsatz.
  final int learned; // Gelernte Fragen.
  final int total; // Gesamtanzahl Fragen.
  final int finishedCategories; // Abgeschlossene Kategorien.
  final int totalCategories; // Gesamtanzahl Kategorien.

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
    const isFinished = 1.0; // Const für statische Bedingung (Lint).

    final surfaceWithAlpha = surface.withValues(alpha: 0.18); // Deprecated behoben, alpha angepasst.

    return Card(
      elevation: 7,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      margin: const EdgeInsets.only(bottom: 24), // Const.
      child: Padding(
        padding: const EdgeInsets.all(24), // Const.
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
                const SizedBox(width: 10), // Const.
                Text(
                  "Dein Lernfortschritt",
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 14), // Const.
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 1000), // Const.
                    curve: Curves.easeOutCubic,
                    tween: Tween<double>(begin: 0, end: percent),
                    builder: (context, value, child) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 120,
                            height: 120,
                            child: CircularProgressIndicator(
                              value: 1,
                              strokeWidth: 14,
                              valueColor: AlwaysStoppedAnimation(surfaceWithAlpha),
                            ),
                          ),
                          SizedBox(
                            width: 120,
                            height: 120,
                            child: CircularProgressIndicator(
                              value: value,
                              strokeWidth: 14,
                              backgroundColor: Colors.transparent,
                              valueColor: AlwaysStoppedAnimation(
                                percent >= isFinished ? Colors.green : primary,
                              ),
                            ),
                          ),
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
                              const SizedBox(height: 4), // Const.
                              Text(
                                percent >= isFinished ? "Alles geschafft!" : "geschafft",
                                style: theme.textTheme.labelLarge,
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
                if (percent >= isFinished)
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
            const SizedBox(height: 14), // Const.
            Text(
              "$learned von $total Fragen gelernt",
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 4), // Const.
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "$finishedCategories / $totalCategories Kategorien abgeschlossen",
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(width: 8), // Const.
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