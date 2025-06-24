// lib/data/question_categories.dart
// Automatisch generiert aus Sachkundefragen-neu-ab-01.01.2025.pdf

// Alle Kategorie-Keys in Reihenfolge für z.B. Dropdown, Navigation etc.
const List<String> categoryKeys = [
  'ausdrucksverhalten_bilder',
  'ausdrucksverhalten_fragen',
  'rassen',
  'hund_und_kind',
  'umgang_verstaendnis',
  'training',
  'strafen',
  'hundewahl',
  'hundebegegnungen',
  'aufzucht',
  'hilfsmittel',
  'probleme_verstaendnis',
  'probleme_ursachen_vorbeugen',
  'probleme_massnahmen',
  'rechtliches',
  'haltung',
  'gesundheit',
  'geschlechter',
  'krankheiten',
  'oeffentlichkeit',
];

// Kategorie-Key → Deutscher Titel
const Map<String, String> categoryTitles = {
  'ausdrucksverhalten_bilder': 'Ausdrucksverhalten Bilder',
  'ausdrucksverhalten_fragen': 'Ausdrucksverhalten Fragen',
  'rassen': 'Rassen',
  'hund_und_kind': 'Hund und Kind',
  'umgang_verstaendnis': 'Umgang und Verständnis',
  'training': 'Training',
  'strafen': 'Strafen',
  'hundewahl': 'Hundewahl',
  'hundebegegnungen': 'Hundebegegnungen',
  'aufzucht': 'Aufzucht',
  'hilfsmittel': 'Hilfsmittel',
  'probleme_verstaendnis': 'Probleme – Verständnis',
  'probleme_ursachen_vorbeugen': 'Probleme – Ursachen und Vorbeugen',
  'probleme_massnahmen': 'Probleme – Maßnahmen',
  'rechtliches': 'Rechtliches',
  'haltung': 'Haltung',
  'gesundheit': 'Gesundheit',
  'geschlechter': 'Geschlechter',
  'krankheiten': 'Krankheiten',
  'oeffentlichkeit': 'Öffentlichkeit',
};

// Kategorie-Key → Frage-IDs (direkt aus dem Fragen-PDF, Reihenfolge original)
final Map<String, List<int>> questionCategories = {
  'ausdrucksverhalten_bilder': [6, 16, 26, 46, 56, 65, 75],
  'ausdrucksverhalten_fragen': [1, 31, 41, 51, 61, 86, 88, 121, 126, 167],
  'rassen': [2, 12, 161, 171, 184, 185, 186, 187, 196, 197],
  'hund_und_kind': [3, 28, 33, 38, 43, 48, 58, 107, 110, 112],
  'umgang_verstaendnis': [18, 62, 78, 76, 89, 91, 96, 131, 157, 159],
  'training': [70, 134, 136, 141, 143, 147, 162, 164, 165, 166],
  'strafen': [5, 9, 59, 99, 129, 138, 145, 149, 150, 192],
  'hundewahl': [17, 22, 27, 45, 47, 49, 52, 54, 57, 173],
  'hundebegegnungen': [8, 11, 13, 25, 80, 93, 98, 109, 122, 139],
  'aufzucht': [4, 14, 19, 29, 34, 39, 44, 63, 68, 73],
  'hilfsmittel': [7, 10, 15, 20, 36, 84, 87, 90, 100, 168],
  'probleme_verstaendnis': [21, 24, 67, 72, 82, 103, 114, 119, 123, 151],
  'probleme_ursachen_vorbeugen': [85, 117, 132, 153, 155, 169, 172, 190, 193, 195],
  'probleme_massnahmen': [23, 71, 77, 81, 92, 125, 160, 163, 170, 188],
  'rechtliches': [30, 35, 50, 60, 69, 74, 79, 174, 182, 194],
  'haltung': [32, 37, 42, 55, 64, 66, 83, 101, 120, 175],
  'gesundheit': [94, 97, 105, 127, 130, 140, 158, 178, 179, 183],
  'geschlechter': [113, 115, 118, 124, 133, 135, 137, 148, 177, 189],
  'krankheiten': [40, 142, 144, 146, 152, 154, 156, 176, 180, 181],
  'oeffentlichkeit': [53, 95, 102, 104, 106, 108, 111, 116, 128, 191],
};
