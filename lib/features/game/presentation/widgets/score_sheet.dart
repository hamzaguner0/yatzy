import 'package:flutter/material.dart';
import 'package:yatzy_tr/features/game/domain/entities.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Score sheet widget displaying all categories and scores
class ScoreSheet extends StatelessWidget {
  const ScoreSheet({
    required this.scoreCard,
    required this.potentialScores,
    required this.onCategoryTap,
    this.interactive = true,
    super.key,
  });

  final ScoreCard scoreCard;
  final Map<ScoreCategory, int> potentialScores;
  final void Function(ScoreCategory) onCategoryTap;
  final bool interactive;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Upper section
          _buildSectionHeader(context, l10n.scoreUpperSection),
          ...ScoreCategory.values.where((c) => c.isUpper).map(
                (category) => _buildCategoryRow(
                  context,
                  category,
                ),
              ),
          _buildSubtotalRow(
            context,
            l10n.scoreSubtotal,
            scoreCard.upperSubtotal,
          ),
          _buildSubtotalRow(
            context,
            l10n.scoreBonus,
            scoreCard.upperBonus,
          ),
          _buildTotalRow(
            context,
            l10n.scoreUpperTotal,
            scoreCard.upperTotal,
          ),

          const Divider(height: 1, thickness: 2),

          // Lower section
          _buildSectionHeader(context, l10n.scoreLowerSection),
          ...ScoreCategory.values.where((c) => c.isLower).map(
                (category) => _buildCategoryRow(
                  context,
                  category,
                ),
              ),
          _buildTotalRow(
            context,
            l10n.scoreLowerTotal,
            scoreCard.lowerSubtotal,
          ),

          const Divider(height: 1, thickness: 2),

          // Grand total
          _buildGrandTotalRow(context),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      color: theme.colorScheme.primaryContainer.withOpacity(0.5),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }

  Widget _buildCategoryRow(BuildContext context, ScoreCategory category) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final entry = scoreCard.getEntry(category);
    final potential = potentialScores[category];

    final isFilled = entry?.isFilled ?? false;
    final canSelect = !isFilled && potential != null && interactive;

    Widget row = InkWell(
      onTap: canSelect ? () => onCategoryTap(category) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                _getCategoryDisplayName(l10n, category),
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: canSelect
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                  fontWeight: canSelect ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ),
            SizedBox(
              width: 60,
              child: Text(
                _getScoreDisplay(entry, potential),
                textAlign: TextAlign.right,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: canSelect
                      ? theme.colorScheme.primary
                      : entry?.isScratched == true
                          ? theme.colorScheme.error
                          : theme.colorScheme.onSurface,
                  fontWeight: canSelect || isFilled
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (canSelect) {
      row = Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withOpacity(0.3),
          border: Border(
            left: BorderSide(
              color: theme.colorScheme.primary,
              width: 4,
            ),
          ),
        ),
        child: row,
      );
    }

    return Semantics(
      label:
          '${_getCategoryDisplayName(l10n, category)}, ${_getScoreDisplay(entry, potential)}',
      button: canSelect,
      child: row,
    );
  }

  String _getCategoryDisplayName(
    AppLocalizations l10n,
    ScoreCategory category,
  ) {
    switch (category) {
      case ScoreCategory.ones:
        return l10n.category_ones;
      case ScoreCategory.twos:
        return l10n.category_twos;
      case ScoreCategory.threes:
        return l10n.category_threes;
      case ScoreCategory.fours:
        return l10n.category_fours;
      case ScoreCategory.fives:
        return l10n.category_fives;
      case ScoreCategory.sixes:
        return l10n.category_sixes;
      case ScoreCategory.threeOfAKind:
        return l10n.category_three_of_a_kind;
      case ScoreCategory.fourOfAKind:
        return l10n.category_four_of_a_kind;
      case ScoreCategory.fullHouse:
        return l10n.category_full_house;
      case ScoreCategory.smallStraight:
        return l10n.category_small_straight;
      case ScoreCategory.largeStraight:
        return l10n.category_large_straight;
      case ScoreCategory.chance:
        return l10n.category_chance;
      case ScoreCategory.yahtzee:
        return l10n.category_yahtzee;
    }
  }

  String _getScoreDisplay(ScoreEntry? entry, int? potential) {
    if (entry != null && entry.isFilled) {
      if (entry.isScratched) {
        return '—';
      }
      return entry.score.toString();
    } else if (potential != null) {
      return '($potential)';
    }
    return '';
  }

  Widget _buildSubtotalRow(BuildContext context, String label, int value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontStyle: FontStyle.italic,
            ),
          ),
          SizedBox(
            width: 60,
            child: Text(
              value.toString(),
              textAlign: TextAlign.right,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(BuildContext context, String label, int value) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            width: 60,
            child: Text(
              value.toString(),
              textAlign: TextAlign.right,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrandTotalRow(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.primaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            l10n.scoreGrandTotal,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          Text(
            scoreCard.grandTotal.toString(),
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
