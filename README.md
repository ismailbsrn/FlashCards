# 📚 Flashcards

A beautiful, offline-first flashcard application built with Flutter. Study smarter with spaced repetition and sync across devices.

![Flutter](https://img.shields.io/badge/Flutter-3.9+-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart)
![License](https://img.shields.io/badge/License-Read--Only-red)

## ✨ Features

- **📱 Offline-First** — Study anywhere, anytime. Data syncs when you're back online.
- **🔄 Spaced Repetition** — Optimized learning with smart review intervals.
- **📂 Collections** — Organize cards into color-coded collections with tags.
- **🌍 Multi-Language** — English and Turkish with in-app language switching.
- **🌙 Dark Mode** — Easy on the eyes for late-night study sessions.
- **📤 Import/Export** — Backup and share your flashcard collections.
- **☁️ Cloud Sync** — Keep your progress synced across all your devices.


## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.9+
- Dart 3.0+
- iOS Simulator / Android Emulator or physical device

### Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/flashcards2.git
cd flashcards2

# Install dependencies
flutter pub get

# Generate localization files
flutter gen-l10n

# Run the app
flutter run
```

### Environment Setup

Create a `.env` file in the project root:

```env
API_BASE_URL=your_api_url_here
```

## 🏗️ Architecture

```
lib/
├── config/          # App configuration
├── database/        # SQLite database layer
├── l10n/            # Localization (ARB files)
├── models/          # Data models
├── providers/       # State management (Provider)
├── repositories/    # Data repositories
├── screens/         # UI screens
├── services/        # Business logic services
└── main.dart        # App entry point
```

## 🌐 Localization

The app supports multiple languages using Flutter's built-in localization:

| Language | Status |
|----------|--------|
| 🇺🇸 English | ✅ Complete |
| 🇹🇷 Turkish | ✅ Complete |

### Adding a New Language

1. Create `lib/l10n/app_XX.arb` (e.g., `app_de.arb` for German)
2. Add your translations
3. Run `flutter gen-l10n`

## 🛠️ Tech Stack

- **Framework:** Flutter
- **State Management:** Provider
- **Local Database:** SQLite (sqflite)
- **Preferences:** SharedPreferences
- **Networking:** HTTP
- **Serialization:** json_serializable

## 📄 License

This project is licensed under a **Read-Only License** — see the [LICENSE](LICENSE) file for details.

Copyright © 2026 İsmail Başaran

---

<p align="center">Made with Flutter</p>
