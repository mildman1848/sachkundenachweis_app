// Pfad: lib/screens/dashboard_screen.dart – Dashboard mit Lernfortschritt pro Kategorie und global.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Für State-Management (Best Practice: Asynchron).
import '../storage/progress_dashboard.dart'; // Fortschritt-Dashboard.
import '../data/question_categories.dart'; // Kategorien-Daten.
import 'category_detail_screen.dart'; // Kategorie-Detail.
import '../widgets/global_progress_card.dart'; // Globale Fortschritts-Karte.

// DashboardScreen (ConsumerStatefulWidget für Riverpod, Cross-OS: WidgetsBindingObserver für Resume).
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> with WidgetsBindingObserver {
  Map<String, int> learnedByCategory = {}; // Gelernte pro Kategorie.
  Map<String, int> totalByCategory = {}; // Total pro Kategorie.
  bool loading = true; // Lade-Flag.

  int globalLearned = 0; // Global gelernte.
  int globalTotal = 0; // Global total.
  double globalPercent = 0.0; // Globaler Prozentsatz.

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Observer für Lifecycle (Cross-OS: Resume-Refresh).
    loadProgress(); // Initial laden.
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Cleanup.
    super.dispose();
  }

  // Refresh bei Resume (Best Practice: AppLifecycleState).
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      loadProgress(); // Neu laden.
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadProgress(); // Bei Deps-Change (z.B. Theme).
  }

  // Fortschritt laden (asynchron, nutzt Provider).
  Future<void> loadProgress() async {
    setState(() {
      loading = true;
    });

    final byCategory = await ProgressDashboard.getLearnedCountByCategory(ref); // ref übergeben (behebt Argument-Fehler).
    final totalPerCat = <String, int>{};
    for (final catKey in categoryKeys) {
      totalPerCat[catKey] = questionCategories[catKey]?.length ?? 0;
    }

    final learnedGlobal = await ProgressDashboard.getTotalLearnedCount(ref); // ref übergeben.
    final totalGlobal = await ProgressDashboard.getTotalQuestionCount(ref); // ref übergeben.
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

  // Fertige Kategorien zählen (Best Practice: Getter für Klarheit).
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
        body: Center(child: CircularProgressIndicator()), // Const für Lint.
      );
    }

    const categories = categoryKeys; // Const für Kategorien.

    final screenWidth = MediaQuery.of(context).size.width; // Responsive Grid.
    final crossAxisCount = screenWidth > 1000
        ? 4
        : screenWidth > 700
            ? 3
            : screenWidth > 400
                ? 2
                : 1;

    final colorScheme = Theme.of(context).colorScheme;
    final secondary = colorScheme.secondary;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Lernfortschritt"), // Const.
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Aktualisieren",
            onPressed: loadProgress,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16), // Const.
        child: Column(
          children: [
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

                  final Color backgroundColor = secondary.withValues(alpha: 0.15); // Alpha angepasst.

                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Semantics(  // Accessibility (Best Practice: Screen-Reader).
                      label: categoryTitles[catKey] ?? catKey,
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
                          padding: const EdgeInsets.all(16), // Const.
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                categoryTitles[catKey] ?? catKey,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const Spacer(), // Const.
                              Text(
                                "$learned von $total gelernt",
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 6), // Const.
                              ClipRRect(
                                borderRadius: BorderRadius.circular(7),
                                child: LinearProgressIndicator(
                                  value: percent,
                                  minHeight: 12,
                                  backgroundColor: backgroundColor,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    percent >= 1.0
                                        ? Colors.green
                                        : secondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
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