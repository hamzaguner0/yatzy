import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:yatzy_tr/app/router.dart';
import 'package:yatzy_tr/features/game/application/game_controller.dart';
import 'package:yatzy_tr/features/game/data/persistence.dart';
import 'package:yatzy_tr/features/game/presentation/widgets/score_sheet.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Results screen showing final scores and rankings
class ResultsScreen extends ConsumerWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final controller = ref.read(gameStateProvider.notifier);
    final results = controller.getResults();

    final winner = results.first;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.resultsTitle),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Winner announcement
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primaryContainer,
                    theme.colorScheme.secondaryContainer,
                  ],
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.emoji_events,
                    size: 64,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.resultsWinner(winner.player.displayName),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${winner.scoreCard.grandTotal} points',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),

            // Rankings
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final result = results[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ExpansionTile(
                      leading: CircleAvatar(
                        backgroundColor: index == 0
                            ? theme.colorScheme.primary
                            : theme.colorScheme.secondary,
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: index == 0
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        result.player.displayName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        '${result.scoreCard.grandTotal} points',
                        style: theme.textTheme.bodyMedium,
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: ScoreSheet(
                            scoreCard: result.scoreCard,
                            potentialScores: const {},
                            onCategoryTap: (_) {},
                            interactive: false,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Action buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _mainMenu(context, ref),
                      icon: const Icon(Icons.home),
                      label: Text(l10n.resultsMainMenu),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _playAgain(context, ref),
                      icon: const Icon(Icons.replay),
                      label: Text(l10n.resultsPlayAgain),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mainMenu(BuildContext context, WidgetRef ref) {
    // Clear saved game
    ref.read(persistenceProvider).clearGame();
    ref.read(gameStateProvider.notifier).returnToMenu();
    context.go(Routes.home);
  }

  void _playAgain(BuildContext context, WidgetRef ref) {
    // Get current game settings and players
    final currentState = ref.read(gameStateProvider);
    final players = currentState.players;
    final settings = currentState.settings;

    // Clear saved game
    ref.read(persistenceProvider).clearGame();

    // Start new game with same settings
    ref.read(gameStateProvider.notifier).startGame(
          players: players,
          settings: settings,
        );

    context.go(Routes.game);
  }
}
