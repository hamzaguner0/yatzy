import 'dart:math' as math;

import 'package:yatzy_tr/core/rng.dart';
import 'package:yatzy_tr/features/game/domain/entities.dart';
import 'package:yatzy_tr/features/game/domain/scoring_engine.dart';

/// AI decision: which dice to keep and whether to roll again
class AIKeepDecision {
  const AIKeepDecision({
    required this.diceToKeep,
    required this.shouldRoll,
  });

  final List<int> diceToKeep; // Die IDs to keep
  final bool shouldRoll; // Whether to roll again (or choose category)
}

/// AI decision: which category to choose
class AICategoryDecision {
  const AICategoryDecision({
    required this.category,
    this.reasoning,
  });

  final ScoreCategory category;
  final String? reasoning;
}

/// Base class for AI policy
abstract class AIPolicy {
  const AIPolicy({
    required this.scoringEngine,
    required this.rng,
  });

  final ScoringEngine scoringEngine;
  final RNG rng;

  /// Decide which dice to keep and whether to roll again
  AIKeepDecision decideKeep({
    required List<Die> dice,
    required ScoreCard scoreCard,
    required int rollCount,
    required int maxRolls,
  });

  /// Decide which category to choose
  AICategoryDecision decideCategory({
    required List<Die> dice,
    required ScoreCard scoreCard,
  });
}

/// Easy AI: Greedy heuristic
class EasyAI extends AIPolicy {
  const EasyAI({
    required super.scoringEngine,
    required super.rng,
  });

  @override
  AIKeepDecision decideKeep({
    required List<Die> dice,
    required ScoreCard scoreCard,
    required int rollCount,
    required int maxRolls,
  }) {
    // Simple greedy: keep the most common value
    final diceValues = dice.map((d) => d.value).toList();
    final counts = <int, int>{};
    for (final value in diceValues) {
      counts[value] = (counts[value] ?? 0) + 1;
    }

    // Find most common value
    var maxCount = 0;
    var bestValue = 0;
    for (final entry in counts.entries) {
      if (entry.value > maxCount) {
        maxCount = entry.value;
        bestValue = entry.key;
      }
    }

    // Keep dice with the most common value
    final diceToKeep = <int>[];
    for (final die in dice) {
      if (die.value == bestValue) {
        diceToKeep.add(die.id);
      }
    }

    // Roll again unless we have 3+ of a kind or it's the last roll
    final shouldRoll = maxCount < 3 && rollCount < maxRolls;

    return AIKeepDecision(
      diceToKeep: diceToKeep,
      shouldRoll: shouldRoll,
    );
  }

  @override
  AICategoryDecision decideCategory({
    required List<Die> dice,
    required ScoreCard scoreCard,
  }) {
    // Choose the category with the highest immediate score
    final diceValues = dice.map((d) => d.value).toList();
    final potentials = scoringEngine.calculatePotentialScores(
      diceValues,
      scoreCard,
    );

    if (potentials.isEmpty) {
      throw StateError('No available categories');
    }

    var bestCategory = potentials.keys.first;
    var bestScore = potentials[bestCategory]!;

    for (final entry in potentials.entries) {
      if (entry.value > bestScore) {
        bestCategory = entry.key;
        bestScore = entry.value;
      }
    }

    return AICategoryDecision(category: bestCategory);
  }
}

/// Normal AI: 1-step lookahead with expected values
class NormalAI extends AIPolicy {
  const NormalAI({
    required super.scoringEngine,
    required super.rng,
  });

  @override
  AIKeepDecision decideKeep({
    required List<Die> dice,
    required ScoreCard scoreCard,
    required int rollCount,
    required int maxRolls,
  }) {
    // If last roll, keep everything
    if (rollCount >= maxRolls) {
      return AIKeepDecision(
        diceToKeep: dice.map((d) => d.id).toList(),
        shouldRoll: false,
      );
    }

    // Evaluate different keep strategies
    final diceValues = dice.map((d) => d.value).toList();
    final strategies = _generateKeepStrategies(diceValues);

    var bestStrategy = <int>[];
    var bestEV = 0.0;

    for (final strategy in strategies) {
      final ev = _evaluateStrategy(strategy, diceValues, scoreCard);
      if (ev > bestEV) {
        bestEV = ev;
        bestStrategy = strategy;
      }
    }

    // Convert values back to die IDs
    final diceToKeep = <int>[];
    final strategySet = Set<int>.from(bestStrategy);
    for (final die in dice) {
      if (strategySet.contains(die.value)) {
        diceToKeep.add(die.id);
        strategySet.remove(die.value);
      }
    }

    return AIKeepDecision(
      diceToKeep: diceToKeep,
      shouldRoll: rollCount < maxRolls,
    );
  }

