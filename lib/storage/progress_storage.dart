import 'package:shared_preferences/shared_preferences.dart';

class ProgressStorage {
  static const String _prefix = 'question_';

  // Gibt zurück, wie oft eine Frage korrekt beantwortet wurde
  static Future<int> getCorrectCount(int questionId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('$_prefix${questionId}_correct') ?? 0;
  }

  // Erhöht den Zähler für korrekt beantwortete Frage um 1
  static Future<void> incrementCorrect(int questionId) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt('$_prefix${questionId}_correct') ?? 0;
    await prefs.setInt('$_prefix${questionId}_correct', current + 1);
  }

  // Setzt die Fortschrittsdaten für eine Frage zurück
  static Future<void> resetProgress(int questionId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_prefix${questionId}_correct');
  }

  // Gibt zurück, ob eine Frage gelernt ist (≥ threshold mal korrekt)
  static Future<bool> isLearned(int questionId, {int threshold = 3}) async {
    final count = await getCorrectCount(questionId);
    return count >= threshold;
  }
}
