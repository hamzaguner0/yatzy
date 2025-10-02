/// Domain entities for Yatzy game

/// Represents a single die
class Die {
  const Die({
    required this.id,
    required this.value,
    this.held = false,
  }) : assert(value >= 1 && value <= 6, 'Die value must be 1-6');

  final int id;
  final int value;
  final bool held;

  Die copyWith({int? value, bool? held}) => Die(
        id: id,
        value: value ?? this.value,
        held: held ?? this.held,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Die &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          value == other.value &&
          held == other.held;

  @override
  int get hashCode => Object.hash(id, value, held);

  @override
  String toString() => 'Die(id: $id, value: $value, held: $held)';
}

/// Difficulty levels for AI opponents
enum AIDifficulty {
  easy,
  normal,
  hard;

  String get displayName {
    switch (this) {
      case AIDifficulty.easy:
        return 'Easy';
      case AIDifficulty.normal:
        return 'Normal';
      case AIDifficulty.hard:
        return 'Hard';
    }
  }
}

/// Represents a player in the game
class Player {
  const Player({
    required this.id,
    required this.displayName,
    this.isAI = false,
    this.difficulty = AIDifficulty.normal,
  });

  final String id;
  final String displayName;
  final bool isAI;
  final AIDifficulty difficulty;

  Player copyWith({
    String? displayName,
    bool? isAI,
    AIDifficulty? difficulty,
  }) =>
      Player(
        id: id,
        displayName: displayName ?? this.displayName,
        isAI: isAI ?? this.isAI,
        difficulty: difficulty ?? this.difficulty,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Player &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          displayName == other.displayName &&
          isAI == other.isAI &&
          difficulty == other.difficulty;

  @override
  int get hashCode => Object.hash(id, displayName, isAI, difficulty);

  @override
  String toString() =>
      'Player(id: $id, name: $displayName, isAI: $isAI, difficulty: $difficulty)';

  Map<String, dynamic> toJson() => {
        'id': id,
        'displayName': displayName,
        'isAI': isAI,
        'difficulty': difficulty.name,
      };

  factory Player.fromJson(Map<String, dynamic> json) => Player(
        id: json['id'] as String,
        displayName: json['displayName'] as String,
        isAI: json['isAI'] as bool? ?? false,
        difficulty: AIDifficulty.values.firstWhere(
          (e) => e.name == json['difficulty'],
          orElse: () => AIDifficulty.normal,
        ),
      );
}

/// Score categories in Yatzy
enum ScoreCategory {
  // Upper section
  ones,
  twos,
  threes,
  fours,
  fives,
  sixes,

  // Lower section
  threeOfAKind,
  fourOfAKind,
  fullHouse,
  smallStraight,
  largeStraight,
  chance,
  yahtzee;

  bool get isUpper => index < 6;

  bool get isLower => !isUpper;

  String get displayKey {
    switch (this) {
      case ScoreCategory.ones:
        return 'category_ones';
      case ScoreCategory.twos:
        return 'category_twos';
      case ScoreCategory.threes:
        return 'category_threes';
      case ScoreCategory.fours:
        return 'category_fours';
      case ScoreCategory.fives:
        return 'category_fives';
      case ScoreCategory.sixes:
        return 'category_sixes';
      case ScoreCategory.threeOfAKind:
        return 'category_three_of_a_kind';
      case ScoreCategory.fourOfAKind:
        return 'category_four_of_a_kind';
      case ScoreCategory.fullHouse:
        return 'category_full_house';
      case ScoreCategory.smallStraight:
        return 'category_small_straight';
      case ScoreCategory.largeStraight:
        return 'category_large_straight';
      case ScoreCategory.chance:
        return 'category_chance';
      case ScoreCategory.yahtzee:
        return 'category_yahtzee';
    }
  }
}

/// Entry in a score card for a specific category
class ScoreEntry {
  const ScoreEntry({
    this.score,
    this.isScratched = false,
  }) : assert(
          score == null || !isScratched,
          'Cannot have score and be scratched',
        );

  final int? score;
  final bool isScratched;

  bool get isFilled => score != null || isScratched;

