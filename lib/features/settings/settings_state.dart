import 'package:flutter/material.dart';

/// Theme mode preference
enum ThemePreference {
  system,
  light,
  dark;

  ThemeMode get themeMode {
    switch (this) {
      case ThemePreference.system:
        return ThemeMode.system;
      case ThemePreference.light:
        return ThemeMode.light;
      case ThemePreference.dark:
        return ThemeMode.dark;
    }
  }
}

/// App settings state
class SettingsState {
  const SettingsState({
    this.locale,
    this.themePreference = ThemePreference.system,
    this.soundEnabled = true,
    this.hapticsEnabled = true,
    this.jokerRulesEnabled = false,
    this.multipleYahtzeesEnabled = false,
    this.rngSeed,
  });

  final Locale? locale;
  final ThemePreference themePreference;
  final bool soundEnabled;
  final bool hapticsEnabled;
  final bool jokerRulesEnabled;
  final bool multipleYahtzeesEnabled;
  final int? rngSeed;

  SettingsState copyWith({
    Locale? locale,
    ThemePreference? themePreference,
    bool? soundEnabled,
    bool? hapticsEnabled,
    bool? jokerRulesEnabled,
    bool? multipleYahtzeesEnabled,
    int? rngSeed,
  }) =>
      SettingsState(
        locale: locale ?? this.locale,
        themePreference: themePreference ?? this.themePreference,
        soundEnabled: soundEnabled ?? this.soundEnabled,
        hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
        jokerRulesEnabled: jokerRulesEnabled ?? this.jokerRulesEnabled,
        multipleYahtzeesEnabled:
            multipleYahtzeesEnabled ?? this.multipleYahtzeesEnabled,
        rngSeed: rngSeed ?? this.rngSeed,
      );

  Map<String, dynamic> toJson() => {
        'locale': locale?.languageCode,
        'themePreference': themePreference.name,
        'soundEnabled': soundEnabled,
        'hapticsEnabled': hapticsEnabled,
        'jokerRulesEnabled': jokerRulesEnabled,
        'multipleYahtzeesEnabled': multipleYahtzeesEnabled,
        'rngSeed': rngSeed,
      };

  factory SettingsState.fromJson(Map<String, dynamic> json) {
    final localeCode = json['locale'] as String?;
    return SettingsState(
      locale: localeCode != null ? Locale(localeCode) : null,
      themePreference: ThemePreference.values.firstWhere(
        (e) => e.name == json['themePreference'],
        orElse: () => ThemePreference.system,
      ),
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      hapticsEnabled: json['hapticsEnabled'] as bool? ?? true,
      jokerRulesEnabled: json['jokerRulesEnabled'] as bool? ?? false,
      multipleYahtzeesEnabled:
          json['multipleYahtzeesEnabled'] as bool? ?? false,
      rngSeed: json['rngSeed'] as int?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsState &&
          runtimeType == other.runtimeType &&
          locale == other.locale &&
          themePreference == other.themePreference &&
          soundEnabled == other.soundEnabled &&
          hapticsEnabled == other.hapticsEnabled &&
          jokerRulesEnabled == other.jokerRulesEnabled &&
          multipleYahtzeesEnabled == other.multipleYahtzeesEnabled &&
          rngSeed == other.rngSeed;

  @override
  int get hashCode => Object.hash(
        locale,
        themePreference,
        soundEnabled,
        hapticsEnabled,
        jokerRulesEnabled,
        multipleYahtzeesEnabled,
        rngSeed,
      );
}
