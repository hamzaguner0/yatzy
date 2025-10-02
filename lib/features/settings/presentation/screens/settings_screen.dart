import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:yatzy_tr/features/settings/settings_controller.dart';
import 'package:yatzy_tr/features/settings/settings_state.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Settings screen
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
      ),
      body: ListView(
        children: [
          // Language
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l10n.settingsLanguage),
            trailing: DropdownButton<String?>(
              value: settings.locale?.languageCode,
              items: const [
                DropdownMenuItem(
                  value: null,
                  child: Text('System'),
                ),
                DropdownMenuItem(
                  value: 'en',
                  child: Text('English'),
                ),
                DropdownMenuItem(
                  value: 'tr',
                  child: Text('Türkçe'),
                ),
              ],
              onChanged: (value) {
                controller.setLocale(value != null ? Locale(value) : null);
              },
            ),
          ),
          const Divider(),

          // Theme
          ListTile(
            leading: const Icon(Icons.palette),
            title: Text(l10n.settingsTheme),
            trailing: DropdownButton<ThemePreference>(
              value: settings.themePreference,
              items: [
                DropdownMenuItem(
                  value: ThemePreference.system,
                  child: Text(l10n.settingsThemeSystem),
                ),
                DropdownMenuItem(
                  value: ThemePreference.light,
                  child: Text(l10n.settingsThemeLight),
                ),
                DropdownMenuItem(
                  value: ThemePreference.dark,
                  child: Text(l10n.settingsThemeDark),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  controller.setThemePreference(value);
                }
              },
            ),
          ),
          const Divider(),

          // Sound
          SwitchListTile(
            secondary: const Icon(Icons.volume_up),
            title: Text(l10n.settingsSound),
            value: settings.soundEnabled,
            onChanged: controller.setSoundEnabled,
          ),

          // Haptics
          SwitchListTile(
            secondary: const Icon(Icons.vibration),
            title: Text(l10n.settingsHaptics),
            value: settings.hapticsEnabled,
            onChanged: controller.setHapticsEnabled,
          ),
          const Divider(),

          // Variants header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              l10n.settingsVariants,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),

          // Joker rules
          SwitchListTile(
            secondary: const Icon(Icons.rule),
            title: Text(l10n.settingsJokerRules),
            value: settings.jokerRulesEnabled,
            onChanged: controller.setJokerRulesEnabled,
          ),

          // Multiple Yahtzees
          SwitchListTile(
            secondary: const Icon(Icons.casino),
            title: Text(l10n.settingsMultipleYahtzees),
            value: settings.multipleYahtzeesEnabled,
            onChanged: controller.setMultipleYahtzeesEnabled,
          ),
          const Divider(),

          // RNG Seed (for testing)
          ListTile(
            leading: const Icon(Icons.code),
            title: Text(l10n.settingsRngSeed),
            subtitle: Text(
              settings.rngSeed?.toString() ?? 'None (random)',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showSeedDialog(context, controller, settings),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showSeedDialog(
    BuildContext context,
    SettingsController controller,
    SettingsState settings,
  ) async {
    final textController = TextEditingController(
      text: settings.rngSeed?.toString() ?? '',
    );

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('RNG Seed'),
        content: TextField(
          controller: textController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            hintText: 'Enter seed number (leave empty for random)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final text = textController.text.trim();
              final seed = text.isEmpty ? null : int.tryParse(text);
              controller.setRngSeed(seed);
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