  /// Generate candidate keep strategies
  List<List<int>> _generateKeepStrategies(List<int> dice) {
    final strategies = <List<int>>[];

    // Strategy 1: Keep nothing (reroll all)
    strategies.add([]);

    // Strategy 2-7: Keep all of each value
    for (var value = 1; value <= 6; value++) {
      final keep = dice.where((d) => d == value).toList();
      if (keep.isNotEmpty) {
        strategies.add(keep);
      }
    }

    // Strategy 8: Keep pairs
    final counts = <int, int>{};
    for (final value in dice) {
      counts[value] = (counts[value] ?? 0) + 1;
    }
    for (final entry in counts.entries) {
      if (entry.value >= 2) {
        final keep = dice.where((d) => d == entry.key).toList();
        strategies.add(keep);
      }
    }

    return strategies;
  }

  /// Evaluate expected value of a keep strategy
  double _evaluateStrategy(
    List<int> keep,
    List<int> allDice,
    ScoreCard scoreCard,
  ) {
    // Simple heuristic: current best score + value of kept dice
    final potentials = scoringEngine.calculatePotentialScores(
      allDice,
      scoreCard,
    );

    if (potentials.isEmpty) return 0;

    final currentBest = potentials.values.reduce(math.max).toDouble();
    final keepValue = keep.isEmpty ? 0 : keep.reduce((a, b) => a + b);

    return currentBest + keepValue * 0.5;
  }

  @override
  AICategoryDecision decideCategory({
    required List<Die> dice,
    required ScoreCard scoreCard,
  }) {
    final diceValues = dice.map((d) => d.value).toList();
    final potentials = scoringEngine.calculatePotentialScores(
      diceValues,
      scoreCard,
    );

    if (potentials.isEmpty) {
      throw StateError('No available categories');
    }

    // Choose based on score value vs expected value tradeoff
    var bestCategory = potentials.keys.first;
    var bestScore = _categoryValue(bestCategory, potentials[bestCategory]!, scoreCard);

    for (final entry in potentials.entries) {
      final value = _categoryValue(entry.key, entry.value, scoreCard);
      if (value > bestScore) {
        bestCategory = entry.key;
        bestScore = value;
      }
    }

    return AICategoryDecision(category: bestCategory);
  }

  /// Evaluate category value considering opportunity cost
  double _categoryValue(
    ScoreCategory category,
    int actualScore,
    ScoreCard scoreCard,
  ) {
    final expectedValue = scoringEngine.expectedValueFor(category);
    // If actual score is much better than expected, take it
    // Otherwise, consider opportunity cost
    return actualScore - expectedValue * 0.3;
  }
}

/// Hard AI: Monte Carlo simulation
class HardAI extends AIPolicy {
  const HardAI({
    required super.scoringEngine,
    required super.rng,
    this.simulations = 5000,
    this.timeBudgetMs = 100,
  });

  final int simulations;
  final int timeBudgetMs;

