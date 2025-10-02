import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// A banner widget that displays the current turn information
class TurnBanner extends StatelessWidget {
  const TurnBanner({
    required this.playerName,
    required this.rollsLeft,
    required this.currentRound,
    required this.totalRounds,
    super.key,
  });

  final String playerName;
  final int rollsLeft;
  final int currentRound;
  final int totalRounds;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer,
            colorScheme.primaryContainer.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Round indicator
          Text(
            l10n.gameRound(currentRound, totalRounds),
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onPrimaryContainer.withOpacity(0.8),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),

          // Current player
          Text(
            l10n.gameTurn(playerName),
            style: theme.textTheme.headlineSmall?.copyWith(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Rolls left indicator
          _RollsLeftIndicator(
            rollsLeft: rollsLeft,
            maxRolls: 3,
            color: colorScheme.onPrimaryContainer,
          ),
        ],
      ),
    );
  }
}

/// Visual indicator for remaining rolls
class _RollsLeftIndicator extends StatelessWidget {
  const _RollsLeftIndicator({
    required this.rollsLeft,
    required this.maxRolls,
    required this.color,
  });

  final int rollsLeft;
  final int maxRolls;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l10n.gameRollsLeft(rollsLeft),
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: color.withOpacity(0.9),
              ),
        ),
        const SizedBox(width: 8),
        ...List.generate(
          maxRolls,
          (index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Icon(
              index < rollsLeft ? Icons.circle : Icons.circle_outlined,
              size: 12,
              color: color.withOpacity(index < rollsLeft ? 0.9 : 0.4),
            ),
          ),
        ),
      ],
    );
  }
}

/// Compact version of turn banner for tight spaces
class CompactTurnBanner extends StatelessWidget {
  const CompactTurnBanner({
    required this.playerName,
    required this.rollsLeft,
    super.key,
  });

  final String playerName;
  final int rollsLeft;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.person,
            size: 16,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Text(
            playerName,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 16),
          Icon(
            Icons.casino,
            size: 16,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            l10n.gameRollsLeft(rollsLeft),
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
