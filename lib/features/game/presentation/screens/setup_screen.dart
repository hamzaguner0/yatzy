import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:yatzy_tr/app/router.dart';
import 'package:yatzy_tr/features/game/application/game_controller.dart';
import 'package:yatzy_tr/features/game/domain/entities.dart';
import 'package:yatzy_tr/features/settings/settings_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Setup screen for configuring a new game
class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({
    required this.isSolo,
    super.key,
  });

  final bool isSolo;

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  int _numPlayers = 2;
  final List<TextEditingController> _nameControllers = [];
  AIDifficulty _aiDifficulty = AIDifficulty.normal;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    final maxPlayers = widget.isSolo ? 1 : 6;
    for (var i = 0; i < maxPlayers; i++) {
      _nameControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    for (final controller in _nameControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.setupTitle),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Number of players (only for pass-and-play)
            if (!widget.isSolo) ...[
              Text(
                l10n.setupNumPlayers,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Slider(
                value: _numPlayers.toDouble(),
                min: 2,
                max: 6,
                divisions: 4,
                label: _numPlayers.toString(),
                onChanged: (value) {
                  setState(() {
                    _numPlayers = value.toInt();
                  });
                },
              ),
              const SizedBox(height: 24),
            ],

            // Player name inputs
            ...List.generate(
              widget.isSolo ? 1 : _numPlayers,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextField(
                  controller: _nameControllers[index],
                  decoration: InputDecoration(
                    labelText: l10n.setupPlayerName(index + 1),
                    hintText: 'Player ${index + 1}',
                    prefixIcon: const Icon(Icons.person),
                  ),
                ),
              ),
            ),

            // AI opponent (only for solo mode)
            if (widget.isSolo) ...[
              const SizedBox(height: 24),
              Text(
                l10n.setupAIOpponent,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.setupDifficulty,
                        style: theme.textTheme.labelLarge,
                      ),
                      const SizedBox(height: 12),
                      SegmentedButton<AIDifficulty>(
                        segments: [
                          ButtonSegment(
                            value: AIDifficulty.easy,
                            label: Text(l10n.difficultyEasy),
                            icon: const Icon(Icons.sentiment_satisfied),
                          ),
                          ButtonSegment(
                            value: AIDifficulty.normal,
                            label: Text(l10n.difficultyNormal),
                            icon: const Icon(Icons.sentiment_neutral),
                          ),
                          ButtonSegment(
                            value: AIDifficulty.hard,
                            label: Text(l10n.difficultyHard),
                            icon: const Icon(Icons.sentiment_very_dissatisfied),
                          ),
                        ],
                        selected: {_aiDifficulty},
                        onSelectionChanged: (Set<AIDifficulty> newSelection) {
                          setState(() {
                            _aiDifficulty = newSelection.first;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Start game button
            FilledButton.icon(
              onPressed: _startGame,
              icon: const Icon(Icons.play_arrow),
              label: Text(l10n.setupStartGame),
            ),
          ],
        ),
      ),
    );
  }

  void _startGame() {
    final settings = ref.read(settingsProvider);
    final gameSettings = GameSettings(
      allowJokerRules: settings.jokerRulesEnabled,
      multipleYahtzees: settings.multipleYahtzeesEnabled,
      seed: settings.rngSeed,
    );

    final players = <Player>[];

    if (widget.isSolo) {
      // Solo mode: human player + AI
      final playerName = _nameControllers[0].text.trim().isEmpty
          ? 'Player 1'
          : _nameControllers[0].text.trim();

      players.add(
        Player(
          id: '1',
          displayName: playerName,
          isAI: false,
        ),
      );

      players.add(
        Player(
          id: '2',
          displayName: 'AI',
          isAI: true,
          difficulty: _aiDifficulty,
        ),
      );
    } else {
      // Pass-and-play mode: multiple human players
      for (var i = 0; i < _numPlayers; i++) {
        final playerName = _nameControllers[i].text.trim().isEmpty
            ? 'Player ${i + 1}'
            : _nameControllers[i].text.trim();

        players.add(
          Player(
            id: '${i + 1}',
            displayName: playerName,
            isAI: false,
          ),
        );
      }
    }

    // Start the game
    ref.read(gameStateProvider.notifier).startGame(
          players: players,
          settings: gameSettings,
        );

    // Navigate to game screen
    context.go(Routes.game);
  }
}
