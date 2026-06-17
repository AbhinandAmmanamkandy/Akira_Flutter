import 'package:flutter/material.dart';
import '../../../widgets/glass_container.dart';
import '../../../../services/theme_service.dart';
import '../../../../theme/akira_colors.dart';

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
    final isLight = Theme.of(context).brightness == Brightness.light;

    if (useGlass) {
      return GlassContainer(
        borderRadius: 16,
        opacity: isSelected ? 0.3 : (isLight ? 0.15 : 0.05),
        border: Border.all(
          color: isSelected 
              ? colorScheme.primary 
              : colorScheme.onSurface.withValues(alpha: isLight ? 0.3 : 0.1),
          width: isSelected ? 2.0 : 1.5,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Text(
              '$episodeNum',
              style: TextStyle(
                color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: isSelected 
            ? colorScheme.primary 
            : AkiraColors.getComponentColor(colorScheme, isLight).withValues(alpha: isLight ? 1.0 : 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected 
              ? colorScheme.primary 
              : colorScheme.onSurface.withValues(alpha: isLight ? 0.1 : 0.0),
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
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
