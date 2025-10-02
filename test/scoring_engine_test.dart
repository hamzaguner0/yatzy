import 'package:flutter_test/flutter_test.dart';
import 'package:yatzy_tr/features/game/domain/entities.dart';
import 'package:yatzy_tr/features/game/domain/scoring_engine.dart';

void main() {
  late ScoringEngine engine;

  setUp(() {
    engine = const ScoringEngine();
  });

  group('Upper Section Scoring', () {
    test('Ones - counts all ones', () {
      expect(engine.scoreFor(ScoreCategory.ones, [1, 1, 1, 2, 3]), 3);
      expect(engine.scoreFor(ScoreCategory.ones, [1, 2, 3, 4, 5]), 1);
      expect(engine.scoreFor(ScoreCategory.ones, [2, 3, 4, 5, 6]), 0);
      expect(engine.scoreFor(ScoreCategory.ones, [1, 1, 1, 1, 1]), 5);
    });

    test('Twos - counts all twos', () {
      expect(engine.scoreFor(ScoreCategory.twos, [2, 2, 2, 3, 4]), 6);
      expect(engine.scoreFor(ScoreCategory.twos, [1, 2, 3, 4, 5]), 2);
      expect(engine.scoreFor(ScoreCategory.twos, [1, 3, 4, 5, 6]), 0);
      expect(engine.scoreFor(ScoreCategory.twos, [2, 2, 2, 2, 2]), 10);
    });

    test('Threes - counts all threes', () {
      expect(engine.scoreFor(ScoreCategory.threes, [3, 3, 3, 1, 2]), 9);
      expect(engine.scoreFor(ScoreCategory.threes, [1, 2, 3, 4, 5]), 3);
      expect(engine.scoreFor(ScoreCategory.threes, [1, 2, 4, 5, 6]), 0);
      expect(engine.scoreFor(ScoreCategory.threes, [3, 3, 3, 3, 3]), 15);
    });

    test('Fours - counts all fours', () {
      expect(engine.scoreFor(ScoreCategory.fours, [4, 4, 4, 1, 2]), 12);
      expect(engine.scoreFor(ScoreCategory.fours, [1, 2, 3, 4, 5]), 4);
      expect(engine.scoreFor(ScoreCategory.fours, [1, 2, 3, 5, 6]), 0);
      expect(engine.scoreFor(ScoreCategory.fours, [4, 4, 4, 4, 4]), 20);
    });

    test('Fives - counts all fives', () {
      expect(engine.scoreFor(ScoreCategory.fives, [5, 5, 5, 1, 2]), 15);
      expect(engine.scoreFor(ScoreCategory.fives, [1, 2, 3, 4, 5]), 5);
      expect(engine.scoreFor(ScoreCategory.fives, [1, 2, 3, 4, 6]), 0);
      expect(engine.scoreFor(ScoreCategory.fives, [5, 5, 5, 5, 5]), 25);
    });

    test('Sixes - counts all sixes', () {
      expect(engine.scoreFor(ScoreCategory.sixes, [6, 6, 6, 1, 2]), 18);
      expect(engine.scoreFor(ScoreCategory.sixes, [1, 2, 3, 4, 6]), 6);
      expect(engine.scoreFor(ScoreCategory.sixes, [1, 2, 3, 4, 5]), 0);
      expect(engine.scoreFor(ScoreCategory.sixes, [6, 6, 6, 6, 6]), 30);
    });
  });

  group('Three of a Kind', () {
    test('returns sum of all dice when 3 or more match', () {
      expect(engine.scoreFor(ScoreCategory.threeOfAKind, [3, 3, 3, 2, 1]), 12);
      expect(engine.scoreFor(ScoreCategory.threeOfAKind, [5, 5, 5, 6, 6]), 27);
      expect(engine.scoreFor(ScoreCategory.threeOfAKind, [4, 4, 4, 4, 1]), 17);
      expect(engine.scoreFor(ScoreCategory.threeOfAKind, [6, 6, 6, 6, 6]), 30);
    });

    test('returns 0 when no three of a kind', () {
      expect(engine.scoreFor(ScoreCategory.threeOfAKind, [1, 2, 3, 4, 5]), 0);
      expect(engine.scoreFor(ScoreCategory.threeOfAKind, [1, 1, 2, 2, 3]), 0);
      expect(engine.scoreFor(ScoreCategory.threeOfAKind, [6, 6, 5, 4, 3]), 0);
    });
  });

  group('Four of a Kind', () {
    test('returns sum of all dice when 4 or more match', () {
      expect(engine.scoreFor(ScoreCategory.fourOfAKind, [4, 4, 4, 4, 2]), 18);
      expect(engine.scoreFor(ScoreCategory.fourOfAKind, [5, 5, 5, 5, 6]), 26);
      expect(engine.scoreFor(ScoreCategory.fourOfAKind, [6, 6, 6, 6, 6]), 30);
    });

    test('returns 0 when no four of a kind', () {
      expect(engine.scoreFor(ScoreCategory.fourOfAKind, [1, 2, 3, 4, 5]), 0);
      expect(engine.scoreFor(ScoreCategory.fourOfAKind, [3, 3, 3, 2, 1]), 0);
      expect(engine.scoreFor(ScoreCategory.fourOfAKind, [5, 5, 5, 6, 6]), 0);
    });
  });

  group('Full House', () {
    test('returns 25 for valid full house (3 + 2)', () {
      expect(engine.scoreFor(ScoreCategory.fullHouse, [3, 3, 3, 2, 2]), 25);
      expect(engine.scoreFor(ScoreCategory.fullHouse, [5, 5, 6, 6, 6]), 25);
      expect(engine.scoreFor(ScoreCategory.fullHouse, [1, 1, 4, 4, 4]), 25);
    });

    test('returns 0 for invalid combinations', () {
      expect(engine.scoreFor(ScoreCategory.fullHouse, [1, 2, 3, 4, 5]), 0);
      expect(engine.scoreFor(ScoreCategory.fullHouse, [3, 3, 3, 3, 2]), 0);
      expect(engine.scoreFor(ScoreCategory.fullHouse, [5, 5, 5, 5, 5]), 0);
      expect(engine.scoreFor(ScoreCategory.fullHouse, [1, 1, 2, 3, 4]), 0);
    });
  });

  group('Small Straight', () {
    test('returns 30 for sequence of 4', () {
      expect(engine.scoreFor(ScoreCategory.smallStraight, [1, 2, 3, 4, 6]), 30);
      expect(engine.scoreFor(ScoreCategory.smallStraight, [2, 3, 4, 5, 1]), 30);
      expect(engine.scoreFor(ScoreCategory.smallStraight, [3, 4, 5, 6, 1]), 30);
      expect(engine.scoreFor(ScoreCategory.smallStraight, [1, 2, 3, 4, 5]), 30);
    });

    test('returns 0 when no sequence of 4', () {
      expect(engine.scoreFor(ScoreCategory.smallStraight, [1, 2, 3, 5, 6]), 0);
      expect(engine.scoreFor(ScoreCategory.smallStraight, [1, 3, 4, 5, 6]), 0);
      expect(engine.scoreFor(ScoreCategory.smallStraight, [1, 1, 1, 1, 1]), 0);
      expect(engine.scoreFor(ScoreCategory.smallStraight, [1, 2, 4, 5, 6]), 0);
    });
  });

  group('Large Straight', () {
    test('returns 40 for sequence of 5', () {
      expect(engine.scoreFor(ScoreCategory.largeStraight, [1, 2, 3, 4, 5]), 40);
      expect(engine.scoreFor(ScoreCategory.largeStraight, [2, 3, 4, 5, 6]), 40);
      expect(engine.scoreFor(ScoreCategory.largeStraight, [5, 4, 3, 2, 1]), 40);
    });

    test('returns 0 when no sequence of 5', () {
      expect(engine.scoreFor(ScoreCategory.largeStraight, [1, 2, 3, 4, 6]), 0);
      expect(engine.scoreFor(ScoreCategory.largeStraight, [1, 3, 4, 5, 6]), 0);
      expect(engine.scoreFor(ScoreCategory.largeStraight, [1, 1, 1, 1, 1]), 0);
      expect(engine.scoreFor(ScoreCategory.largeStraight, [1, 2, 3, 4, 4]), 0);
    });
  });

  group('Chance', () {
    test('returns sum of all dice', () {
      expect(engine.scoreFor(ScoreCategory.chance, [1, 2, 3, 4, 5]), 15);
      expect(engine.scoreFor(ScoreCategory.chance, [6, 6, 6, 6, 6]), 30);
      expect(engine.scoreFor(ScoreCategory.chance, [1, 1, 1, 1, 1]), 5);
      expect(engine.scoreFor(ScoreCategory.chance, [3, 4, 5, 6, 2]), 20);
    });
  });

  group('Yahtzee', () {
    test('returns 50 when all dice match', () {
      expect(engine.scoreFor(ScoreCategory.yahtzee, [1, 1, 1, 1, 1]), 50);
      expect(engine.scoreFor(ScoreCategory.yahtzee, [3, 3, 3, 3, 3]), 50);
      expect(engine.scoreFor(ScoreCategory.yahtzee, [6, 6, 6, 6, 6]), 50);
    });

    test('returns 0 when not all dice match', () {
      expect(engine.scoreFor(ScoreCategory.yahtzee, [1, 1, 1, 1, 2]), 0);
      expect(engine.scoreFor(ScoreCategory.yahtzee, [1, 2, 3, 4, 5]), 0);
      expect(engine.scoreFor(ScoreCategory.yahtzee, [6, 6, 6, 6, 5]), 0);
    });
  });

  group('Edge Cases', () {
    test('handles all same value correctly across categories', () {
      const allSixes = [6, 6, 6, 6, 6];
      expect(engine.scoreFor(ScoreCategory.sixes, allSixes), 30);
      expect(engine.scoreFor(ScoreCategory.threeOfAKind, allSixes), 30);
      expect(engine.scoreFor(ScoreCategory.fourOfAKind, allSixes), 30);
      expect(engine.scoreFor(ScoreCategory.fullHouse, allSixes), 0);
      expect(engine.scoreFor(ScoreCategory.chance, allSixes), 30);
      expect(engine.scoreFor(ScoreCategory.yahtzee, allSixes), 50);
    });

    test('handles large straight as small straight too', () {
      const largeStraight = [1, 2, 3, 4, 5];
      expect(engine.scoreFor(ScoreCategory.smallStraight, largeStraight), 30);
      expect(engine.scoreFor(ScoreCategory.largeStraight, largeStraight), 40);
    });

    test('four of a kind counts as three of a kind', () {
      const fourOfAKind = [4, 4, 4, 4, 2];
      expect(engine.scoreFor(ScoreCategory.threeOfAKind, fourOfAKind), 18);
      expect(engine.scoreFor(ScoreCategory.fourOfAKind, fourOfAKind), 18);
    });
  });

  group('Potential Scores', () {
    test('calculates potential scores for unfilled categories', () {
      final dice = [3, 3, 3, 4, 5];
      final scoreCard = const ScoreCard(
        entries: {
          ScoreCategory.ones: ScoreEntry(score: 1),
          ScoreCategory.twos: ScoreEntry(score: 0, isScratched: true),
        },
      );

      final potentials = engine.calculatePotentialScores(dice, scoreCard);

      expect(potentials.containsKey(ScoreCategory.ones), false);
      expect(potentials.containsKey(ScoreCategory.twos), false);
      expect(potentials[ScoreCategory.threes], 9);
      expect(potentials[ScoreCategory.threeOfAKind], 18);
      expect(potentials[ScoreCategory.chance], 18);
    });

    test('returns empty map when all categories filled', () {
      final dice = [1, 2, 3, 4, 5];
      final entries = <ScoreCategory, ScoreEntry>{};
      for (final category in ScoreCategory.values) {
        entries[category] = const ScoreEntry(score: 10);
      }
      final scoreCard = ScoreCard(entries: entries);

      final potentials = engine.calculatePotentialScores(dice, scoreCard);
      expect(potentials.isEmpty, true);
    });
  });

  group('Expected Values', () {
    test('returns reasonable expected values for all categories', () {
      for (final category in ScoreCategory.values) {
        final ev = engine.expectedValueFor(category);
        expect(ev, greaterThan(0));
        expect(ev, lessThan(20));
      }
    });

    test('upper section values increase with die value', () {
      expect(
        engine.expectedValueFor(ScoreCategory.ones),
        lessThan(engine.expectedValueFor(ScoreCategory.twos)),
      );
      expect(
        engine.expectedValueFor(ScoreCategory.twos),
        lessThan(engine.expectedValueFor(ScoreCategory.threes)),
      );
      expect(
        engine.expectedValueFor(ScoreCategory.fives),
        lessThan(engine.expectedValueFor(ScoreCategory.sixes)),
      );
    });
  });

  group('Validation', () {
    test('asserts on invalid dice count', () {
      expect(
        () => engine.scoreFor(ScoreCategory.ones, [1, 2, 3]),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => engine.scoreFor(ScoreCategory.ones, [1, 2, 3, 4, 5, 6]),
        throwsA(isA<AssertionError>()),
      );
    });

    test('asserts on invalid die values', () {
      expect(
        () => engine.scoreFor(ScoreCategory.ones, [0, 1, 2, 3, 4]),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => engine.scoreFor(ScoreCategory.ones, [1, 2, 3, 4, 7]),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}
