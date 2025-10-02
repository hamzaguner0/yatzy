import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:yatzy_tr/core/rng.dart';
import 'package:yatzy_tr/features/game/domain/entities.dart';
import 'package:yatzy_tr/features/game/domain/scoring_engine.dart';

/// Provider for the scoring engine
final scoringEngineProvider = Provider<ScoringEngine>((ref) {
  return const ScoringEngine();
});

/// Provider for the RNG instance
final rngProvider = Provider<RNG>((ref) {
  final state = ref.watch(gameStateProvider);
  return RNG(seed: state.settings.seed);
});

/// Main game state provider
final gameStateProvider =
    StateNotifierProvider<GameController, GameState>((ref) {
  return GameController(
    scoringEngine: ref.watch(scoringEngineProvider),
    rng: ref.watch(rngProvider),
  );
});

/// Game controller managing all game state and transitions
class GameController extends StateNotifier<GameState> {
  GameController({
    required ScoringEngine scoringEngine,
    required RNG rng,
  })  : _scoringEngine = scoringEngine,
        _rng = rng,
        super(
          const GameState(
            phase: GamePhase.menu,
            players: [],
            settings: GameSettings(),
          ),
        );

  final ScoringEngine _scoringEngine;
  final RNG _rng;

  /// Start a new game with given settings and players
  void startGame({
    required List<Player> players,
    required GameSettings settings,
  }) {
    assert(players.isNotEmpty, 'Must have at least one player');
    assert(players.length <= 6, 'Cannot have more than 6 players');

    // Initialize dice
    final dice = List.generate(
      5,
      (index) => Die(id: index, value: 1, held: false),
    );

    // Initialize scoreboards for all players
    final scoreboards = <String, ScoreCard>{};
    for (final player in players) {
      scoreboards[player.id] = const ScoreCard();
    }

    state = GameState(
      phase: GamePhase.playing,
      players: players,
      settings: settings,
      activePlayerIndex: 0,
      currentRound: 1,
      rollCount: 0,
      dice: dice,
      scoreboards: scoreboards,
    );
  }

  /// Roll dice (non-held dice only)
  void rollDice() {
    if (!state.canRoll) {
      throw StateError('Cannot roll: maximum rolls reached');
    }

    final newDice = state.dice.map((die) {
      if (die.held) {
        return die;
      }
      return die.copyWith(value: _rng.rollDie());
    }).toList();

    state = state.copyWith(
      dice: newDice,
      rollCount: state.rollCount + 1,
    );
  }

  /// Toggle hold status of a die
  void toggleDieHold(int dieId) {
    if (!state.hasRolled) {
      throw StateError('Must roll before holding dice');
    }

    final newDice = state.dice.map((die) {
      if (die.id == dieId) {
        return die.copyWith(held: !die.held);
      }
      return die;
    }).toList();

    state = state.copyWith(dice: newDice);
  }

  /// Set hold status for multiple dice at once
  void setDiceHold(List<int> heldDiceIds) {
    if (!state.hasRolled) {
      throw StateError('Must roll before holding dice');
    }

    final heldSet = Set<int>.from(heldDiceIds);
    final newDice = state.dice.map((die) {
      return die.copyWith(held: heldSet.contains(die.id));
    }).toList();

    state = state.copyWith(dice: newDice);
  }

  /// Choose a category and commit the score
  void chooseCategory(ScoreCategory category) {
    if (!state.hasRolled) {
      throw StateError('Must roll before choosing category');
    }

    final activeCard = state.activeScoreCard;
    if (activeCard.isFilled(category)) {
      throw StateError('Category already filled');
    }

    // Calculate score
    final diceValues = state.dice.map((d) => d.value).toList();
    final score = _scoringEngine.scoreFor(category, diceValues);

    // Update scoreboard
    final newEntry = ScoreEntry(score: score);
    final newCard = activeCard.withEntry(category, newEntry);
    final newScoreboards = Map<String, ScoreCard>.from(state.scoreboards);
    newScoreboards[state.activePlayer.id] = newCard;

    // Check if game is complete
    final allComplete =
        newScoreboards.values.every((card) => card.isComplete);

    if (allComplete) {
      // Game complete
      state = state.copyWith(
        phase: GamePhase.complete,
        scoreboards: newScoreboards,
      );
    } else {
      // Advance to next turn
      _advanceTurn(newScoreboards);
    }
  }

  /// Scratch a category (score 0)
  void scratchCategory(ScoreCategory category) {
    if (!state.hasRolled) {
      throw StateError('Must roll before scratching category');
    }

    final activeCard = state.activeScoreCard;
    if (activeCard.isFilled(category)) {
      throw StateError('Category already filled');
    }

    // Update scoreboard with scratched entry
    final newEntry = const ScoreEntry(score: 0, isScratched: true);
    final newCard = activeCard.withEntry(category, newEntry);
    final newScoreboards = Map<String, ScoreCard>.from(state.scoreboards);
    newScoreboards[state.activePlayer.id] = newCard;

    // Check if game is complete
    final allComplete =
        newScoreboards.values.every((card) => card.isComplete);

    if (allComplete) {
      state = state.copyWith(
        phase: GamePhase.complete,
        scoreboards: newScoreboards,
      );
    } else {
      _advanceTurn(newScoreboards);
    }
  }

  /// Advance to the next turn
  void _advanceTurn(Map<String, ScoreCard> newScoreboards) {
    final nextPlayerIndex = (state.activePlayerIndex + 1) % state.players.length;
    final isNewRound = nextPlayerIndex == 0;

    // Reset dice for next turn
    final resetDice = state.dice.map((die) {
      return die.copyWith(held: false);
    }).toList();

    state = state.copyWith(
      scoreboards: newScoreboards,
      activePlayerIndex: nextPlayerIndex,
      currentRound: isNewRound ? state.currentRound + 1 : state.currentRound,
      rollCount: 0,
      dice: resetDice,
    );
  }

  /// Get potential scores for all available categories
  Map<ScoreCategory, int> getPotentialScores() {
    if (!state.hasRolled) {
      return {};
    }

    final diceValues = state.dice.map((d) => d.value).toList();
    return _scoringEngine.calculatePotentialScores(
      diceValues,
      state.activeScoreCard,
    );
  }

  /// Get game results with rankings
  List<PlayerResult> getResults() {
    if (state.phase != GamePhase.complete) {
      throw StateError('Game not complete');
    }

    final results = <PlayerResult>[];
    for (final player in state.players) {
      final scoreCard = state.scoreboards[player.id] ?? const ScoreCard();
      results.add(
        PlayerResult(
          player: player,
          scoreCard: scoreCard,
        ),
      );
    }

    // Sort by total score (descending)
    results.sort((a, b) => b.scoreCard.grandTotal.compareTo(a.scoreCard.grandTotal));

    return results;
  }

  /// Return to menu
  void returnToMenu() {
    state = const GameState(
      phase: GamePhase.menu,
      players: [],
      settings: GameSettings(),
    );
  }

  /// Load a saved game state
  void loadGameState(GameState savedState) {
    state = savedState;
  }
}

/// Result for a single player at game end
class PlayerResult {
  const PlayerResult({
    required this.player,
    required this.scoreCard,
  });

  final Player player;
  final ScoreCard scoreCard;

  int get rank => 0; // Set by sorting in getResults

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerResult &&
          runtimeType == other.runtimeType &&
          player == other.player &&
          scoreCard == other.scoreCard;

  @override
  int get hashCode => Object.hash(player, scoreCard);
}
