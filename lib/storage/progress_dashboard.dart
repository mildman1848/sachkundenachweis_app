import 'package:shared_preferences/shared_preferences.dart';
import '../data/questions.dart';
import '../models/question_model.dart';

class ProgressDashboard {
  static const String _prefix = 'question_';

  // Hilfsfunktion – korrekt beantwortet?
  static Future<int> _getCorrectCount(int id) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('$_prefix${id}_correct') ?? 0;
  }

  // Gibt pro Kategorie zurück, wie viele Fragen gelernt sind (>= threshold)
  static Future<Map<String, int>> getLearnedCountByCategory({int threshold = 3}) async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, int> categoryCounts = {};

    for (var q in questions) {
      final correct = prefs.getInt('$_prefix${q.id}_correct') ?? 0;
      if (correct >= threshold) {
        categoryCounts[q.category] = (categoryCounts[q.category] ?? 0) + 1;
      }
    }

    return categoryCounts;
  }

  // Gibt zurück, wie viele Fragen insgesamt gelernt sind
  static Future<int> getTotalLearnedCount({int threshold = 3}) async {
    final prefs = await SharedPreferences.getInstance();
    int count = 0;
    for (var q in questions) {
      final correct = prefs.getInt('$_prefix${q.id}_correct') ?? 0;
      if (correct >= threshold) count++;
    }
    return count;
  }

  // Gibt die Gesamtzahl aller Fragen zurück
  static int getTotalQuestionCount() => questions.length;
}