  ScoreEntry copyWith({int? score, bool? isScratched}) => ScoreEntry(
        score: score ?? this.score,
        isScratched: isScratched ?? this.isScratched,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScoreEntry &&
          runtimeType == other.runtimeType &&
          score == other.score &&
          isScratched == other.isScratched;

  @override
  int get hashCode => Object.hash(score, isScratched);

  Map<String, dynamic> toJson() => {
        'score': score,
        'isScratched': isScratched,
      };

  factory ScoreEntry.fromJson(Map<String, dynamic> json) => ScoreEntry(
        score: json['score'] as int?,
        isScratched: json['isScratched'] as bool? ?? false,
      );
}

/// Score card for a single player
class ScoreCard {
  const ScoreCard({
    this.entries = const {},
  });

  final Map<ScoreCategory, ScoreEntry> entries;

  ScoreEntry? getEntry(ScoreCategory category) => entries[category];

  bool isFilled(ScoreCategory category) =>
      entries[category]?.isFilled ?? false;

  bool get isComplete => ScoreCategory.values.every(isFilled);

  int get upperSubtotal {
    var sum = 0;
    for (final category in ScoreCategory.values.where((c) => c.isUpper)) {
      final entry = entries[category];
      if (entry != null && entry.score != null) {
        sum += entry.score!;
      }
    }
    return sum;
  }

  int get upperBonus => upperSubtotal >= 63 ? 35 : 0;

  int get upperTotal => upperSubtotal + upperBonus;

  int get lowerSubtotal {
    var sum = 0;
    for (final category in ScoreCategory.values.where((c) => c.isLower)) {
      final entry = entries[category];
      if (entry != null && entry.score != null) {
        sum += entry.score!;
      }
    }
    return sum;
  }

  int get grandTotal => upperTotal + lowerSubtotal;

