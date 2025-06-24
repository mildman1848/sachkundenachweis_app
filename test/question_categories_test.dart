// test/question_categories_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:sachkundenachweis/data/question_categories.dart';

void main() {
  test('Alle IDs von 1 bis 197 sind lückenlos und eindeutig zugeordnet', () {
    final alleIds = <int>{};

    // Alle IDs sammeln
    for (final ids in questionCategories.values) {
      alleIds.addAll(ids);
    }

    // Doppelte IDs prüfen
    final idCounts = <int, int>{};
    for (final ids in questionCategories.values) {
      for (final id in ids) {
        idCounts[id] = (idCounts[id] ?? 0) + 1;
      }
    }
    final doppelt = idCounts.entries.where((e) => e.value > 1).toList();
    expect(doppelt, isEmpty, reason: 'Doppelte IDs gefunden: ${doppelt.map((e) => e.key).join(', ')}');

    // Fehlende/zu viele IDs prüfen
    final expected = Set.from(List.generate(197, (i) => i + 1));
    final fehlend = expected.difference(alleIds);
    final zuviel = alleIds.difference(expected);

    expect(fehlend, isEmpty, reason: 'Fehlende IDs: ${fehlend.join(', ')}');
    expect(zuviel, isEmpty, reason: 'Zu viele IDs (unerwartet): ${zuviel.join(', ')}');
  });
}
