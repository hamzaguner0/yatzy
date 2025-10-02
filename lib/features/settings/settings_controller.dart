import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:yatzy_tr/features/game/data/persistence.dart';
import 'package:yatzy_tr/features/settings/settings_state.dart';

/// Provider for persistence repository
final persistenceProvider = Provider<PersistenceRepository>((ref) {
  final prefs = getPrefsInstance();
  return PersistenceRepository(prefs);
});

/// Settings controller provider
final settingsProvider =
    StateNotifierProvider<SettingsController, SettingsState>((ref) {
  final persistence = ref.watch(persistenceProvider);
  return SettingsController(persistence);
});

/// Controller for app settings
class SettingsController extends StateNotifier<SettingsState> {
  SettingsController(this._persistence) : super(const SettingsState()) {
    _loadSettings();
  }

  final PersistenceRepository _persistence;

  void _loadSettings() {
    state = _persistence.loadSettings();
  }

  Future<void> setLocale(Locale? locale) async {
    state = state.copyWith(locale: locale);
    await _persistence.saveSettings(state);
  }

  Future<void> setThemePreference(ThemePreference preference) async {
    state = state.copyWith(themePreference: preference);
    await _persistence.saveSettings(state);
  }

  Future<void> setSoundEnabled(bool enabled) async {
    state = state.copyWith(soundEnabled: enabled);
    await _persistence.saveSettings(state);
  }

  Future<void> setHapticsEnabled(bool enabled) async {
    state = state.copyWith(hapticsEnabled: enabled);
    await _persistence.saveSettings(state);
  }

  Future<void> setJokerRulesEnabled(bool enabled) async {
    state = state.copyWith(jokerRulesEnabled: enabled);
    await _persistence.saveSettings(state);
  }

  Future<void> setMultipleYahtzeesEnabled(bool enabled) async {
    state = state.copyWith(multipleYahtzeesEnabled: enabled);
    await _persistence.saveSettings(state);
  }

  Future<void> setRngSeed(int? seed) async {
    state = state.copyWith(rngSeed: seed);
    await _persistence.saveSettings(state);
  }
}
