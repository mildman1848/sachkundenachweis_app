// test/questions_integrity_test.dart
// Testet, ob alle 197 Fragen in /lib/data/questions.dart enthalten sind und keine Duplikate vorliegen.

import 'package:flutter_test/flutter_test.dart';
import 'package:sachkundenachweis/data/questions.dart';

void main() {
  test('Alle Fragen sind eindeutig, lückenlos und komplett', () {
    final ids = questions.map((q) => q.id).toList();

    // Test auf Duplikate
    final doppel = ids.where((id) => ids.where((i) => i == id).length > 1).toSet();
    expect(doppel.isEmpty, true, reason: 'Doppelte IDs: ${doppel.join(", ")}');

    // Test auf Lücken
    final expected = List.generate(197, (i) => i + 1).toSet();
    final vorhanden = ids.toSet();
    final fehlend = expected.difference(vorhanden);
    final zuviel = vorhanden.difference(expected);

    expect(fehlend.isEmpty, true, reason: 'Fehlende IDs: ${fehlend.join(", ")}');
    expect(zuviel.isEmpty, true, reason: 'IDs außerhalb von 1–197: ${zuviel.join(", ")}');
    expect(questions.length, 197, reason: 'Fragenanzahl stimmt nicht: ${questions.length}/197');
  });
}
