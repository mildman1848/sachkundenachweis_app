// Speicherort: test/question_categories_test.dart
// Beschreibung: Testet die Integrität der Kategorienzuordnung in lib/data/question_categories.dart.
// Überprüft, ob alle IDs von 1 bis 197 lückenlos und eindeutig einer Kategorie zugeordnet sind.
// Der Test ist plattformübergreifend kompatibel und verwendet Best Practices für Flutter-Tests.

import 'package:flutter_test/flutter_test.dart';
import 'package:sachkundenachweis/data/question_categories.dart'; // Kategorien-Datenquelle importieren.

void main() {
  group('Question Categories Tests', () {
    test('Alle IDs von 1 bis 197 sind lückenlos und eindeutig zugeordnet', () {
      // Sammle alle IDs aus den Kategorien.
      final alleIds = <int>{};
      for (final ids in questionCategories.values) {
        alleIds.addAll(ids);
      }

      // Prüfe auf doppelte IDs.
      final idCounts = <int, int>{};
      for (final ids in questionCategories.values) {
        for (final id in ids) {
          idCounts[id] = (idCounts[id] ?? 0) + 1;
        }
      }
      final doppelt = idCounts.entries.where((e) => e.value > 1).toList();
      expect(
        doppelt,
        isEmpty,
        reason: 'Doppelte IDs gefunden: ${doppelt.map((e) => e.key).join(', ')}',
      );

      // Prüfe auf fehlende oder zu viele IDs.
      const expected = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
                        21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
                        41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60,
                        61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80,
                        81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100,
                        101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120,
                        121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140,
                        141, 142, 143, 144, 145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 160,
                        161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 175, 176, 177, 178, 179, 180,
                        181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 192, 193, 194, 195, 196, 197}; // Konstante Menge für erwartete IDs (1 bis 197).
      final fehlend = expected.difference(alleIds);
      final zuviel = alleIds.difference(expected);

      expect(
        fehlend,
        isEmpty,
        reason: 'Fehlende IDs: ${fehlend.join(', ')}',
      );
      expect(
        zuviel,
        isEmpty,
        reason: 'Zu viele IDs (unerwartet): ${zuviel.join(', ')}',
      );
    });
  });
}