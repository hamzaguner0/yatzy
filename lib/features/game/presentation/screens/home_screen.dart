import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:yatzy_tr/app/router.dart';
import 'package:yatzy_tr/features/game/application/game_controller.dart';
import 'package:yatzy_tr/features/game/data/persistence.dart';
import 'package:yatzy_tr/features/game/domain/entities.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Home screen with main menu
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final persistence = ref.watch(persistenceProvider);
    final hasSavedGame = persistence.hasSavedGame();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App title
                Text(
                  l10n.appTitle,
                  style: theme.textTheme.displayMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Dice icon placeholder
                Icon(
                  Icons.casino,
                  size: 80,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 48),

                // Continue game button (if available)
                if (hasSavedGame) ...[
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => _continueGame(context, ref),
                      icon: const Icon(Icons.play_arrow),
                      label: Text(l10n.homeContinueGame),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Play Solo button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => context.push('${Routes.setup}?solo=true'),
                    icon: const Icon(Icons.person),
                    label: Text(l10n.homePlaySolo),
                  ),
                ),
                const SizedBox(height: 16),

                // Pass and Play button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => context.push('${Routes.setup}?solo=false'),
                    icon: const Icon(Icons.people),
                    label: Text(l10n.homePassAndPlay),
                  ),
                ),
                const SizedBox(height: 32),

                // Secondary buttons
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => context.push(Routes.settings),
                    icon: const Icon(Icons.settings),
                    label: Text(l10n.homeSettings),
                  ),
                ),
                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => context.push(Routes.howToPlay),
                    icon: const Icon(Icons.help_outline),
                    label: Text(l10n.homeHowToPlay),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _continueGame(BuildContext context, WidgetRef ref) {
    final persistence = ref.read(persistenceProvider);
    final savedGame = persistence.loadGame();

    if (savedGame != null && savedGame.phase == GamePhase.playing) {
      ref.read(gameStateProvider.notifier).loadGameState(savedGame);
      context.push(Routes.game);
    } else {
      // Invalid saved game, clear it
      persistence.clearGame();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved game is invalid or complete')),
      );
    }
  }
}
