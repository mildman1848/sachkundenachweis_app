// Pfad: lib/storage/progress_dashboard.dart – Hilfsfunktionen für Fortschrittsberechnungen pro Kategorie und global.

import 'package:flutter_riverpod/flutter_riverpod.dart'; // Für State-Management (Best Practice: Asynchron).
import '../data/questions.dart'; // questionsProvider importieren (behebt 'questions' undefined).
import '../data/question_categories.dart'; // Kategorien-Daten.
import 'progress_storage.dart'; // Fortschritt-Speicherung.

// Hilfsfunktion: Ermittle Kategorie-Key für eine Frage-ID (Best Practice: Encapsulation).
String? getCategoryKeyForQuestion(int questionId) {
  for (final entry in questionCategories.entries) {
    if (entry.value.contains(questionId)) return entry.key;
  }
  return null;
}

// ProgressDashboard für Fortschrittsberechnungen (Best Practice: Asynchrone Methoden).
class ProgressDashboard {
  /// Gibt pro Kategorie zurück, wie viele Fragen gelernt sind (letzte 3 korrekt).
  static Future<Map<String, int>> getLearnedCountByCategory(WidgetRef ref) async {
    final Map<String, int> categoryCounts = {};

    // Initialisiere jede Kategorie mit 0 (Best Practice: Klarheit).
    for (final catKey in questionCategories.keys) {
      categoryCounts[catKey] = 0;
    }

    // Fragen asynchron laden (behebt 'questions' undefined).
    final questionsData = await ref.read(questionsProvider.future);

    // Prüfe für jede Frage: Ist sie gelernt?
    for (final q in questionsData) {
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
  static Future<int> getTotalLearnedCount(WidgetRef ref) async {
    int count = 0;
    final questionsData = await ref.read(questionsProvider.future); // Asynchron (behebt undefined).
    for (final q in questionsData) {
      if (await ProgressStorage.isLearned(q.id)) count++;
    }
    return count;
  }

  /// Gibt die Gesamtzahl aller Fragen zurück (asynchron für Konsistenz).
  static Future<int> getTotalQuestionCount(WidgetRef ref) async {
    final questionsData = await ref.read(questionsProvider.future);
    return questionsData.length;
  }
}