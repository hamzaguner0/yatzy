import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:yatzy_tr/features/game/domain/entities.dart';

/// Animated die widget with hold functionality
class AnimatedDice extends StatelessWidget {
  const AnimatedDice({
    required this.die,
    required this.onTap,
    this.canHold = true,
    this.animate = false,
    super.key,
  });

  final Die die;
  final VoidCallback onTap;
  final bool canHold;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = 56.0;

    Widget dieWidget = GestureDetector(
      onTap: canHold ? onTap : null,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: die.held
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: die.held
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
            width: die.held ? 3 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: _buildDiePips(die.value, theme),
        ),
      ),
    );

    if (animate) {
      dieWidget = dieWidget
          .animate()
          .rotate(duration: 300.ms, curve: Curves.easeOut)
          .scale(
            begin: const Offset(0.8, 0.8),
            end: const Offset(1.0, 1.0),
            duration: 300.ms,
            curve: Curves.elasticOut,
          );
    }

    return Semantics(
      label: 'Die showing ${die.value}${die.held ? ", held" : ""}',
      button: canHold,
      child: dieWidget,
    );
  }

  Widget _buildDiePips(int value, ThemeData theme) {
    final pipColor = theme.colorScheme.onSurface;
    const pipSize = 8.0;

    Widget pip() => Container(
          width: pipSize,
          height: pipSize,
          decoration: BoxDecoration(
            color: pipColor,
            shape: BoxShape.circle,
          ),
        );

    switch (value) {
      case 1:
        return pip();

      case 2:
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [pip(), const SizedBox(width: 8)],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [const SizedBox(width: 8), pip()],
            ),
          ],
        );

      case 3:
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [pip(), const SizedBox(width: 8)],
            ),
            pip(),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [const SizedBox(width: 8), pip()],
            ),
          ],
        );

      case 4:
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [pip(), pip()],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [pip(), pip()],
            ),
          ],
        );

      case 5:
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [pip(), pip()],
            ),
            pip(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [pip(), pip()],
            ),
          ],
        );

      case 6:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [pip(), pip(), pip()],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [pip(), pip(), pip()],
            ),
          ],
        );

      default:
        return const SizedBox();
    }
  }
}

/// Row of animated dice
class DiceRow extends StatelessWidget {
  const DiceRow({
    required this.dice,
    required this.onDieTap,
    this.canHold = true,
    this.animate = false,
    super.key,
  });

  final List<Die> dice;
  final void Function(int dieId) onDieTap;
  final bool canHold;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: dice.map((die) {
        return AnimatedDice(
          die: die,
          onTap: () => onDieTap(die.id),
          canHold: canHold,
          animate: animate,
        );
      }).toList(),
    );
  }
}