  ScoreCard withEntry(ScoreCategory category, ScoreEntry entry) {
    final newEntries = Map<ScoreCategory, ScoreEntry>.from(entries);
    newEntries[category] = entry;
    return ScoreCard(entries: newEntries);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScoreCard &&
          runtimeType == other.runtimeType &&
          _mapEquals(entries, other.entries);

  bool _mapEquals(
    Map<ScoreCategory, ScoreEntry> a,
    Map<ScoreCategory, ScoreEntry> b,
  ) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (a[key] != b[key]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(entries.entries);

  Map<String, dynamic> toJson() => {
        'entries': entries.map(
          (key, value) => MapEntry(key.name, value.toJson()),
        ),
      };

  factory ScoreCard.fromJson(Map<String, dynamic> json) {
    final entriesJson = json['entries'] as Map<String, dynamic>? ?? {};
    final entries = <ScoreCategory, ScoreEntry>{};
    for (final entry in entriesJson.entries) {
      final category = ScoreCategory.values.firstWhere(
        (c) => c.name == entry.key,
      );
      entries[category] = ScoreEntry.fromJson(
        entry.value as Map<String, dynamic>,
      );
    }
    return ScoreCard(entries: entries);
  }
}

/// Game settings and variant rules
class GameSettings {
  const GameSettings({
    this.rollsPerTurn = 3,
    this.allowJokerRules = false,
    this.multipleYahtzees = false,
    this.seed,
  });

  final int rollsPerTurn;
  final bool allowJokerRules;
  final bool multipleYahtzees;
  final int? seed;

  GameSettings copyWith({
    int? rollsPerTurn,
    bool? allowJokerRules,
    bool? multipleYahtzees,
    int? seed,
  }) =>
      GameSettings(
        rollsPerTurn: rollsPerTurn ?? this.rollsPerTurn,
        allowJokerRules: allowJokerRules ?? this.allowJokerRules,
        multipleYahtzees: multipleYahtzees ?? this.multipleYahtzees,
        seed: seed ?? this.seed,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameSettings &&
          runtimeType == other.runtimeType &&
          rollsPerTurn == other.rollsPerTurn &&
          allowJokerRules == other.allowJokerRules &&
          multipleYahtzees == other.multipleYahtzees &&
          seed == other.seed;

  @override
  int get hashCode =>
      Object.hash(rollsPerTurn, allowJokerRules, multipleYahtzees, seed);

  Map<String, dynamic> toJson() => {
        'rollsPerTurn': rollsPerTurn,
        'allowJokerRules': allowJokerRules,
        'multipleYahtzees': multipleYahtzees,
        'seed': seed,
      };

  factory GameSettings.fromJson(Map<String, dynamic> json) => GameSettings(
        rollsPerTurn: json['rollsPerTurn'] as int? ?? 3,
        allowJokerRules: json['allowJokerRules'] as bool? ?? false,
        multipleYahtzees: json['multipleYahtzees'] as bool? ?? false,
        seed: json['seed'] as int?,
      );
}

/// Game phase enumeration
enum GamePhase {
  menu,
  playing,
  complete;

  bool get isPlaying => this == GamePhase.playing;
}

/// Complete game state
class GameState {
  const GameState({
    required this.phase,
    required this.players,
    required this.settings,
    this.activePlayerIndex = 0,
    this.currentRound = 1,
    this.rollCount = 0,
    this.dice = const [],
    this.scoreboards = const {},
  });

  final GamePhase phase;
  final List<Player> players;
  final GameSettings settings;
  final int activePlayerIndex;
  final int currentRound;
  final int rollCount;
  final List<Die> dice;
  final Map<String, ScoreCard> scoreboards;

  Player get activePlayer => players[activePlayerIndex];

  ScoreCard get activeScoreCard => scoreboards[activePlayer.id] ?? const ScoreCard();

  bool get canRoll => rollCount < settings.rollsPerTurn;

  bool get hasRolled => rollCount > 0;

  GameState copyWith({
    GamePhase? phase,
    List<Player>? players,
    GameSettings? settings,
    int? activePlayerIndex,
    int? currentRound,
    int? rollCount,
    List<Die>? dice,
    Map<String, ScoreCard>? scoreboards,
  }) =>
      GameState(
        phase: phase ?? this.phase,
        players: players ?? this.players,
        settings: settings ?? this.settings,
        activePlayerIndex: activePlayerIndex ?? this.activePlayerIndex,
        currentRound: currentRound ?? this.currentRound,
        rollCount: rollCount ?? this.rollCount,
        dice: dice ?? this.dice,
        scoreboards: scoreboards ?? this.scoreboards,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameState &&
          runtimeType == other.runtimeType &&
          phase == other.phase &&
          _listEquals(players, other.players) &&
          settings == other.settings &&
          activePlayerIndex == other.activePlayerIndex &&
          currentRound == other.currentRound &&
          rollCount == other.rollCount &&
          _listEquals(dice, other.dice) &&
          _mapEquals(scoreboards, other.scoreboards);

  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  bool _mapEquals(Map<String, ScoreCard> a, Map<String, ScoreCard> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (a[key] != b[key]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
        phase,
        Object.hashAll(players),
        settings,
        activePlayerIndex,
        currentRound,
        rollCount,
        Object.hashAll(dice),
        Object.hashAll(scoreboards.entries),
      );

  Map<String, dynamic> toJson() => {
        'phase': phase.name,
        'players': players.map((p) => p.toJson()).toList(),
        'settings': settings.toJson(),
        'activePlayerIndex': activePlayerIndex,
        'currentRound': currentRound,
        'rollCount': rollCount,
        'dice': dice.map((d) => {'id': d.id, 'value': d.value, 'held': d.held}).toList(),
        'scoreboards': scoreboards.map(
          (key, value) => MapEntry(key, value.toJson()),
        ),
      };

  factory GameState.fromJson(Map<String, dynamic> json) {
    final playersJson = json['players'] as List<dynamic>? ?? [];
    final players = playersJson
        .map((p) => Player.fromJson(p as Map<String, dynamic>))
        .toList();

    final diceJson = json['dice'] as List<dynamic>? ?? [];
    final dice = diceJson.map((d) {
      final diceMap = d as Map<String, dynamic>;
      return Die(
        id: diceMap['id'] as int,
        value: diceMap['value'] as int,
        held: diceMap['held'] as bool? ?? false,
      );
    }).toList();

    final scoreboardsJson = json['scoreboards'] as Map<String, dynamic>? ?? {};
    final scoreboards = <String, ScoreCard>{};
    for (final entry in scoreboardsJson.entries) {
      scoreboards[entry.key] = ScoreCard.fromJson(
        entry.value as Map<String, dynamic>,
      );
    }

    return GameState(
      phase: GamePhase.values.firstWhere(
        (p) => p.name == json['phase'],
        orElse: () => GamePhase.menu,
      ),
      players: players,
      settings: GameSettings.fromJson(
        json['settings'] as Map<String, dynamic>? ?? {},
      ),
      activePlayerIndex: json['activePlayerIndex'] as int? ?? 0,
      currentRound: json['currentRound'] as int? ?? 1,
      rollCount: json['rollCount'] as int? ?? 0,
      dice: dice,
      scoreboards: scoreboards,
    );
  }
}
