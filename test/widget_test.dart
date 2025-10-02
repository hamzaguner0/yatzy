import 'package:flutter_test/flutter_test.dart';
import 'package:yatzy_tr/features/game/domain/entities.dart';

/// Basic widget tests to ensure Flutter test framework is working
void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // This is a basic smoke test to verify test setup
    expect(1 + 1, 2);
  });

  group('Entity Tests', () {
    test('Die entity holds correct values', () {
      const die = Die(id: 0, value: 3, held: true);

      expect(die.id, 0);
      expect(die.value, 3);
      expect(die.held, true);
    });

    test('Player entity serialization', () {
      const player = Player(
        id: '1',
        displayName: 'Test Player',
        isAI: false,
      );

      final json = player.toJson();
      final deserialized = Player.fromJson(json);

      expect(deserialized.id, player.id);
      expect(deserialized.displayName, player.displayName);
      expect(deserialized.isAI, player.isAI);
    });

    test('ScoreCard calculates totals correctly', () {
      var scoreCard = const ScoreCard();

      scoreCard = scoreCard.withEntry(
        ScoreCategory.ones,
        const ScoreEntry(score: 3),
      );
      scoreCard = scoreCard.withEntry(
        ScoreCategory.twos,
        const ScoreEntry(score: 6),
      );
      scoreCard = scoreCard.withEntry(
        ScoreCategory.chance,
        const ScoreEntry(score: 20),
      );

      expect(scoreCard.upperSubtotal, 9);
      expect(scoreCard.lowerSubtotal, 20);
      expect(scoreCard.upperBonus, 0); // Less than 63
      expect(scoreCard.grandTotal, 29);
    });

    test('ScoreCard upper bonus awarded correctly', () {
      var scoreCard = const ScoreCard();

      // Fill upper section to get bonus
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
        const ScoreEntry(score: 11),
      );
      scoreCard = scoreCard.withEntry(
        ScoreCategory.sixes,
        const ScoreEntry(score: 12),
      );

      expect(scoreCard.upperSubtotal, 65);
      expect(scoreCard.upperBonus, 35);
      expect(scoreCard.upperTotal, 100);
    });

    test('GameState serialization round trip', () {
      final state = GameState(
        phase: GamePhase.playing,
        players: const [
          Player(id: '1', displayName: 'Player 1'),
          Player(id: '2', displayName: 'Player 2'),
        ],
        settings: const GameSettings(seed: 42),
        activePlayerIndex: 0,
        currentRound: 3,
        rollCount: 1,
        dice: const [
          Die(id: 0, value: 3, held: true),
          Die(id: 1, value: 5, held: false),
          Die(id: 2, value: 2, held: false),
          Die(id: 3, value: 6, held: false),
          Die(id: 4, value: 1, held: false),
        ],
        scoreboards: const {},
      );

      final json = state.toJson();
      final deserialized = GameState.fromJson(json);

      expect(deserialized.phase, state.phase);
      expect(deserialized.players.length, state.players.length);
      expect(deserialized.currentRound, state.currentRound);
      expect(deserialized.rollCount, state.rollCount);
      expect(deserialized.dice.length, state.dice.length);
      expect(deserialized.dice.first.value, state.dice.first.value);
      expect(deserialized.dice.first.held, state.dice.first.held);
    });
  });
}
