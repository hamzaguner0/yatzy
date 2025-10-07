import 'package:flutter_test/flutter_test.dart';
import 'package:yatzy_tr/core/rng.dart';
import 'package:yatzy_tr/features/game/application/game_controller.dart';
import 'package:yatzy_tr/features/game/domain/entities.dart';
import 'package:yatzy_tr/features/game/domain/scoring_engine.dart';

void main() {
  late GameController controller;
  late ScoringEngine scoringEngine;
  late RngFactory rngFactory;

  setUp(() {
    scoringEngine = const ScoringEngine();
    rngFactory = ({int? seed}) => RNG(seed: seed);
    controller = GameController(
      scoringEngine: scoringEngine,
      rngFactory: rngFactory,
    );
  });

  group('Game Flow', () {
    test('starts game with correct initial state', () {
      final players = [
        const Player(id: '1', displayName: 'Player 1'),
        const Player(id: '2', displayName: 'Player 2'),
      ];
      const settings = GameSettings(seed: 42);

      controller.startGame(players: players, settings: settings);

      final state = controller.state;
      expect(state.phase, GamePhase.playing);
      expect(state.players.length, 2);
      expect(state.currentRound, 1);
      expect(state.rollCount, 0);
      expect(state.dice.length, 5);
      expect(state.activePlayerIndex, 0);
    });

    test('rolls dice correctly', () {
      final players = [
        const Player(id: '1', displayName: 'Player 1'),
      ];
      const settings = GameSettings(seed: 42);

      controller.startGame(players: players, settings: settings);

      // Initial state - no rolls yet
      expect(controller.state.rollCount, 0);
      expect(controller.state.canRoll, true);

      // First roll
      controller.rollDice();
      expect(controller.state.rollCount, 1);
      expect(controller.state.hasRolled, true);

      // Save dice values
      final firstRoll = controller.state.dice.map((d) => d.value).toList();

      // Second roll (all dice should change)
      controller.rollDice();
      expect(controller.state.rollCount, 2);

      // Third roll
      controller.rollDice();
      expect(controller.state.rollCount, 3);
      expect(controller.state.canRoll, false);
    });

    test('holds dice correctly', () {
      final players = [
        const Player(id: '1', displayName: 'Player 1'),
      ];
      const settings = GameSettings(seed: 42);

      controller.startGame(players: players, settings: settings);
      controller.rollDice();

      final dieId = controller.state.dice.first.id;
      final initialValue = controller.state.dice.first.value;

      // Hold first die
      controller.toggleDieHold(dieId);
      expect(controller.state.dice.first.held, true);

      // Roll again - held die should not change
      controller.rollDice();
      expect(controller.state.dice.first.value, initialValue);
      expect(controller.state.dice.first.held, true);

      // Unheld dice should have changed (with high probability)
      final unHeldDiceChanged = controller.state.dice
          .where((d) => !d.held)
          .any((d) => d.value != initialValue);
      expect(unHeldDiceChanged, true);
    });

    test('chooses category and advances turn', () {
      final players = [
        const Player(id: '1', displayName: 'Player 1'),
        const Player(id: '2', displayName: 'Player 2'),
      ];
      const settings = GameSettings(seed: 42);

      controller.startGame(players: players, settings: settings);
      controller.rollDice();

      // Choose a category
      controller.chooseCategory(ScoreCategory.chance);

      // Should advance to next player
      expect(controller.state.activePlayerIndex, 1);
      expect(controller.state.rollCount, 0);
      expect(controller.state.dice.every((d) => !d.held), true);

      // Previous player's scorecard should be filled
      final player1Card = controller.state.scoreboards['1']!;
      expect(player1Card.isFilled(ScoreCategory.chance), true);
    });

    test('completes game after all categories filled', () {
      final players = [
        const Player(id: '1', displayName: 'Player 1'),
      ];
      const settings = GameSettings(seed: 42);

      controller.startGame(players: players, settings: settings);

      // Play through all 13 categories
      for (final category in ScoreCategory.values) {
        controller.rollDice();
        controller.chooseCategory(category);
      }

      // Game should be complete
      expect(controller.state.phase, GamePhase.complete);
      expect(controller.state.activeScoreCard.isComplete, true);
    });

    test('calculates upper bonus correctly', () {
      final players = [
        const Player(id: '1', displayName: 'Player 1'),
      ];
      const settings = GameSettings(seed: 42);

      controller.startGame(players: players, settings: settings);

      // Manually set high scores for upper section
      var scoreCard = const ScoreCard();
      scoreCard = scoreCard.withEntry(
        ScoreCategory.ones,
        const ScoreEntry(score: 5),
      );
      scoreCard = scoreCard.withEntry(
        ScoreCategory.twos,
        const ScoreEntry(score: 10),
      );
      scoreCard = scoreCard.withEntry(
        ScoreCategory.threes,
        const ScoreEntry(score: 15),
      );
      scoreCard = scoreCard.withEntry(
        ScoreCategory.fours,
        const ScoreEntry(score: 12),
      );
      scoreCard = scoreCard.withEntry(
        ScoreCategory.fives,
        const ScoreEntry(score: 10),
      );
      scoreCard = scoreCard.withEntry(
        ScoreCategory.sixes,
        const ScoreEntry(score: 12),
      );

      expect(scoreCard.upperSubtotal, 64);
      expect(scoreCard.upperBonus, 35);
      expect(scoreCard.upperTotal, 99);
    });

    test('does not allow choosing filled category', () {
      final players = [
        const Player(id: '1', displayName: 'Player 1'),
      ];
      const settings = GameSettings(seed: 42);

      controller.startGame(players: players, settings: settings);
      controller.rollDice();

      controller.chooseCategory(ScoreCategory.chance);

      // Next turn
      controller.rollDice();

      // Try to choose same category again
      expect(
        () => controller.chooseCategory(ScoreCategory.chance),
        throwsStateError,
      );
    });

    test('scratches category correctly', () {
      final players = [
        const Player(id: '1', displayName: 'Player 1'),
      ];
      const settings = GameSettings(seed: 42);

      controller.startGame(players: players, settings: settings);
      controller.rollDice();

      controller.scratchCategory(ScoreCategory.yahtzee);

      final scoreCard = controller.state.scoreboards['1']!;
      final entry = scoreCard.getEntry(ScoreCategory.yahtzee);

      expect(entry?.isFilled, true);
      expect(entry?.isScratched, true);
      expect(entry?.score, 0);
    });

    test('returns to menu correctly', () {
      final players = [
        const Player(id: '1', displayName: 'Player 1'),
      ];
      const settings = GameSettings(seed: 42);

      controller.startGame(players: players, settings: settings);
      controller.rollDice();

      controller.returnToMenu();

      expect(controller.state.phase, GamePhase.menu);
      expect(controller.state.players.isEmpty, true);
    });

    test('gets results with correct rankings', () {
      final players = [
        const Player(id: '1', displayName: 'Player 1'),
        const Player(id: '2', displayName: 'Player 2'),
      ];
      const settings = GameSettings(seed: 42);

      controller.startGame(players: players, settings: settings);

      // Simulate a complete game with different scores
      var scoreboards = controller.state.scoreboards;

      // Player 1 scores higher
      var card1 = const ScoreCard();
      card1 = card1.withEntry(
        ScoreCategory.yahtzee,
        const ScoreEntry(score: 50),
      );
      scoreboards['1'] = card1;

      // Player 2 scores lower
      var card2 = const ScoreCard();
      card2 = card2.withEntry(
        ScoreCategory.chance,
        const ScoreEntry(score: 20),
      );
      scoreboards['2'] = card2;

      // Fill remaining categories with scratches to complete game
      for (final category in ScoreCategory.values) {
        if (!card1.isFilled(category)) {
          card1 = card1.withEntry(
            category,
            const ScoreEntry(score: 0, isScratched: true),
          );
        }
        if (!card2.isFilled(category)) {
          card2 = card2.withEntry(
            category,
            const ScoreEntry(score: 0, isScratched: true),
          );
        }
      }

      scoreboards['1'] = card1;
      scoreboards['2'] = card2;

      // Update state to complete
      controller.state = controller.state.copyWith(
        phase: GamePhase.complete,
        scoreboards: scoreboards,
      );

      final results = controller.getResults();

      expect(results.length, 2);
      expect(results.first.player.id, '1');
      expect(results.last.player.id, '2');
      expect(
        results.first.scoreCard.grandTotal,
        greaterThan(results.last.scoreCard.grandTotal),
      );
    });
  });

  group('Deterministic RNG', () {
    test('produces same results with same seed', () {
      final rng1 = RNG(seed: 123);
      final rng2 = RNG(seed: 123);

      final rolls1 = List.generate(10, (_) => rng1.rollDie());
      final rolls2 = List.generate(10, (_) => rng2.rollDie());

      expect(rolls1, equals(rolls2));
    });

    test('produces different results with different seeds', () {
      final rng1 = RNG(seed: 123);
      final rng2 = RNG(seed: 456);

      final rolls1 = List.generate(10, (_) => rng1.rollDie());
      final rolls2 = List.generate(10, (_) => rng2.rollDie());

      expect(rolls1, isNot(equals(rolls2)));
    });
  });
}
