import 'package:flutter/material.dart';
import '../storage/progress_dashboard.dart';
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

  @override
  void initState() {
    super.initState();
    loadProgress();
  }

  Future<void> loadProgress() async {
    final byCategory = await ProgressDashboard.getLearnedCountByCategory();
    final totalPerCat = <String, int>{};

    for (var q in questions) {
      totalPerCat[q.category] = (totalPerCat[q.category] ?? 0) + 1;
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

    final categories = totalByCategory.keys.toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Lernfortschritt")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final cat = categories[index];
            final learned = learnedByCategory[cat] ?? 0;
            final total = totalByCategory[cat]!;
            final percent = (learned / total * 100).clamp(0, 100);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("$cat – $learned von $total gelernt"),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: percent / 100,
                  minHeight: 12,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    percent >= 100 ? Colors.green : Colors.blue,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            );
          },
        ),
      ),
    );
  }
}
