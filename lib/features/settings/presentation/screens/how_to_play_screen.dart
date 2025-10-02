import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// How to play screen explaining game rules
class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.rulesTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            context: context,
            icon: Icons.flag,
            title: l10n.rulesObjective,
            content: l10n.rulesObjectiveText,
          ),
          const SizedBox(height: 24),
          _buildSection(
            context: context,
            icon: Icons.gamepad,
            title: l10n.rulesGameplay,
            content: l10n.rulesGameplayText,
          ),
          const SizedBox(height: 24),
          _buildSection(
            context: context,
            icon: Icons.grid_view,
            title: l10n.rulesCategories,
            content: l10n.rulesCategoriesText,
          ),
          const SizedBox(height: 24),
          _buildSection(
            context: context,
            icon: Icons.score,
            title: l10n.rulesScoring,
            content: l10n.rulesScoringText,
          ),
          const SizedBox(height: 24),

          // Quick reference card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Reference',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildScoreRow('Full House', '25'),
                  _buildScoreRow('Small Straight', '30'),
                  _buildScoreRow('Large Straight', '40'),
                  _buildScoreRow('Yahtzee', '50'),
                  _buildScoreRow('Upper Bonus (63+)', '+35'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String content,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: theme.textTheme.bodyLarge,
        ),
      ],
    );
  }

  Widget _buildScoreRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
