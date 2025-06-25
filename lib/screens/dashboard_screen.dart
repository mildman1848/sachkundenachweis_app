// lib/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import '../storage/progress_dashboard.dart';
import '../storage/progress_storage.dart';
import '../data/question_categories.dart';
import '../data/questions.dart';
import 'category_detail_screen.dart';
import '../widgets/global_progress_card.dart'; // <--- NEU!

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with WidgetsBindingObserver {
  Map<String, int> learnedByCategory = {};
  Map<String, int> totalByCategory = {};
  bool loading = true;

  int globalLearned = 0;
  int globalTotal = 0;
  double globalPercent = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    loadProgress();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      loadProgress();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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

  int get finishedCategoriesCount {
    int count = 0;
    for (final catKey in categoryKeys) {
      final learned = learnedByCategory[catKey] ?? 0;
      final total = totalByCategory[catKey] ?? 0;
      if (total > 0 && learned == total) {
        count++;
      }
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final categories = categoryKeys;

    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 1000
        ? 4
        : screenWidth > 700
            ? 3
            : screenWidth > 400
                ? 2
                : 1;

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
            // Moderner Fortschrittsbereich mit Lottie und allem Drum und Dran:
            GlobalProgressCard(
              percent: globalPercent,
              learned: globalLearned,
              total: globalTotal,
              finishedCategories: finishedCategoriesCount,
              totalCategories: totalByCategory.length,
            ),
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
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () async {
                        final ids = questionCategories[catKey] ?? [];
                        final title = categoryTitles[catKey] ?? catKey;
                        final refreshed = await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => CategoryDetailScreen(
                              categoryKey: catKey,
                              categoryTitle: title,
                              questionIds: ids,
                            ),
                          ),
                        );
                        if (refreshed == true) {
                          loadProgress();
                        }
                      },
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
                                backgroundColor: Theme.of(context).colorScheme.secondary.withValues(
                                  alpha: 0.15 * 255.0,
                                  red: Theme.of(context).colorScheme.secondary.r * 255.0,
                                  green: Theme.of(context).colorScheme.secondary.g * 255.0,
                                  blue: Theme.of(context).colorScheme.secondary.b * 255.0,
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
