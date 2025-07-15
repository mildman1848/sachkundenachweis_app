// Pfad: lib/models/question_model.dart – Model-Klasse für Prüfungsfragen.

import 'package:freezed_annotation/freezed_annotation.dart'; // Für immutable Models (Best Practice: Null-Safety, Performance).

part 'question_model.freezed.dart'; // Generierte Freezed-Datei (führe `flutter pub run build_runner build` aus).
part 'question_model.g.dart'; // Generierte JSON-Serialisierung.

// Immutable Question-Model (Best Practice für Cross-OS-Kompatibilität: Pure Dart, läuft auf Android, iOS, Web).
@freezed
class Question with _$Question {
  const factory Question({
    required int id, // Eindeutige ID der Frage (Getter automatisch generiert, behebt 'id' not defined).
    required String question, // Fragentext.
    required List<String> answers, // Antwortoptionen.
    required List<int> correctAnswers, // Indizes der richtigen Antworten.
    String? image, // Optionales Bild-Pfad (z.B. assets/images/...).
  }) = _Question;

  // JSON-Serialisierung (Best Practice: Für dynamisches Laden aus JSON, behebt Parsing-Fehler).
  factory Question.fromJson(Map<String, dynamic> json) => _$QuestionFromJson(json);
}