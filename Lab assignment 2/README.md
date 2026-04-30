# 🎮 Number Guessing Game — Flutter

A complete, production-ready Flutter mobile app for the Number Guessing Game with SQLite persistence, stats, history, and settings.

---

## 📁 Project Structure

```
number_guessing_game/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── models/
│   │   ├── difficulty.dart          # Difficulty level model (Easy/Medium/Hard)
│   │   └── game_result.dart         # GameResult model with DB mapping
│   ├── database/
│   │   └── database_helper.dart     # SQLite helper (sqflite)
│   ├── providers/
│   │   └── game_provider.dart       # State management (Provider)
│   ├── screens/
│   │   ├── splash_screen.dart       # Animated splash screen
│   │   ├── main_navigation.dart     # Bottom nav container
│   │   ├── home_screen.dart         # Difficulty + guess input
│   │   ├── result_screen.dart       # Correct/Too High/Too Low result
│   │   ├── history_screen.dart      # SQLite game history list
│   │   ├── stats_screen.dart        # Aggregated stats with progress bars
│   │   └── settings_screen.dart     # Sound/vibration toggles + reset
│   └── widgets/
│       ├── app_theme.dart           # ThemeData, colors, gradients
│       └── common_widgets.dart      # Reusable buttons, cards, icons
├── android/
│   └── app/
│       ├── build.gradle
│       └── src/main/
│           ├── AndroidManifest.xml
│           └── kotlin/.../MainActivity.kt
└── pubspec.yaml                     # All dependencies
```

---

## 🚀 How to Run

### Prerequisites

- Flutter SDK ≥ 3.0.0 installed ([flutter.dev](https://flutter.dev/docs/get-started/install))
- Android Studio with an emulator **OR** a real Android device (USB debugging on)
- Java 11+ (for Android builds)

### Step-by-Step

```bash
# 1. Navigate to the project
cd number_guessing_game

# 2. Get all dependencies
flutter pub get

# 3. Check connected devices
flutter devices

# 4. Run on Android emulator or device
flutter run

# 5. For a release build APK
flutter build apk --release
# APK will be at: build/app/outputs/flutter-apk/app-release.apk
```

> ⚠️ **This app targets Android only.** Web and iOS are not configured.

---

## 📦 Key Dependencies

| Package | Purpose |
|---|---|
| `sqflite` | SQLite database for game history |
| `path` | Path helpers for DB location |
| `provider` | State management |
| `shared_preferences` | Persist sound/vibration settings |
| `intl` | Date/time formatting in history |
| `vibration` | Haptic feedback |

---

## 🎮 Features

### Core Gameplay
- **3 Difficulty Levels:**
  - Easy: 1–20
  - Medium: 1–50
  - Hard: 1–100
- Random number generated on first guess in a new game
- Result feedback: ✅ Correct / 🔴 Too High / 🔵 Too Low
- Input validation (empty, non-integer, out-of-range)

### Screens
| Screen | Description |
|---|---|
| Splash | Animated intro with gradient + logo |
| Home | Difficulty selector + number input |
| Result | Animated result with guess vs. correct comparison |
| History | All past games from SQLite, sorted newest first |
| Stats | Total games, win %, by-difficulty breakdown |
| Settings | Sound/vibration toggles, reset, about |

### Data Persistence
- SQLite via `sqflite` stores every game result
- `SharedPreferences` stores sound/vibration preference across sessions
- Stats computed live from the database

---

## 🎨 UI Preview

**Colors:**
- Primary: Deep purple `#6C2BD9`
- Accent: Amber `#F5A623`
- Success (Correct): Green `#4CAF50`
- Too High: Red `#F44336`
- Too Low: Blue `#2196F3`

**Animations:**
- Splash screen: scale + fade entrance
- Result screen: elastic scale icon + slide-fade content
- Difficulty selector: animated color + shadow on selection

---

## 🛠 Troubleshooting

**`flutter pub get` fails:**
```bash
flutter clean
flutter pub get
```

**Build fails with Kotlin/Gradle error:**
- Make sure Android Studio is up to date
- Check `android/app/build.gradle` minSdk is 21+

**Emulator not showing:**
- Open Android Studio → Device Manager → Start emulator
- Then run `flutter run`

**App crashes on launch:**
```bash
flutter run --verbose
```
Check logs for SQLite permission or path issues.

---

## 📝 Database Schema

**Table: `game_results`**

| Column | Type | Description |
|---|---|---|
| id | INTEGER PK | Auto-increment |
| guessed_number | INTEGER | What the user guessed |
| correct_number | INTEGER | The secret number |
| result | TEXT | `win`, `too_high`, `too_low` |
| difficulty | TEXT | `Easy`, `Medium`, `Hard` |
| timestamp | TEXT | ISO 8601 datetime |
