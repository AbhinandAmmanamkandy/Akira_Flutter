import 'package:flutter/material.dart';
import '../../../../theme/akira_colors.dart';

class EpisodeControlsHeader extends StatelessWidget {
  final String? totalEpisodes;
  final bool isReversed;
  final VoidCallback onToggleSort;
  final VoidCallback onJumpToEpisode;

  const EpisodeControlsHeader({
    super.key,
    this.totalEpisodes,
    required this.isReversed,
    required this.onToggleSort,
    required this.onJumpToEpisode,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Text(
            'Episodes',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          if (totalEpisodes != null) ...[
            const SizedBox(width: 8),
            Text(
              '($totalEpisodes)',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const Spacer(),
          _HeaderButton(
            icon: isReversed ? Icons.sort_rounded : Icons.sort_rounded,
            onTap: onToggleSort,
            isSelected: isReversed,
          ),
          const SizedBox(width: 8),
          _HeaderButton(
            icon: Icons.bolt_rounded,
            onTap: onJumpToEpisode,
            isAccent: true,
          ),
        ],
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isSelected;
  final bool isAccent;

  const _HeaderButton({
    required this.icon,
    required this.onTap,
    this.isSelected = false,
    this.isAccent = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;

    Color bgColor = AkiraColors.getComponentColor(colorScheme, isLight);
    Color iconColor = colorScheme.onSurface;

    if (isSelected) {
      bgColor = colorScheme.primary;
      iconColor = colorScheme.onPrimary;
    } else if (isAccent) {
      bgColor = colorScheme.primary.withValues(alpha: 0.1);
      iconColor = colorScheme.primary;
    }

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: isAccent ? BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
          ) : null,
          child: Icon(
            icon,
            size: 20,
            color: iconColor,
          ),
        ),
      ),
    );
  }
}
