import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:yatzy_tr/features/game/domain/entities.dart';
import 'package:yatzy_tr/features/settings/settings_state.dart';

/// Keys for shared preferences
class _Keys {
  static const String savedGame = 'saved_game';
  static const String settings = 'settings';
}

/// Repository for persisting game data
class PersistenceRepository {
  const PersistenceRepository(this._prefs);

  final SharedPreferences _prefs;

  /// Save current game state
  Future<bool> saveGame(GameState gameState) async {
    try {
      final json = jsonEncode(gameState.toJson());
      return await _prefs.setString(_Keys.savedGame, json);
    } catch (e) {
      return false;
    }
  }

  /// Load saved game state
  GameState? loadGame() {
    try {
      final json = _prefs.getString(_Keys.savedGame);
      if (json == null) return null;

      final data = jsonDecode(json) as Map<String, dynamic>;
      return GameState.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  /// Clear saved game
  Future<bool> clearGame() async {
    try {
      return await _prefs.remove(_Keys.savedGame);
    } catch (e) {
      return false;
    }
  }

  /// Check if there's a saved game
  bool hasSavedGame() {
    return _prefs.containsKey(_Keys.savedGame);
  }

  /// Save settings
  Future<bool> saveSettings(SettingsState settings) async {
    try {
      final json = jsonEncode(settings.toJson());
      return await _prefs.setString(_Keys.settings, json);
    } catch (e) {
      return false;
    }
  }

  /// Load settings
  SettingsState loadSettings() {
    try {
      final json = _prefs.getString(_Keys.settings);
      if (json == null) return const SettingsState();

      final data = jsonDecode(json) as Map<String, dynamic>;
      return SettingsState.fromJson(data);
    } catch (e) {
      return const SettingsState();
    }
  }
}

/// Provider for SharedPreferences instance
/// This needs to be initialized in main()
SharedPreferences? _prefsInstance;

void initPersistence(SharedPreferences prefs) {
  _prefsInstance = prefs;
}

SharedPreferences getPrefsInstance() {
  if (_prefsInstance == null) {
    throw StateError('SharedPreferences not initialized. Call initPersistence first.');
  }
  return _prefsInstance!;
}
