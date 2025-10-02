# 🚀 Quick Start Guide - Yatzy TR

## Prerequisites
- Flutter SDK 3.0+ installed
- An IDE (VS Code, Android Studio, or IntelliJ)
- Android emulator/device or iOS simulator (for Mac)

## Installation & Running

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Generate Localization Files
```bash
flutter gen-l10n
```

### 3. Run the App
```bash
# Run on connected device/emulator
flutter run

# Run in debug mode with hot reload
flutter run --debug

# Run in release mode (optimized)
flutter run --release
```

### 4. Run Tests
```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/scoring_engine_test.dart
```

### 5. Code Analysis
```bash
# Check for issues
flutter analyze

# Format code
dart format .
```

## Quick Build Commands

### Android
```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# App Bundle (for Play Store)
flutter build appbundle --release
```

### iOS (macOS only)
```bash
# Debug
flutter build ios --debug

# Release
flutter build ios --release
```

## Common Issues & Solutions

### Issue: "Waiting for another flutter command to release the startup lock"
**Solution:**
```bash
killall -9 dart
flutter clean
flutter pub get
```

### Issue: Localization files not found
**Solution:**
```bash
flutter clean
flutter pub get
flutter gen-l10n
```

### Issue: Hot reload not working
**Solution:**
- Press `r` in terminal to hot reload
- Press `R` in terminal to hot restart
- Or restart the app with `flutter run`

### Issue: Tests failing
**Solution:**
```bash
flutter clean
flutter pub get
flutter test
```

## Development Tips

### Enable Hot Reload in VS Code
1. Install Flutter extension
2. Press `F5` to start debugging
3. Save files to trigger hot reload

### View Logs
```bash
# All logs
flutter logs

# Filtered logs
flutter logs -v
```

### Clean Build
```bash
flutter clean
flutter pub get
flutter run
```

## Feature Testing Checklist

- [ ] Start solo game vs AI (Easy/Normal/Hard)
- [ ] Start pass-and-play with 2-6 players
- [ ] Roll dice and hold/unhold dice
- [ ] Fill all 13 categories
- [ ] Check upper bonus calculation (63+ = +35)
- [ ] Complete a full game
- [ ] View results and rankings
- [ ] Exit and resume game
- [ ] Change language (EN ↔ TR)
- [ ] Toggle theme (Light/Dark/System)
- [ ] Enable/disable sound and haptics
- [ ] View "How to Play" screen

## Performance Testing

```bash
# Profile app performance
flutter run --profile

# Build size analysis
flutter build apk --analyze-size
```

## Troubleshooting

### Clear All Cached Data
```bash
flutter clean
rm -rf .dart_tool
rm pubspec.lock
flutter pub get
```

### Reset Shared Preferences (app data)
Uninstall and reinstall the app, or clear app data from device settings.

---

**Happy Coding! 🎲**
