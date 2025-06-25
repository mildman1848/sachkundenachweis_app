// lib/storage/progress_storage.dart

import 'package:shared_preferences/shared_preferences.dart';
import 'package:sachkundenachweis/data/questions.dart'; // <- KORREKT!

class ProgressStorage {
  static const String _prefix = 'question_';

  /// Gibt die letzten 3 Antwort-Ergebnisse als Liste von bool zurück (true = korrekt).
  static Future<List<bool>> getLastThreeResults(int questionId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('$_prefix${questionId}_last3') ?? [];
    return raw.map((e) => e == '1').toList();
  }

  /// Fügt das Ergebnis der aktuellen Beantwortung hinzu (true = korrekt, false = falsch).
  static Future<void> addAnswerResult(int questionId, bool isCorrect) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('$_prefix${questionId}_last3') ?? [];
    final results = raw.map((e) => e == '1').toList();
    // Neueste Antwort vorne anfügen
    results.insert(0, isCorrect);
    if (results.length > 3) results.length = 3;
    final saveList = results.map((e) => e ? '1' : '0').toList();
    await prefs.setStringList('$_prefix${questionId}_last3', saveList);
  }

  /// Setzt den Fortschritt für eine Frage zurück.
  static Future<void> resetProgress(int questionId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_prefix${questionId}_last3');
  }

  /// Setzt den Fortschritt für alle Fragen zurück.
  static Future<void> resetAllProgress(Iterable<int> questionIds) async {
    final prefs = await SharedPreferences.getInstance();
    for (final id in questionIds) {
      await prefs.remove('$_prefix${id}_last3');
    }
  }

  /// Gibt zurück, ob eine Frage gelernt ist (3 mal in Folge korrekt).
  static Future<bool> isLearned(int questionId) async {
    final results = await getLastThreeResults(questionId);
    return results.length == 3 && results.every((e) => e);
  }

  /// Gibt die Anzahl aller Fragen zurück, die gelernt sind (3x in Folge korrekt).
  static Future<int> getTotalLearnedCount() async {
    int count = 0;
    for (final q in questions) {
      if (await isLearned(q.id)) count++;
    }
    return count;
  }
}