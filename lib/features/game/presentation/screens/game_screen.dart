import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:yatzy_tr/app/router.dart';
import 'package:yatzy_tr/core/rng.dart';
import 'package:yatzy_tr/features/game/application/game_controller.dart';
import 'package:yatzy_tr/features/game/data/persistence.dart';
import 'package:yatzy_tr/features/game/domain/ai.dart';
import 'package:yatzy_tr/features/game/domain/entities.dart';
import 'package:yatzy_tr/features/game/presentation/widgets/animated_dice.dart';
import 'package:yatzy_tr/features/game/presentation/widgets/score_sheet.dart';
import 'package:yatzy_tr/features/settings/settings_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Main game screen
class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  bool _animateDice = false;

  @override
  void initState() {
    super.initState();
    // Check if AI needs to play
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAITurn();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final gameState = ref.watch(gameStateProvider);

    // Navigate to results if game complete
    if (gameState.phase == GamePhase.complete) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go(Routes.results);
      });
    }

    final activePlayer = gameState.activePlayer;
    final scoreCard = gameState.activeScoreCard;
    final potentialScores = ref.read(gameStateProvider.notifier).getPotentialScores();

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          final shouldPop = await _showExitDialog(context);
          if (shouldPop == true && context.mounted) {
            context.pop();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.gameTurn(activePlayer.displayName)),
          actions: [
            // Round indicator
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  l10n.gameRound(gameState.currentRound, 13),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Dice section
              Expanded(
                flex: 2,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Dice
                        DiceRow(
                          dice: gameState.dice,
                          onDieTap: _handleDieTap,
                          canHold: gameState.hasRolled && !activePlayer.isAI,
                          animate: _animateDice,
                        ),
                        const SizedBox(height: 24),

                        // Roll info
                        if (gameState.hasRolled)
                          Text(
                            l10n.gameTapToHold,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),

                        const SizedBox(height: 16),

                        // Roll button
                        if (gameState.canRoll && !activePlayer.isAI)
                          FilledButton.icon(
                            onPressed: _rollDice,
                            icon: const Icon(Icons.casino),
                            label: Text(
                              '${l10n.gameRollDice} (${l10n.gameRollsLeft(gameState.settings.rollsPerTurn - gameState.rollCount)})',
                            ),
                          ),

                        if (!gameState.canRoll && gameState.hasRolled && !activePlayer.isAI)
                          Text(
                            l10n.gameSelectCategory,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),

                        if (activePlayer.isAI)
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // Score sheet section
              Expanded(
                flex: 3,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: ScoreSheet(
                    scoreCard: scoreCard,
                    potentialScores: potentialScores,
                    onCategoryTap: _handleCategoryTap,
                    interactive: gameState.hasRolled && !activePlayer.isAI,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _rollDice() async {
    final settings = ref.read(settingsProvider);

    // Haptic feedback
    if (settings.hapticsEnabled) {
      HapticFeedback.lightImpact();
    }

    setState(() {
      _animateDice = true;
    });

    ref.read(gameStateProvider.notifier).rollDice();

    // Auto-save after roll
    final gameState = ref.read(gameStateProvider);
    ref.read(persistenceProvider).saveGame(gameState);

    // Reset animation
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      setState(() {
        _animateDice = false;
      });
    }
  }

  void _handleDieTap(int dieId) {
    final settings = ref.read(settingsProvider);

    if (settings.hapticsEnabled) {
      HapticFeedback.selectionClick();
    }

    ref.read(gameStateProvider.notifier).toggleDieHold(dieId);
  }

  void _handleCategoryTap(ScoreCategory category) async {
    final settings = ref.read(settingsProvider);

    if (settings.hapticsEnabled) {
      HapticFeedback.mediumImpact();
    }

    ref.read(gameStateProvider.notifier).chooseCategory(category);

    // Auto-save after category selection
    final gameState = ref.read(gameStateProvider);
    await ref.read(persistenceProvider).saveGame(gameState);

    // Check if next player is AI
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _checkAITurn();
      }
    });
  }

  void _checkAITurn() async {
    GameState gameState = ref.read(gameStateProvider);

    bool shouldContinue(GameState state) =>
        state.phase == GamePhase.playing && state.activePlayer.isAI;

    if (!shouldContinue(gameState)) return;

    // Allow UI to update before the AI acts.
    await Future.delayed(const Duration(milliseconds: 500));

    gameState = ref.read(gameStateProvider);
    if (!shouldContinue(gameState)) return;

    final rng = RNG(seed: gameState.settings.seed);
    final scoringEngine = ref.read(scoringEngineProvider);
    final aiFactory = AIFactory(scoringEngine: scoringEngine, rng: rng);
    final aiPolicy = aiFactory.createPolicy(gameState.activePlayer.difficulty);

    // AI rolling phase
    while (true) {
      gameState = ref.read(gameStateProvider);
      if (!shouldContinue(gameState)) return;
      if (!gameState.canRoll) break;

      final decision = aiPolicy.decideKeep(
        dice: gameState.dice,
        scoreCard: gameState.activeScoreCard,
        rollCount: gameState.rollCount,
        maxRolls: gameState.settings.rollsPerTurn,
      );

      if (!decision.shouldRoll || !gameState.canRoll) {
        break;
      }

      await Future.delayed(const Duration(milliseconds: 500));
      ref.read(gameStateProvider.notifier).setDiceHold(decision.diceToKeep);
      gameState = ref.read(gameStateProvider);
      if (!shouldContinue(gameState) || !gameState.canRoll) {
        break;
      }

      await Future.delayed(const Duration(milliseconds: 800));
      ref.read(gameStateProvider.notifier).rollDice();
      gameState = ref.read(gameStateProvider);
      await ref.read(persistenceProvider).saveGame(gameState);
    }

    await Future.delayed(const Duration(milliseconds: 800));
    gameState = ref.read(gameStateProvider);
    if (!shouldContinue(gameState)) return;

    final categoryDecision = aiPolicy.decideCategory(
      dice: gameState.dice,
      scoreCard: gameState.activeScoreCard,
    );

    if (!mounted) return;

    ref
        .read(gameStateProvider.notifier)
        .chooseCategory(categoryDecision.category);

    gameState = ref.read(gameStateProvider);
    await ref.read(persistenceProvider).saveGame(gameState);

    if (shouldContinue(gameState)) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _checkAITurn();
        }
      });
    }
  }

  Future<bool?> _showExitDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Game?'),
        content: const Text('Your progress will be saved. You can resume later.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}
