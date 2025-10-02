# Yatzy TR

A production-ready, cross-platform Yatzy (Yahtzee) game built with Flutter.

[![CI](https://github.com/yourusername/yatzy_tr/workflows/CI/badge.svg)](https://github.com/yourusername/yatzy_tr/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

## 📱 Features

- **Single-player vs AI**: Play against AI opponents with three difficulty levels (Easy, Normal, Hard)
- **Pass-and-Play**: Local multiplayer for 2-6 players on one device
- **Fully Offline**: No internet connection required
- **Multi-language Support**: Turkish (default) and English
- **Dark/Light Theme**: Material 3 design with dynamic theming
- **Accessibility**: High contrast support, large fonts, screen reader labels
- **Save/Resume**: Automatic game state persistence
- **Deterministic RNG**: Optional seeded random number generator for practice and testing

## 🎮 Game Rules

Yatzy is played over 13 rounds. Each round:
1. Roll up to 3 times
2. Hold dice you want to keep between rolls
3. Choose a category to score (or scratch)

### Categories

**Upper Section** (Ones through Sixes):
- Score: Sum of matching dice
- Bonus: +35 points if upper section totals 63 or more

**Lower Section**:
- **Three of a Kind**: Sum of all dice (requires 3+ matching)
- **Four of a Kind**: Sum of all dice (requires 4+ matching)
- **Full House**: 3 of one kind + 2 of another = 25 points
- **Small Straight**: 4 in sequence = 30 points
- **Large Straight**: 5 in sequence = 40 points
- **Chance**: Sum of all dice (no requirement)
- **Yahtzee**: All 5 dice match = 50 points

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────┐
│                     Presentation Layer                  │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐             │
│  │  Home    │  │  Game    │  │ Results  │  Screens    │
│  │  Screen  │  │  Screen  │  │  Screen  │             │
│  └──────────┘  └──────────┘  └──────────┘             │
│                                                          │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐             │
│  │Animated  │  │  Score   │  │  Turn    │  Widgets    │
│  │  Dice    │  │  Sheet   │  │  Banner  │             │
│  └──────────┘  └──────────┘  └──────────┘             │
└─────────────────────────────────────────────────────────┘
                        ↓ ↑
┌─────────────────────────────────────────────────────────┐
│                   Application Layer                     │
│  ┌──────────────────────────────────────────────────┐  │
│  │          GameController (Riverpod)               │  │
│  │  - State Management                              │  │
│  │  - Game Flow Orchestration                       │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
                        ↓ ↑
┌─────────────────────────────────────────────────────────┐
│                      Domain Layer                       │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐        │
│  │  Entities  │  │  Scoring   │  │     AI     │        │
│  │  (Models)  │  │   Engine   │  │  Policies  │        │
│  └────────────┘  └────────────┘  └────────────┘        │
│                                                          │
│  Pure business logic - no dependencies on Flutter       │
└─────────────────────────────────────────────────────────┘
                        ↓ ↑
┌─────────────────────────────────────────────────────────┐
│                       Data Layer                        │
│  ┌──────────────────────────────────────────────────┐  │
│  │    Persistence (SharedPreferences)               │  │
│  │    - Game state save/load                        │  │
│  │    - Settings storage                            │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

## 🎯 State Machine

```
         ┌────────┐
         │  Menu  │
         └───┬────┘
             │ startGame()
             ↓
       ┌──────────┐
       │ Playing  │──────┐
       └─────┬────┘      │
             │           │ returnToMenu()
             │           │
  ┌──────────┴───────────┴────────────────┐
  │                                        │
  │  Per Turn:                             │
  │  1. rollDice() (max 3 times)          │
  │  2. toggleDieHold() (optional)        │
  │  3. chooseCategory() or               │
  │     scratchCategory()                 │
  │                                        │
  │  → Advance to next player             │
  │  → After round 13 → Complete          │
  │                                        │
  └───────────────┬────────────────────────┘
                  │
                  ↓
            ┌──────────┐
            │ Complete │
            └──────────┘
```

## 🚀 Getting Started

### Prerequisites

- Flutter 3.24.0 or later
- Dart 3.0.0 or later
- Android SDK (for Android builds)
- Xcode (for iOS builds)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/yatzy_tr.git
cd yatzy_tr
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

### Platform-specific setup

**Android** (minSdk 24):
```bash
flutter build apk --release
```

**iOS** (iOS 13+):
```bash
flutter build ios --release
```

## 🧪 Testing

Run all tests:
```bash
flutter test
```

Run tests with coverage:
```bash
flutter test --coverage
```

View coverage report:
```bash
# On macOS/Linux
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html

# On Windows
perl C:\ProgramData\chocolatey\lib\lcov\tools\bin\genhtml coverage\lcov.info -o coverage\html
start coverage\html\index.html
```

### Test Structure

- **Unit Tests**: `test/scoring_engine_test.dart` - 100% coverage of scoring logic
- **AI Tests**: `test/ai_policy_test.dart` - Deterministic AI behavior validation
- **Integration Tests**: `test/game_flow_test.dart` - End-to-end game flow scenarios

## 🌍 Localization

The app supports Turkish and English. Translations are in ARB format:

- `lib/l10n/app_en.arb` - English translations
- `lib/l10n/app_tr.arb` - Turkish translations

### Adding new translations

1. Add new keys to both ARB files
2. Run code generation:
```bash
flutter gen-l10n
```

### Adding a new language

1. Create `lib/l10n/app_XX.arb` (XX = language code)
2. Translate all keys from `app_en.arb`
3. Update `lib/app/localization/` if needed
4. Run `flutter gen-l10n`

## 📁 Project Structure

```
lib/
├── app/
│   ├── router.dart              # go_router configuration
│   ├── theme.dart               # Material 3 themes
│   └── localization/            # Localization setup
├── core/
│   ├── rng.dart                 # Random number generator
│   └── utils/                   # Shared utilities
├── features/
│   ├── game/
│   │   ├── domain/
│   │   │   ├── entities.dart    # Game models (immutable)
│   │   │   ├── scoring_engine.dart  # Pure scoring logic
│   │   │   └── ai.dart          # AI strategies
│   │   ├── application/
│   │   │   └── game_controller.dart # State management
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   ├── home_screen.dart
│   │   │   │   ├── setup_screen.dart
│   │   │   │   ├── game_screen.dart
│   │   │   │   └── results_screen.dart
│   │   │   └── widgets/
│   │   │       ├── animated_dice.dart
│   │   │       ├── score_sheet.dart
│   │   │       └── turn_banner.dart
│   │   └── data/
│   │       └── persistence.dart  # Save/load game state
│   └── settings/
│       ├── settings_state.dart
│       ├── settings_controller.dart
│       └── presentation/
│           └── screens/
│               ├── settings_screen.dart
│               └── how_to_play_screen.dart
├── l10n/                        # Localization files
└── main.dart

test/
├── scoring_engine_test.dart     # Scoring logic tests
├── ai_policy_test.dart          # AI behavior tests
└── game_flow_test.dart          # Integration tests

assets/
├── icons/
│   └── app_icon.svg
└── splash/
    └── splash.svg
```

## 🎨 Code Quality

The project uses strict linting rules defined in `analysis_options.yaml`:

- Implicit casts disabled
- Implicit dynamic disabled
- Exhaustive switch cases required
- Const constructors preferred
- Proper error handling enforced

Run analyzer:
```bash
flutter analyze
```

Format code:
```bash
dart format .
```

## 🤖 AI Implementation

### Easy AI
- **Strategy**: Greedy heuristic
- **Hold logic**: Keep dice that maximize immediate category scores
- **Category selection**: Choose highest-scoring available category
- **Performance**: < 10ms per decision

### Normal AI
- **Strategy**: 1-step lookahead with expected values
- **Hold logic**: Estimate expected values for each hold pattern
- **Category selection**: Avoid scratching high-EV categories early
- **Performance**: < 50ms per decision

### Hard AI
- **Strategy**: Monte Carlo rollouts (≤ 5,000 simulations)
- **Hold logic**: Simulate future rolls and outcomes
- **Category selection**: Maximize total expected score
- **Performance**: < 100ms per decision (with pruning)

All AI implementations are deterministic with seeded RNG for testing and reproducibility.

## 🔧 Configuration

### Settings

Users can configure:
- **Language**: Turkish, English, or System Default
- **Theme**: Light, Dark, or System Default
- **Sound Effects**: On/Off
- **Haptic Feedback**: On/Off
- **Game Variants**: Joker rules (toggleable)
- **RNG Seed**: Optional numeric seed for deterministic gameplay

Settings are persisted locally using `shared_preferences`.

## 🚦 CI/CD

GitHub Actions CI workflow (`.github/workflows/ci.yml`):

1. **Analyze & Test**: Code formatting, linting, and all tests
2. **Build Android**: APK generation
3. **Build iOS**: IPA generation (no codesign)

CI runs on:
- Push to `main` or `develop`
- Pull requests to `main` or `develop`

## 📊 Performance

- **60 FPS** during dice animations
- **< 500ms** dice roll animation duration
- **< 100ms** AI decision time (Hard difficulty)
- **Minimal rebuilds** via Riverpod selectors and const widgets

## 🛣️ Roadmap

Future enhancements (post-MVP):
- [ ] Online multiplayer
- [ ] Global leaderboards
- [ ] Achievement system
- [ ] Statistics tracking
- [ ] Custom rule variants
- [ ] In-app purchases (cosmetics)
- [ ] Rewarded ads integration

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

Ensure:
- All tests pass (`flutter test`)
- Code is formatted (`dart format .`)
- No analyzer issues (`flutter analyze`)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Inspired by the classic Yahtzee dice game
- Built with [Flutter](https://flutter.dev/)
- State management by [Riverpod](https://riverpod.dev/)
- Icons and theming powered by Material 3

## 📧 Contact

For questions or feedback, please open an issue on GitHub.

---

**Made with ❤️ using Flutter**
