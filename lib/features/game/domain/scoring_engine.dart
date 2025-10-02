import 'package:yatzy_tr/features/game/domain/entities.dart';

/// Pure, deterministic scoring engine for Yatzy game
/// All methods are side-effect free and deterministic
class ScoringEngine {
  const ScoringEngine();

  /// Calculate score for a given category and dice combination
  int scoreFor(ScoreCategory category, List<int> dice) {
    assert(dice.length == 5, 'Must have exactly 5 dice');
    assert(
      dice.every((d) => d >= 1 && d <= 6),
      'All dice must be between 1 and 6',
    );

    switch (category) {
      case ScoreCategory.ones:
        return _sumOf(dice, 1);
      case ScoreCategory.twos:
        return _sumOf(dice, 2);
      case ScoreCategory.threes:
        return _sumOf(dice, 3);
      case ScoreCategory.fours:
        return _sumOf(dice, 4);
      case ScoreCategory.fives:
        return _sumOf(dice, 5);
      case ScoreCategory.sixes:
        return _sumOf(dice, 6);
      case ScoreCategory.threeOfAKind:
        return _nOfAKind(dice, 3);
      case ScoreCategory.fourOfAKind:
        return _nOfAKind(dice, 4);
      case ScoreCategory.fullHouse:
        return _fullHouse(dice);
      case ScoreCategory.smallStraight:
        return _smallStraight(dice);
      case ScoreCategory.largeStraight:
        return _largeStraight(dice);
      case ScoreCategory.chance:
        return _chance(dice);
      case ScoreCategory.yahtzee:
        return _yahtzee(dice);
    }
  }

  /// Sum all dice showing the target value
  int _sumOf(List<int> dice, int target) =>
      dice.where((d) => d == target).fold(0, (sum, d) => sum + d);

  /// Check for N of a kind and return sum of all dice if found, otherwise 0
  int _nOfAKind(List<int> dice, int n) {
    final counts = _countDice(dice);
    final hasNOfAKind = counts.values.any((count) => count >= n);
    return hasNOfAKind ? dice.reduce((a, b) => a + b) : 0;
  }

  /// Check for full house (3 of one kind + 2 of another)
  int _fullHouse(List<int> dice) {
    final counts = _countDice(dice);
    final hasThree = counts.values.any((count) => count == 3);
    final hasTwo = counts.values.any((count) => count == 2);

    // Must have exactly 2 different values, one with 3, one with 2
    if (counts.length == 2 && hasThree && hasTwo) {
      return 25;
    }
    return 0;
  }

  /// Check for small straight (sequence of 4)
  /// Valid sequences: 1-2-3-4, 2-3-4-5, 3-4-5-6
  int _smallStraight(List<int> dice) {
    final unique = dice.toSet().toList()..sort();

    // Check for any sequence of 4 consecutive numbers
    if (_hasSequence(unique, 4)) {
      return 30;
    }
    return 0;
  }

  /// Check for large straight (sequence of 5)
  /// Valid sequences: 1-2-3-4-5, 2-3-4-5-6
  int _largeStraight(List<int> dice) {
    final unique = dice.toSet().toList()..sort();

    // Must have exactly 5 unique values in sequence
    if (unique.length == 5 && _hasSequence(unique, 5)) {
      return 40;
    }
    return 0;
  }

  /// Check if list contains a consecutive sequence of given length
  bool _hasSequence(List<int> sortedUnique, int length) {
    if (sortedUnique.length < length) return false;

    for (var i = 0; i <= sortedUnique.length - length; i++) {
      var isSequence = true;
      for (var j = 0; j < length - 1; j++) {
        if (sortedUnique[i + j + 1] != sortedUnique[i + j] + 1) {
          isSequence = false;
          break;
        }
      }
      if (isSequence) return true;
    }
    return false;
  }

  /// Sum of all dice (no conditions)
  int _chance(List<int> dice) => dice.reduce((a, b) => a + b);

  /// Check for Yahtzee (all 5 dice same value)
  int _yahtzee(List<int> dice) {
    final first = dice.first;
    return dice.every((d) => d == first) ? 50 : 0;
  }

  /// Count occurrences of each die value
  Map<int, int> _countDice(List<int> dice) {
    final counts = <int, int>{};
    for (final die in dice) {
      counts[die] = (counts[die] ?? 0) + 1;
    }
    return counts;
  }

  /// Calculate potential score preview for all unfilled categories
  Map<ScoreCategory, int> calculatePotentialScores(
    List<int> dice,
    ScoreCard scoreCard,
  ) {
    final potentials = <ScoreCategory, int>{};
    for (final category in ScoreCategory.values) {
      if (!scoreCard.isFilled(category)) {
        potentials[category] = scoreFor(category, dice);
      }
    }
    return potentials;
  }

  /// Calculate expected value for a category (used by AI)
  /// Returns the average score if this category is kept open
  double expectedValueFor(ScoreCategory category) {
    // Simplified expected values based on probability analysis
    // These are approximations for AI decision-making
    switch (category) {
      case ScoreCategory.ones:
        return 2.8;
      case ScoreCategory.twos:
        return 5.6;
      case ScoreCategory.threes:
        return 8.3;
      case ScoreCategory.fours:
        return 11.1;
      case ScoreCategory.fives:
        return 13.9;
      case ScoreCategory.sixes:
        return 16.7;
      case ScoreCategory.threeOfAKind:
        return 15.0;
      case ScoreCategory.fourOfAKind:
        return 10.0;
      case ScoreCategory.fullHouse:
        return 8.0;
      case ScoreCategory.smallStraight:
        return 10.0;
      case ScoreCategory.largeStraight:
        return 8.0;
      case ScoreCategory.chance:
        return 17.5;
      case ScoreCategory.yahtzee:
        return 4.6;
    }
  }
}
