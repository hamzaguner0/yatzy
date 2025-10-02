import 'dart:math';

/// Random number generator wrapper for deterministic testing
class RNG {
  RNG({int? seed}) : _random = seed != null ? Random(seed) : Random();

  final Random _random;

  /// Roll a single die (1-6)
  int rollDie() => _random.nextInt(6) + 1;

  /// Roll multiple dice
  List<int> rollDice(int count) => List.generate(count, (_) => rollDie());

  /// Get a random int in range [0, max)
  int nextInt(int max) => _random.nextInt(max);

  /// Get a random double in range [0, 1)
  double nextDouble() => _random.nextDouble();
}
