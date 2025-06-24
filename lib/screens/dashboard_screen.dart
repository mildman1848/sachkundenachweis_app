// lib/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import '../storage/progress_dashboard.dart';
import '../data/question_categories.dart'; // <--- NEU

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, int> learnedByCategory = {};
  Map<String, int> totalByCategory = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadProgress();
  }

  Future<void> loadProgress() async {
    final byCategory = await ProgressDashboard.getLearnedCountByCategory();
    // Ermittelt die Gesamtzahl pro Kategorie anhand der questionCategories-Map
    final totalPerCat = <String, int>{};
    for (final catKey in categoryKeys) {
      totalPerCat[catKey] = questionCategories[catKey]?.length ?? 0;
    }
    setState(() {
      learnedByCategory = byCategory;
      totalByCategory = totalPerCat;
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

    // Gesamter Fortschritt
    final totalLearned = learnedByCategory.values.fold<int>(0, (a, b) => a + b);
    final totalQuestions = totalByCategory.values.fold<int>(0, (a, b) => a + b);
    final overallPercent = totalQuestions == 0 ? 0.0 : totalLearned / totalQuestions;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Lernfortschritt"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Aktualisieren",
            onPressed: () {
              setState(() {
                loading = true;
              });
              loadProgress();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Gesamtfortschritt – als schicker Kreis
            Center(
              child: SizedBox(
                width: 160,
                height: 160,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: overallPercent,
                      strokeWidth: 12,
                      backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.18),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        overallPercent >= 1.0
                            ? Colors.green
                            : Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "${(overallPercent * 100).round()}%",
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "$totalLearned von $totalQuestions Fragen gelernt",
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ],
                ),
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
                            categoryTitles[catKey] ?? catKey, // NEU: schöner Name
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
                              backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.15),
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
