# 🐶 Sachkundenachweis NRW – Lernapp

**Die moderne, kostenlose Android-App zur Vorbereitung auf die Sachkundeprüfung nach §11 Abs. 3 LHundG NRW**

> Für alle Hundehalter:innen in Nordrhein-Westfalen, die den Sachkundenachweis bei anerkannten Tierärzt:innen ablegen möchten.

---

## 📱 Features

- ✅ **Alle 197 offiziellen Prüfungsfragen** (neue Fassung ab 2025)
- 🧠 **Adaptives Lernen**: Jede Frage muss 3× korrekt beantwortet werden
- 🔄 **Fehlerorientiertes Üben**: Falsche Antworten werden bevorzugt wiederholt
- 🧾 **Erklärungen** bei jeder falschen Antwort
- 📊 **Dashboard**: Fortschritt für jede Kategorie sichtbar
- 🎨 **Multi-Theme-Unterstützung**: Drei Designs (Calm Nature, Bright Minimal, Dark Elegant), jeweils mit Light & Dark Mode
- 🌙 **Automatischer und manueller Darkmode** (systemgesteuert oder per App wählbar)
- 💾 **Lokale Speicherung** deines Lernfortschritts (keine Cloud, keine Registrierung)
- 🖼️ **Bilder & Skizzen** zu ausgewählten Fragen (optimiert als WebP)
- 📍 **Verzeichnis prüfender Tierärzt:innen** nach Bestehen der Prüfung sichtbar
- 📐 **100 % Responsive** – läuft auf Smartphone, Tablet und Desktop (Flutter)

---

## 🔧 Technik

- 📦 [Flutter](https://flutter.dev) (ab 3.x)
- 📚 State Management mit [`provider`](https://pub.dev/packages/provider)
- 💾 Speicherung: [`shared_preferences`](https://pub.dev/packages/shared_preferences)
- 📈 Fortschritt: [`fl_chart`](https://pub.dev/packages/fl_chart)
- 🤖 **Automatischer APK-Build & GitHub Release** (via Actions)
- 📜 **Lizenz:** GNU GPLv3

---

## 🚀 Installation (lokal)

```bash
git clone https://github.com/Mildman1848/sachkundenachweis_app.git
cd sachkundenachweis_flutter
flutter pub get
flutter run
```

> Für den APK-Release: siehe GitHub Releases auf der Projektseite.

---

## 🏗️ CI/CD (GitHub Actions)

- Jeder Push auf den `main`-Branch baut automatisch eine neue APK und veröffentlicht sie im Release-Bereich
- Abhängigkeiten (`pubspec.lock`) und Changelog werden automatisch aktualisiert
- Release-Notizen: aus `CHANGELOG.md`

---

## 📂 Projektstruktur (Auszug)

```
lib/
├── main.dart
├── models/
│   └── question_model.dart
├── screens/
│   ├── dashboard_screen.dart
│   ├── quiz_screen.dart
│   └── settings_screen.dart
├── widgets/
│   └── question_card.dart
├── storage/
│   ├── progress_dashboard.dart
│   └── progress_storage.dart
├── data/
│   └── questions.dart
├── theme/
│   └── theme_notifier.dart
assets/
└── images/
.github/
└── workflows/
    └── build.yml
```

---

## ❤️ Mitmachen

Du hast Fehler gefunden oder Ideen für neue Features?  
**Starte ein [Issue](https://github.com/Mildman1848/sachkundenachweis_app/issues)**  
oder reiche einen **Pull Request** ein – wir freuen uns auf deinen Beitrag!

---

## 📘 Quelle

Alle Fragen basieren auf dem offiziellen Fragenkatalog der [Tierärztekammer Nordrhein](https://www.tieraerztekammer-nordrhein.de/tierhalter/sachkundebescheinigung-lhundg/).

---

## © Lizenz

Dieses Projekt steht unter der [GNU GPLv3](LICENSE).