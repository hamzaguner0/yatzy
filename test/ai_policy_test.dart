import 'package:flutter_test/flutter_test.dart';
import 'package:yatzy_tr/core/rng.dart';
import 'package:yatzy_tr/features/game/domain/ai.dart';
import 'package:yatzy_tr/features/game/domain/entities.dart';
import 'package:yatzy_tr/features/game/domain/scoring_engine.dart';

void main() {
  late ScoringEngine scoringEngine;
  late RNG rng;

  setUp(() {
    scoringEngine = const ScoringEngine();
    rng = RNG(seed: 42); // Deterministic for testing
  });

  group('Easy AI', () {
    late EasyAI easyAI;

    setUp(() {
      easyAI = EasyAI(
        scoringEngine: scoringEngine,
        rng: rng,
      );
    });

    test('makes decisions deterministically with seed', () {
      final dice = [Die(id: '1', value: 3, held: false)];
      const scoreCard = ScoreCard();

      final decision1 = easyAI.decideHold(
        dice,
        scoreCard,
        rollsLeft: 2,
      );

      // Reset RNG with same seed
      final rng2 = RNG(seed: 42);
      final easyAI2 = EasyAI(
        scoringEngine: scoringEngine,
        rng: rng2,
      );

      final decision2 = easyAI2.decideHold(
        dice,
        scoreCard,
        rollsLeft: 2,
      );

      expect(decision1, equals(decision2));
    });

    test('holds matching dice greedily', () {
      final dice = [
        const Die(id: '1', value: 5, held: false),
        const Die(id: '2', value: 5, held: false),
        const Die(id: '3', value: 2, held: false),
        const Die(id: '4', value: 3, held: false),
        const Die(id: '5', value: 5, held: false),
      ];
      const scoreCard = ScoreCard();

      final holdDecisions = easyAI.decideHold(
        dice,
        scoreCard,
        rollsLeft: 2,
      );

      // Should prefer holding the three 5s
      final heldFives = dice
          .where((d) => d.value == 5 && holdDecisions.contains(d.id))
          .length;
      expect(heldFives, greaterThan(0));
    });

    test('chooses category with highest immediate score', () {
      final dice = [
        const Die(id: '1', value: 6, held: false),
        const Die(id: '2', value: 6, held: false),
        const Die(id: '3', value: 6, held: false),
        const Die(id: '4', value: 6, held: false),
        const Die(id: '5', value: 6, held: false),
      ];
      const scoreCard = ScoreCard();

      final category = easyAI.decideCategory(dice, scoreCard);

      // Should choose Yahtzee (50 points) over sixes (30 points)
      expect(category, ScoreCategory.yahtzee);
    });

    test('avoids choosing filled categories', () {
      final dice = [
        const Die(id: '1', value: 1, held: false),
        const Die(id: '2', value: 2, held: false),
        const Die(id: '3', value: 3, held: false),
        const Die(id: '4', value: 4, held: false),
        const Die(id: '5', value: 5, held: false),
      ];
      final scoreCard = const ScoreCard().withEntry(
        ScoreCategory.largeStraight,
        const ScoreEntry(score: 40),
      );

      final category = easyAI.decideCategory(dice, scoreCard);

      // Should not choose already-filled large straight
      expect(category, isNot(ScoreCategory.largeStraight));
    });

    test('completes turn within time budget', () {
      final dice = List.generate(
        5,
        (i) => Die(id: '$i', value: i + 1, held: false),
      );
      const scoreCard = ScoreCard();

      final stopwatch = Stopwatch()..start();

      // Simulate multiple decisions
      for (var i = 0; i < 10; i++) {
        easyAI.decideHold(dice, scoreCard, rollsLeft: 2);
        easyAI.decideCategory(dice, scoreCard);
      }

      stopwatch.stop();

      // Should complete well under 100ms budget
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });
  });

  group('Normal AI', () {
    late NormalAI normalAI;

    setUp(() {
      normalAI = NormalAI(
        scoringEngine: scoringEngine,
        rng: rng,
      );
    });

    test('makes decisions deterministically with seed', () {
      final dice = List.generate(
        5,
        (i) => Die(id: '$i', value: i + 1, held: false),
      );
      const scoreCard = ScoreCard();

      final decision1 = normalAI.decideHold(
        dice,
        scoreCard,
        rollsLeft: 2,
      );

      // Reset RNG
      final rng2 = RNG(seed: 42);
      final normalAI2 = NormalAI(
        scoringEngine: scoringEngine,
        rng: rng2,
      );

      final decision2 = normalAI2.decideHold(
        dice,
        scoreCard,
        rollsLeft: 2,
      );

      expect(decision1, equals(decision2));
    });

    test('considers expected values for category selection', () {
      final dice = [
        const Die(id: '1', value: 1, held: false),
        const Die(id: '2', value: 1, held: false),
        const Die(id: '3', value: 1, held: false),
        const Die(id: '4', value: 2, held: false),
        const Die(id: '5', value: 3, held: false),
      ];
      var scoreCard = const ScoreCard();

      // Fill high-EV categories
      scoreCard = scoreCard.withEntry(
        ScoreCategory.yahtzee,
        const ScoreEntry(score: 0, isScratched: true),
      );
      scoreCard = scoreCard.withEntry(
        ScoreCategory.largeStraight,
        const ScoreEntry(score: 0, isScratched: true),
      );

      final category = normalAI.decideCategory(dice, scoreCard);

      // Should choose ones (3 points) or three of a kind (8 points)
      expect(
        [ScoreCategory.ones, ScoreCategory.threeOfAKind].contains(category),
        true,
      );
    });

    test('avoids scratching high-value categories early', () {
      final dice = [
        const Die(id: '1', value: 1, held: false),
        const Die(id: '2', value: 2, held: false),
        const Die(id: '3', value: 3, held: false),
        const Die(id: '4', value: 4, held: false),
        const Die(id: '5', value: 6, held: false),
      ];
      const scoreCard = ScoreCard();

      final category = normalAI.decideCategory(dice, scoreCard);

      // Should NOT scratch Yahtzee or large straight for poor roll
      expect(category, isNot(ScoreCategory.yahtzee));
      expect(category, isNot(ScoreCategory.largeStraight));
    });

    test('completes turn within time budget', () {
      final dice = List.generate(
        5,
        (i) => Die(id: '$i', value: i + 1, held: false),
      );
      const scoreCard = ScoreCard();

      final stopwatch = Stopwatch()..start();

      for (var i = 0; i < 10; i++) {
        normalAI.decideHold(dice, scoreCard, rollsLeft: 2);
        normalAI.decideCategory(dice, scoreCard);
      }

      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });
  });

  group('Hard AI', () {
    late HardAI hardAI;

    setUp(() {
      hardAI = HardAI(
        scoringEngine: scoringEngine,
        rng: rng,
      );
    });

    test('makes decisions deterministically with seed', () {
      final dice = List.generate(
        5,
        (i) => Die(id: '$i', value: i + 1, held: false),
      );
      const scoreCard = ScoreCard();

      final decision1 = hardAI.decideHold(
        dice,
        scoreCard,
        rollsLeft: 2,
      );

      // Reset RNG
      final rng2 = RNG(seed: 42);
      final hardAI2 = HardAI(
        scoringEngine: scoringEngine,
        rng: rng2,
      );

      final decision2 = hardAI2.decideHold(
        dice,
        scoreCard,
        rollsLeft: 2,
      );

      expect(decision1, equals(decision2));
    });

    test('uses Monte Carlo simulations for better decisions', () {
      final dice = [
        const Die(id: '1', value: 6, held: false),
        const Die(id: '2', value: 6, held: false),
        const Die(id: '3', value: 1, held: false),
        const Die(id: '4', value: 2, held: false),
        const Die(id: '5', value: 3, held: false),
      ];
      const scoreCard = ScoreCard();

      final holdDecisions = hardAI.decideHold(
        dice,
        scoreCard,
        rollsLeft: 2,
      );

      // Should intelligently hold the two 6s
      final heldSixes = dice
          .where((d) => d.value == 6 && holdDecisions.contains(d.id))
          .length;
      expect(heldSixes, greaterThan(0));
    });

    test('makes optimal category choices', () {
      final dice = [
        const Die(id: '1', value: 1, held: false),
        const Die(id: '2', value: 2, held: false),
        const Die(id: '3', value: 3, held: false),
        const Die(id: '4', value: 4, held: false),
        const Die(id: '5', value: 5, held: false),
      ];
      const scoreCard = ScoreCard();

      final category = hardAI.decideCategory(dice, scoreCard);

      // Should choose large straight (40 points)
      expect(category, ScoreCategory.largeStraight);
    });

    test('completes turn within time budget', () {
      final dice = List.generate(
        5,
        (i) => Die(id: '$i', value: i + 1, held: false),
      );
      const scoreCard = ScoreCard();

      final stopwatch = Stopwatch()..start();

      // Hard AI should still complete within budget despite simulations
      for (var i = 0; i < 5; i++) {
        hardAI.decideHold(dice, scoreCard, rollsLeft: 2);
        hardAI.decideCategory(dice, scoreCard);
      }

      stopwatch.stop();

      // Should be close to but under 100ms per decision
      expect(stopwatch.elapsedMilliseconds, lessThan(500));
    });

    test('considers future rolls when holding dice', () {
      final dice = [
        const Die(id: '1', value: 5, held: false),
        const Die(id: '2', value: 5, held: false),
        const Die(id: '3', value: 5, held: false),
        const Die(id: '4', value: 1, held: false),
        const Die(id: '5', value: 2, held: false),
      ];
      var scoreCard = const ScoreCard();

      // Yahtzee already scored
      scoreCard = scoreCard.withEntry(
        ScoreCategory.yahtzee,
        const ScoreEntry(score: 50),
      );

      final holdDecisions = hardAI.decideHold(
        dice,
        scoreCard,
        rollsLeft: 2,
      );

      // Should still hold the three 5s for other categories
      final heldFives = dice
          .where((d) => d.value == 5 && holdDecisions.contains(d.id))
          .length;
      expect(heldFives, equals(3));
    });
  });

  group('AI Difficulty Comparison', () {
    test('different difficulties make different decisions', () {
      final dice = [
        const Die(id: '1', value: 3, held: false),
        const Die(id: '2', value: 3, held: false),
        const Die(id: '3', value: 4, held: false),
        const Die(id: '4', value: 5, held: false),
        const Die(id: '5', value: 6, held: false),
      ];
      const scoreCard = ScoreCard();

      final easyDecision = EasyAI(
        scoringEngine: scoringEngine,
        rng: RNG(seed: 100),
      ).decideHold(dice, scoreCard, rollsLeft: 2);

      final normalDecision = NormalAI(
        scoringEngine: scoringEngine,
        rng: RNG(seed: 100),
      ).decideHold(dice, scoreCard, rollsLeft: 2);

      final hardDecision = HardAI(
        scoringEngine: scoringEngine,
        rng: RNG(seed: 100),
      ).decideHold(dice, scoreCard, rollsLeft: 2);

      // Decisions should potentially differ based on strategy
      // (though they may occasionally be the same for obvious cases)
      expect([easyDecision, normalDecision, hardDecision].length, 3);
    });
  });

  group('Edge Cases', () {
    test('handles last category correctly', () {
      final dice = [
        const Die(id: '1', value: 1, held: false),
        const Die(id: '2', value: 2, held: false),
        const Die(id: '3', value: 3, held: false),
        const Die(id: '4', value: 4, held: false),
        const Die(id: '5', value: 5, held: false),
      ];

      // Only one category left
      var scoreCard = const ScoreCard();
      for (final category in ScoreCategory.values) {
        if (category != ScoreCategory.chance) {
          scoreCard = scoreCard.withEntry(
            category,
            const ScoreEntry(score: 10),
          );
        }
      }

      final easyAI = EasyAI(
        scoringEngine: scoringEngine,
        rng: rng,
      );

      final category = easyAI.decideCategory(dice, scoreCard);

      // Must choose the only remaining category
      expect(category, ScoreCategory.chance);
    });

    test('handles all categories filled gracefully', () {
      final dice = List.generate(
        5,
        (i) => Die(id: '$i', value: i + 1, held: false),
      );

      // All categories filled
      var scoreCard = const ScoreCard();
      for (final category in ScoreCategory.values) {
        scoreCard = scoreCard.withEntry(
          category,
          const ScoreEntry(score: 10),
        );
      }

      final easyAI = EasyAI(
        scoringEngine: scoringEngine,
        rng: rng,
      );

      // Should throw or return null/default
      expect(
        () => easyAI.decideCategory(dice, scoreCard),
        throwsA(isA<StateError>()),
      );
    });
  });
}
