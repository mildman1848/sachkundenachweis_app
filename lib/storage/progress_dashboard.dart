// lib/storage/progress_dashboard.dart

import 'package:shared_preferences/shared_preferences.dart';
import '../data/questions.dart';
import '../data/question_categories.dart';

// Hilfsfunktion: Ermittle Kategorie-Key für eine Frage-ID
String? getCategoryKeyForQuestion(int questionId) {
  for (final entry in questionCategories.entries) {
    if (entry.value.contains(questionId)) return entry.key;
  }
  return null;
}

class ProgressDashboard {
  static const String _prefix = 'question_';

  /// Gibt pro Kategorie zurück, wie viele Fragen gelernt sind (d.h. >= [threshold] richtige Antworten).
  static Future<Map<String, int>> getLearnedCountByCategory({int threshold = 3}) async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, int> categoryCounts = {};

    for (final q in questions) {
      final correct = prefs.getInt('$_prefix${q.id}_correct') ?? 0;
      if (correct >= threshold) {
        final catKey = getCategoryKeyForQuestion(q.id);
        if (catKey != null) {
          categoryCounts[catKey] = (categoryCounts[catKey] ?? 0) + 1;
        }
      }
    }
    return categoryCounts;
  }

  /// Gibt zurück, wie viele Fragen insgesamt gelernt sind (d.h. >= [threshold] richtige Antworten).
  static Future<int> getTotalLearnedCount({int threshold = 3}) async {
    final prefs = await SharedPreferences.getInstance();
    int count = 0;
    for (final q in questions) {
      final correct = prefs.getInt('$_prefix${q.id}_correct') ?? 0;
      if (correct >= threshold) count++;
    }
    return count;
  }

  /// Gibt die Gesamtzahl aller Fragen zurück.
  static int getTotalQuestionCount() => questions.length;
}
