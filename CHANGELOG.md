# Changelog

All notable changes to this project will be documented in this file. See [standard-version](https://github.com/conventional-changelog/standard-version) for commit guidelines.

### 1.0.9 (2025-07-15)

### 1.0.8 (2025-07-15)

### 2.0.0
## 2025-07-15 - Verbesserungen in lib/screens/category_learning_screen.dart
- Deprecated withOpacity durch withValues ersetzt (behebt Precision-Loss-Warnung, Best Practice: Genauigkeit).
- Deutsche Kommentare und Pfad-Kommentar beibehalten.
- Cross-OS-Kompatibilität: Vibration-Checks, responsive UI (MediaQuery implizit).
- Best Practices: Const für Konstanten (z.B. Icons, Texts, EdgeInsets – wo möglich final zu const geändert).
- Riverpod-Integration für Theme und Fragen beibehalten.
## 2025-07-15 - Verbesserungen in lib/screens/category_learning_screen.dart
- Wechsel zu ConsumerStatefulWidget für Riverpod (behebt Provider.of, nutzt ref für themeNotifierProvider).
- Asynchrone Frage-Ladung mit questionsProvider (FutureBuilder, behebt 'questions' undefined).
- Haptic-Feedback bei Toggle/Submit hinzugefügt (Vibration, Cross-OS-Check).
- Accessibility: Semantics für Cards/ListTiles (Screen-Reader).
- Deutsche Kommentare und Pfad-Kommentar ergänzt.
- Responsive: MediaQuery implizit, Padding angepasst.
- Best Practices: Null-Safety, required Fields, Error-Handling in Futures.
## 2025-07-15 - Verbesserungen in lib/screens/category_detail_screen.dart
- Wechsel zu ConsumerStatefulWidget für Riverpod (behebt 'questions' undefined durch questionsProvider).
- Asynchrone Lade-Logik mit ref.read(questionsProvider.future) integriert (Best Practice: FutureBuilder für Loading).
- Deutsche Kommentare und Pfad-Kommentar hinzugefügt.
- Accessibility: Semantics für ListTiles (Screen-Reader-Support, Best Practice).
- Cross-OS-Kompatibilität: PopScope für Back-Handling (Android/iOS), responsive Padding.
- Refresh-Logik bei Navigation beibehalten.
## 2025-07-15 - Überarbeitung von pubspec.yaml
- flutter_riverpod beibehalten und Version aktualisiert (Best Practice: State-Management).
- Freezed/JSON-Deps hinzugefügt (freezed_annotation, json_annotation, freezed, build_runner, json_serializable) für immutable Models und JSON-Loading.
- Vibration hinzugefügt für Haptic-Feedback (Cross-OS: Platform-Checks).
- Flutter_localizations für Localization-Vorbereitung (Best Practice).
- Fl_chart-Version aktualisiert, iOS-Support für Icons hinzugefügt.
- Assets: questions.json für dynamische Daten.
- Dev_deps: flutter_lints aktualisiert.
- SDK-Range auf >=3.0.0 für Null-Safety und Kompatibilität.
- Fonts/Assets beibehalten, Cross-OS optimiert (z.B. WebP-Empfehlung).
## 2025-07-15 - Überarbeitung von lib/models/question_model.dart
- Wechsel zu freezed für immutable Model (Best Practice: Null-Safety, Performance, JSON-Support).
- Hinzufügung von fromJson und toJson (via json_serializable) für JSON-Integration.
- Deutsche Kommentare und Pfad-Kommentar ergänzt.
- Cross-OS-Kompatibilität: Pure Dart, läuft auf allen Plattformen (Android, iOS, Web).
- pubspec.yaml: freezed_annotation, json_annotation hinzugefügt; freezed, build_runner als dev_deps (führe `flutter pub run build_runner build` aus).
## 2025-07-15 - Behebung in lib/data/questions.dart und lib/models/question_model.dart
- Freezed-Integration vervollständigt (fromJson hinzugefügt, behebt Method not defined).
- pubspec.yaml: freezed_annotation, freezed, json_annotation, build_runner hinzugefügt (dev_deps für build).
- Deutsche Kommentare ergänzt.
- Cross-OS: JSON-Loading mit rootBundle (Mobile/Web).
- Führe `flutter pub run build_runner build` aus, um Parts zu generieren.
## 2025-07-14 - Neue GitHub Action und Skript für PDF-Update
- GitHub Action workflow für tägliches PDF-Check und Update erstellt.
- Python-Skript update_questions.py für Download, Change-Check (Hash), OCR/Text-Extraktion und JSON-Update.
- Parser-Stub für Fragen/Lösungen (anpassen an PDF-Struktur).
- Deps: requests, hashlib, fitz, PIL, pytesseract.
## 2025-07-13 - Verbesserungen in lib/main.dart
- Wechsel von Provider zu Riverpod für besseres State-Management (Best Practice: Immutable und testbar).
- Entfernung redundanter asynchroner Lade-Logik und MainNavigation-Widget (Vereinfachung: Lazy-Loading via Riverpod).
- Hinzufügung deutscher Kommentare und Pfad-Kommentar am Anfang.
- Cross-OS-Kompatibilität: Plattform-Checks (Platform.isIOS, kIsWeb), System-Theme-Sync, Accessibility mit Semantics.
- Error-Handling verbessert (FlutterError.onError).
- Kürzung des Codes für Effizienz, ohne Funktionalität zu verlieren.
- Riverpod-Dependency hinzugefügt und Imports korrigiert.
- kDebugMode importiert und print durch debugPrint ersetzt (Lint-freundlich).
- themeNotifierProvider in theme_notifier.dart definiert.
- Cross-OS-Checks und Accessibility hinzugefügt.
- Code vereinfacht, ohne Originalfunktionalität zu verlieren.
## 2025-07-13 - Verbesserungen in lib/theme/theme_notifier.dart
- Wechsel von ChangeNotifier zu StateNotifier mit Riverpod (Best Practice: Immutable State, Kompatibilität mit main.dart).
- Definition von themeNotifierProvider hinzugefügt.
- Deutsche Kommentare und Pfad-Kommentar ergänzt.
- Cross-OS: Brightness.system für Theme-Sync (Android, iOS, Web).
- Vereinfachung von Switch-Cases und Vorbereitung für Material You.
- Persistent Storage beibehalten, Debugging mit debugPrint (Lint-freundlich).
## 2025-07-13 - Weitere Behebungen für Riverpod-Integration
- Import zu flutter_riverpod korrigiert (behebt ProviderScope, ConsumerWidget, WidgetRef usw.).
- pubspec.yaml: flutter_riverpod empfohlen.
- @override für initState und build hinzugefügt (behebt Override-Warnungen).
- Typ-Korrekturen für ConsumerStatefulWidget und ConsumerState (behebt Extend-Fehler und setState).
- Cross-OS und Best Practices beibehalten.
## 2025-07-13 - Behebung weiterer Fehler in lib/main.dart
- getTheme-Aufruf korrigiert zu getThemeData mit Brightness (behebt 'getTheme' nicht definiert).
- themeMode zu materialThemeMode geändert (behebt Typ-Zuweisung AppThemeMode -> ThemeMode).
- Named 'key'-Parameter zu allen Widget-Konstruktoren hinzugefügt (behebt Konstruktor-Warnung).
- Deutsche Kommentare und Cross-OS-Kompatibilität beibehalten.
- Best Practices: MediaQuery für Brightness, super(key: key) für Widgets.
## 2025-07-13 - Behebung der Lint-Warnung in lib/main.dart
- Variable 'brightness' integriert in getThemeData-Aufruf für currentTheme (behebt ungenutzte Variable).
- Theme-Abruf dynamisch gemacht basierend auf Brightness (Best Practice: Responsiv und reduziert Duplikation).
- Deutsche Kommentare und Cross-OS-Kompatibilität (MediaQuery) beibehalten.
## 2025-07-13 - Verbesserungen in lib/data/question_categories.dart
- Deutsche Kommentare und Pfad-Kommentar hinzugefügt.
- Typ-Annotationen für Listen/Maps ergänzt (Best Practice: Null-Safety und Klarheit).
- Hilfsfunktionen getCategoryTitle und getQuestionIdsByCategory hinzugefügt (skalierbar, z.B. für dynamische Abfragen).
- Cross-OS-Kompatibilität: Pure Dart, läuft überall (keine Änderungen nötig).
- Struktur beibehalten, aber für JSON-Migration vorbereitet (z.B. bei PDF-Updates).
## 2025-07-13 - Verbesserungen in lib/data/questions.dart
- Deutsche Kommentare und Pfad-Kommentar hinzugefügt.
- Migration zu JSON (assets/questions.json) für dynamische Updates vorbereitet (Best Practice: Skalierbar, einfache PDF-Änderungen).
- Riverpod-Provider für Lazy-Loading integriert (Cross-OS: rootBundle für Mobile/Web).
- Freezed-Integration für Question-Model empfohlen (immutable, Null-Safety).
- Hilfsfunktion getQuestionById hinzugefügt.
- Daten auf Aktualität überprüft (passt zu PDF ab 01.01.2025).


### 1.0.7 (2025-07-02)


### Bug Fixes

* Update Git tagging process in build workflow ([2e0f262](https://github.com/mildman1848/sachkundenachweis_app/commit/2e0f2620471a4d7e41702eda8c441ad621617889))

## [1.0.6] – 2025-07-03

### 🚀 Features
- feat(quiz): automatische Scroll-Position bei Fragewechsel (#123)
- feat(theme): ThemeCards mit Farbvorschau und Auswahlhighlight (#125)

### 🐛 Bug Fixes
- fix(storage): Fragenfortschritt wurde nicht korrekt aktualisiert (#124)

## [1.0.5] – 2025-07-03

### 🐛 Bug Fixes
- fix(questions): Fragen waren teilweise veraltet.

## [1.0.4] – 2025-06-26

### Neu/Funktionen
- **Offizieller Fragenkatalog 2025 integriert:** Alle 197 Fragen, Antworten und Lösungen wurden exakt aus den offiziellen PDFs für die Sachkundeprüfung NRW 2025 übernommen und auf Richtigkeit abgeglichen.
- **Kategorien-Zuordnung aktualisiert:** Die Datei `question_categories.dart` enthält jetzt die offiziellen Kategorien und exakte Zuordnung der Fragen laut Lösungskatalog 2025.
- **Quiz-Flow:** Die Zurück-Funktion im Quiz-Screen wurde entfernt. Ein Zurücknavigieren aus dem Quiz ist nicht mehr möglich.
- **Quiz-Abschluss:** Nach Beantwortung der letzten Frage bleibt der Quiz-Screen bestehen (optional Abschlussanzeige möglich).
- **App-Icon-Automatisierung:** Das Android-App-Icon wird im CI/CD-Build-Prozess automatisch gesetzt (`flutter_launcher_icons` läuft automatisch in GitHub Actions).
- **Build-Workflow verbessert:** GitHub Actions-Workflow erzeugt ab sofort immer das korrekte Icon im APK-Build.

### Technisch/UX
- **Keine Nutzung von BuildContext nach async-gaps:** Alle Kontextzugriffe nach `await` sind jetzt mit `if (!mounted) return;` abgesichert.
- **Refactoring:** Entfernen von SnackBars, `Navigator.pop`, und Back-Button im Quiz.
- **Fragen- und Kategorien-Struktur:** Volle Synchronisierung mit aktuellen PDF-Vorlagen.
- **Code-Aufräumung:** Nur gezielte Änderungen an Navigation und Zuordnung; UI-Logik und Farblogik bleiben unverändert.

---

## [1.0.3] – 2025-06-25

### Neu/Funktionen
- **Dashboard Redesign:** Moderner, motivierender Fortschrittsbereich mit animiertem Donut-Chart, Lottie-Trophäe und Feuerwerk bei 100 %.
- **Kategorien-Detail:** Klick auf eine Kategorie zeigt alle zugehörigen Fragen samt 3 Antwort-Indikatoren (grün/rot/grau für richtig/falsch/unbeantwortet).
- **Direktbeantwortung:** Klick auf eine Frage öffnet den Einzel-Fragen-Modus mit Antwort-Feedback und Indikatoren.
- **Lernmodus:** Neuer „Lernmodus“ pro Kategorie: Alle Fragen der Kategorie werden nacheinander präsentiert, Fortschritt wird angezeigt, Abschluss-Screen nach Durchlauf.
- **Automatische Fortschrittsaktualisierung:** Nach Beantwortung einer Frage oder im Lernmodus werden CategoryScreen und Dashboard automatisch neu geladen.
- **PopScope-Integration:** Alle relevanten Screens nutzen jetzt das moderne PopScope/onPopInvokedWithResult für zuverlässiges und DSGVO-freundliches Navigieren (Flutter 3.22+).
- **Theme-Auswahl stabil & persistent:** Verbesserte Umsetzung des ThemeNotifiers inkl. Darkmode, Bright Minimal & Calm Nature Themes.
- **Zukunftssicher:** Umstellung aller Widgets und Logik auf Flutter 3.22+ (mit .withValues statt .withOpacity, keine deprecated Color-Felder mehr).
- **Saubere Modularisierung:** Einzel-Fragen-Screen, Category-Learning-Screen und ProgressCard als eigenständige, leicht wartbare Komponenten.

### Technisch/UX
- **Lottie-Animationen:** Integration von Lottie-Trophäe und animiertem Feuerwerk direkt in das Dashboard.
- **Fortschrittsberechnung:** Konsistente Zählweise für gelernte Fragen (3 in Folge korrekt).
- **Fehlerbehebung:** Keine doppelten oder nicht verwendeten Importe; keine deprecated Methoden mehr im Code; Dashboard und Kategorie-Screens aktualisieren sich sofort nach jeder Aktion.
- **Responsives Design:** Fortschrittsanzeige und Grid passen sich jeder Bildschirmgröße modern an.
- **Kategorie-Lernfortschritt:** Korrekte und sofortige Anzeige für alle Kategorien – auch wenn noch keine Frage darin gelernt wurde.

---

## [1.0.2] – 2025-06-24

### Neu/Funktionen
- Fortschritts-Tracking jetzt mit „3 in Folge korrekt“ (nur dann gilt eine Frage als gelernt)
- Zufällige Quizreihenfolge mit Gewichtung: ungelernte Fragen werden häufiger gestellt
- Quiz-Filter: Nach Kategorie auswählbar und „Nur ungelernte Fragen“ möglich (Vorbereitung)
- Globale Fortschrittsanzeige (Zahl & Prozent) im Dashboard
- Redesign: Erklärungstexte entfernt, Fragen/Kategorien sauber getrennt
- 100 % konsistentes Datenmodell (questions.dart & question_model.dart)
- Skizzenbilder direkt in Fragen integriert

### Technisch
- Modernisierung aller ColorScheme-Themes: `background` → `surface`
- Umstellung aller Farbdurchsichtigkeiten auf `.withValues(alpha: ...)`
- Update aller Gradle- und NDK-Settings auf Kompatibilität mit Flutter 3.22+ und Android 15
- Github Actions: Automatisches Tagging/Release mit sicherem Tag-Output
- Fehlerbehebungen: Keine doppelten Model-Definitionen, keine deprecated Felder mehr

---

## [1.0.1] – 2025-06-23

### Neu/Funktionen
- **Theme-System**: Volle Unterstützung für Calm Nature, Bright Minimal und Dark Elegant Themes
- **ThemeProvider**/Notifier für Theme-Wechsel und Speicherung
- Launcher-Icon-Integration mit `flutter_launcher_icons`
- Trennung und Optimierung aller Datenmodelle (Fragen, Kategorien, Bilder)
- Pubspec.yaml überarbeitet für WebP, Skizzen-Unterordner, Fonts
- **Komplettes Modernisieren der Build-Umgebung:**
  - `build.gradle.kts` (Kotlin DSL) und sichere NDK-Konfiguration
  - Vorbereitung auf aktuelle und kommende Android-Versionen
- Dashboard, QuizScreen und alle Widgets auf neue Modelstruktur umgestellt
- Widget- und Unittests für neue Fragenstruktur und Logik eingeführt
- Verbesserte Fehler- und Statusausgaben (z.B. Debugging-Anleitungen, Provider-Initialisierung)
- Verbesserte und sichere Verwendung von ChangeNotifier und asynchronem State

---

## [1.0.0] – 2025-06-19

### Neu
- Erste Version der App mit 197 Fragen
- Fortschrittsanzeige pro Kategorie
- Zufallsfragen mit Fehler-Priorisierung
- Erklärungstexte bei falschen Antworten
- Unterstützung für Darkmode (automatisch & manuell)
- Lokale Speicherung des Lernfortschritts
- WebP-Bilder für bildbezogene Fragen

### Technisch
- Flutter-basierter Code
- Automatischer APK-Build via GitHub Actions
- Lizenz: GPLv3

---

<!-- auto-generated changelog below this line -->