  @override
  AIKeepDecision decideKeep({
    required List<Die> dice,
    required ScoreCard scoreCard,
    required int rollCount,
    required int maxRolls,
  }) {
    if (rollCount >= maxRolls) {
      return AIKeepDecision(
        diceToKeep: dice.map((d) => d.id).toList(),
        shouldRoll: false,
      );
    }

    final diceValues = dice.map((d) => d.value).toList();
    final strategies = _generateKeepStrategies(diceValues);

    var bestStrategy = <int>[];
    var bestEV = 0.0;

    final startTime = DateTime.now();

    for (final strategy in strategies) {
      // Time budget check
      final elapsed = DateTime.now().difference(startTime).inMilliseconds;
      if (elapsed > timeBudgetMs) break;

      final numKeep = strategy.length;
      final numReroll = 5 - numKeep;

      // Run simulations
      var totalScore = 0.0;
      final simsPerStrategy = (simulations / strategies.length).ceil();

      for (var i = 0; i < simsPerStrategy; i++) {
        // Simulate reroll
        final simDice = List<int>.from(strategy);
        for (var j = 0; j < numReroll; j++) {
          simDice.add(rng.rollDie());
        }

        // Find best score from this roll
        final potentials = scoringEngine.calculatePotentialScores(
          simDice,
          scoreCard,
        );
        if (potentials.isNotEmpty) {
          final bestScore = potentials.values.reduce(math.max);
          totalScore += bestScore;
        }
      }

      final ev = totalScore / simsPerStrategy;
      if (ev > bestEV) {
        bestEV = ev;
        bestStrategy = strategy;
      }
    }

    // Convert values back to die IDs
    final diceToKeep = <int>[];
    final strategySet = <int>[];
    strategySet.addAll(bestStrategy);

    for (final die in dice) {
      if (strategySet.isNotEmpty && strategySet.first == die.value) {
        diceToKeep.add(die.id);
        strategySet.removeAt(0);
      }
    }

    return AIKeepDecision(
      diceToKeep: diceToKeep,
      shouldRoll: rollCount < maxRolls,
    );
  }

  List<List<int>> _generateKeepStrategies(List<int> dice) {
    final strategies = <List<int>>[];

    strategies.add([]);

    // Keep each value
    for (var value = 1; value <= 6; value++) {
      final keep = dice.where((d) => d == value).toList();
      if (keep.isNotEmpty) {
        strategies.add(keep);
      }
    }

    // Keep pairs and better
    final counts = <int, int>{};
    for (final value in dice) {
      counts[value] = (counts[value] ?? 0) + 1;
    }

    for (final entry in counts.entries) {
      if (entry.value >= 2) {
        strategies.add(dice.where((d) => d == entry.key).toList());
      }
    }

    // Keep for straights
    final sorted = dice.toSet().toList()..sort();
    if (sorted.length >= 4) {
      strategies.add(sorted.take(4).toList());
    }

    return strategies;
  }

  @override
  AICategoryDecision decideCategory({
    required List<Die> dice,
    required ScoreCard scoreCard,
  }) {
    final diceValues = dice.map((d) => d.value).toList();
    final potentials = scoringEngine.calculatePotentialScores(
      diceValues,
      scoreCard,
    );

    if (potentials.isEmpty) {
      throw StateError('No available categories');
    }

    // Sophisticated category selection
    var bestCategory = potentials.keys.first;
    var bestValue = _sophisticatedCategoryValue(
      bestCategory,
      potentials[bestCategory]!,
      scoreCard,
    );

    for (final entry in potentials.entries) {
      final value = _sophisticatedCategoryValue(
        entry.key,
        entry.value,
        scoreCard,
      );
      if (value > bestValue) {
        bestCategory = entry.key;
        bestValue = value;
      }
    }

    return AICategoryDecision(category: bestCategory);
  }

  double _sophisticatedCategoryValue(
    ScoreCategory category,
    int actualScore,
    ScoreCard scoreCard,
  ) {
    final expectedValue = scoringEngine.expectedValueFor(category);
    var value = actualScore.toDouble();

    // Bonus considerations for upper section
    if (category.isUpper) {
      final currentUpperTotal = scoreCard.upperSubtotal;
      final potentialWithThis = currentUpperTotal + actualScore;
      if (potentialWithThis >= 63 && currentUpperTotal < 63) {
        value += 10; // Bonus incentive
      }
    }

    // Opportunity cost
    final opportunityCost = expectedValue * 0.5;
    value -= opportunityCost;

    // Prefer not to scratch high-value categories
    if (actualScore == 0 && expectedValue > 10) {
      value -= 20;
    }

    return value;
  }
}

/// Factory for creating AI policies
class AIFactory {
  const AIFactory({
    required this.scoringEngine,
    required this.rng,
  });

  final ScoringEngine scoringEngine;
  final RNG rng;

  AIPolicy createPolicy(AIDifficulty difficulty) {
    switch (difficulty) {
      case AIDifficulty.easy:
        return EasyAI(scoringEngine: scoringEngine, rng: rng);
      case AIDifficulty.normal:
        return NormalAI(scoringEngine: scoringEngine, rng: rng);
      case AIDifficulty.hard:
        return HardAI(scoringEngine: scoringEngine, rng: rng);
    }
  }
}
