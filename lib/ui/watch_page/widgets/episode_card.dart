import 'package:flutter/material.dart';
import '../../widgets/glass_container.dart';
import '../../../services/theme_service.dart';

class EpisodeCard extends StatelessWidget {
  final int episodeNum;
  final bool isSelected;
  final VoidCallback onTap;

  const EpisodeCard({
    super.key,
    required this.episodeNum,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final useGlass = ThemeService().useGlassTheme;

    if (useGlass) {
      return GlassContainer(
        borderRadius: 16,
        opacity: isSelected ? 0.2 : 0.05,
        border: Border.all(
          color: isSelected 
              ? colorScheme.primary 
              : colorScheme.onSurface.withValues(alpha: 0.1),
          width: 1.5,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Text(
              '$episodeNum',
              style: TextStyle(
                color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isSelected 
            ? colorScheme.primary 
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected 
              ? colorScheme.primary 
              : colorScheme.outlineVariant.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Center(
          child: Text(
            '$episodeNum',
            style: TextStyle(
              color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}
