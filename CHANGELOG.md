# Changelog

All notable changes to this project will be documented in this file. See [standard-version](https://github.com/conventional-changelog/standard-version) for commit guidelines.

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
