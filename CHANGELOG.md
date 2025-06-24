# Changelog – Sachkundenachweis

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
