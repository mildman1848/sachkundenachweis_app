// lib/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import '../storage/progress_dashboard.dart';
import '../storage/progress_storage.dart';
import '../data/question_categories.dart';
import '../data/questions.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, int> learnedByCategory = {};
  Map<String, int> totalByCategory = {};
  bool loading = true;

  int globalLearned = 0;
  int globalTotal = 0;
  double globalPercent = 0.0;

  @override
  void initState() {
    super.initState();
    loadProgress();
  }

  Future<void> loadProgress() async {
    setState(() {
      loading = true;
    });

    final byCategory = await ProgressDashboard.getLearnedCountByCategory();
    final totalPerCat = <String, int>{};
    for (final catKey in categoryKeys) {
      totalPerCat[catKey] = questionCategories[catKey]?.length ?? 0;
    }

    // Globale Fortschrittsberechnung
    final learnedGlobal = await ProgressStorage.getTotalLearnedCount();
    final totalGlobal = questions.length;
    final percentGlobal = totalGlobal == 0 ? 0.0 : learnedGlobal / totalGlobal;

    setState(() {
      learnedByCategory = byCategory;
      totalByCategory = totalPerCat;
      globalLearned = learnedGlobal;
      globalTotal = totalGlobal;
      globalPercent = percentGlobal;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final categories = categoryKeys;

    // Responsive Spaltenanzahl
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 1000
        ? 4
        : screenWidth > 700
            ? 3
            : screenWidth > 400
                ? 2
                : 1;

    final secondary = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Lernfortschritt"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Aktualisieren",
            onPressed: loadProgress,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Globale Fortschrittsanzeige oben
            Center(
              child: Column(
                children: [
                  Text(
                    "Globaler Fortschritt",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 160,
                    height: 160,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: globalPercent,
                          strokeWidth: 12,
                          backgroundColor: secondary.withValues(
                            alpha: 0.18 * 255.0,
                            red: secondary.r * 255.0,
                            green: secondary.g * 255.0,
                            blue: secondary.b * 255.0,
                          ),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            globalPercent >= 1.0
                                ? Colors.green
                                : Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "${(globalPercent * 100).round()}%",
                              style: Theme.of(context).textTheme.headlineLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "$globalLearned von $globalTotal Fragen gelernt",
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 2.6,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final catKey = categories[index];
                  final learned = learnedByCategory[catKey] ?? 0;
                  final total = totalByCategory[catKey]!;
                  final percent = (learned / total).clamp(0.0, 1.0);

                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            categoryTitles[catKey] ?? catKey,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const Spacer(),
                          Text(
                            "$learned von $total gelernt",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(7),
                            child: LinearProgressIndicator(
                              value: percent,
                              minHeight: 12,
                              backgroundColor: secondary.withValues(
                                alpha: 0.15 * 255.0,
                                red: secondary.r * 255.0,
                                green: secondary.g * 255.0,
                                blue: secondary.b * 255.0,
                              ),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                percent >= 1.0
                                    ? Colors.green
                                    : Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
