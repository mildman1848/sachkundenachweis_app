# 🐶 Sachkundenachweis NRW – Lernapp

Eine moderne, kostenlose Android-App zur Vorbereitung auf die Sachkundeprüfung gemäß §11 Abs. 3 LHundG NRW.

> Diese App richtet sich an Hundehalterinnen und Hundehalter in Nordrhein-Westfalen, die den Sachkundenachweis bei einer anerkannten Tierärztin / einem anerkannten Tierarzt ablegen möchten.

---

## 📱 Funktionen

- ✅ Enthält alle **197 offiziellen Prüfungsfragen**
- 🧠 Fragen müssen **mindestens 3× korrekt beantwortet** werden, um als vorbereitet zu gelten
- ❌ Fehlerhafte Antworten werden **bevorzugt erneut gestellt**
- 🧾 Erklärungen bei falschen Antworten
- 📊 **Dashboard** mit Fortschritt **pro Kategorie**
- 🌙 Automatischer und manueller **Darkmode**
- 💾 Fortschritt wird **lokal gespeichert**
- 🖼️ Fragen mit Bildern werden inkl. **Skizzen (WebP)** angezeigt
- 📍 Verzeichnis prüfender Tierärzt:innen nach Bestehen sichtbar

---

## 🔧 Technik

- 📦 Entwickelt mit [Flutter](https://flutter.dev)
- 🎯 Lokale Speicherung mit `shared_preferences`
- 📈 Fortschrittsanzeigen mit `fl_chart`
- 🛠️ Automatischer **APK-Build & GitHub Release** per GitHub Actions
- 📜 Lizenz: **GNU General Public License v3.0**

---

## 🚀 Installation (lokal)

```bash
git clone https://github.com/Mildman1848/sachkundenachweis_flutter.git
cd sachkundenachweis_flutter
flutter pub get
flutter run
```

---

## 🏗️ GitHub Actions Build

- `main`-Branch Push → löst automatisch Build & Release aus
- Änderungen an `pubspec.lock` werden automatisch erkannt, committet & getaggt
- `CHANGELOG.md` wird ins Release übernommen

---

## 📂 Projektstruktur (Auszug)

```
lib/
├── main.dart
├── model/
│   └── question_model.dart
├── screens/
│   ├── dashboard_screen.dart
│   └── quiz_screen.dart
├── widgets/
│   ├── question_card.dart
│   └── progress_dashboard.dart
├── data/
│   └── questions.dart
assets/
└── images/
.github/
└── workflows/
    └── build.yml
```

---

## ❤️ Mitwirken

Fehler gefunden oder Verbesserungsvorschlag?  
Erstelle gerne ein Issue oder Pull Request!

---

## 📘 Quelle

Alle Fragen basieren auf dem offiziellen PDF der [Tierärztekammer Nordrhein](https://www.tieraerztekammer-nordrhein.de/tierhalter/sachkundebescheinigung-lhundg/).

---

## © Lizenz

> Dieses Projekt steht unter der [GNU GPLv3](LICENSE).