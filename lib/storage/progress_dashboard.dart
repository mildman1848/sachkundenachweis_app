// lib/storage/progress_dashboard.dart

import '../data/questions.dart';
import '../data/question_categories.dart';
import 'progress_storage.dart'; // <--- DAS IST NEU

// Hilfsfunktion: Ermittle Kategorie-Key für eine Frage-ID
String? getCategoryKeyForQuestion(int questionId) {
  for (final entry in questionCategories.entries) {
    if (entry.value.contains(questionId)) return entry.key;
  }
  return null;
}

class ProgressDashboard {
  /// Gibt pro Kategorie zurück, wie viele Fragen gelernt sind (letzte 3 korrekt).
  static Future<Map<String, int>> getLearnedCountByCategory() async {
    final Map<String, int> categoryCounts = {};

    // Initialisiere jede Kategorie mit 0
    for (final catKey in questionCategories.keys) {
      categoryCounts[catKey] = 0;
    }

    // Prüfe für jede Frage: Ist sie gelernt?
    for (final q in questions) {
      if (await ProgressStorage.isLearned(q.id)) {
        final catKey = getCategoryKeyForQuestion(q.id);
        if (catKey != null) {
          categoryCounts[catKey] = (categoryCounts[catKey]! + 1);
        }
      }
    }
    return categoryCounts;
  }

  /// Gibt zurück, wie viele Fragen insgesamt gelernt sind (letzte 3 korrekt).
  static Future<int> getTotalLearnedCount() async {
    int count = 0;
    for (final q in questions) {
      if (await ProgressStorage.isLearned(q.id)) count++;
    }
    return count;
  }

  /// Gibt die Gesamtzahl aller Fragen zurück.
  static int getTotalQuestionCount() => questions.length;
}
