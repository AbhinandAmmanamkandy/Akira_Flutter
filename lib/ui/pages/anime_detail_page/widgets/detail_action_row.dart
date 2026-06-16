import 'package:flutter/material.dart';
import '../../../widgets/glass_container.dart';
import '../../../../services/theme_service.dart';

class DetailActionRow extends StatelessWidget {
  final VoidCallback onPlayTap;
  final String watchLabel;

  const DetailActionRow({
    super.key,
    required this.onPlayTap,
    this.watchLabel = 'Watch Now',
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final useGlass = ThemeService().useGlassTheme;

    // Redesign: Distinct styles for Light and Dark modes
    if (isLight) {
      // Light Mode: Solid, bold, and clean
      return Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FilledButton(
          onPressed: onPlayTap,
          style: FilledButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            padding: EdgeInsets.zero,
          ),
          child: _ButtonContent(
            label: watchLabel,
            textColor: colorScheme.onPrimary,
          ),
        ),
      );
    } else {
      // Dark Mode: Sleek, Glassy, and Glowing
      return Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: GlassContainer(
          borderRadius: 16,
          opacity: 0.1,
          blur: 10,
          withBlur: useGlass,
          border: Border.all(
            color: colorScheme.primary.withValues(alpha: 0.5),
            width: 2,
          ),
          child: InkWell(
            onTap: onPlayTap,
            borderRadius: BorderRadius.circular(16),
            child: _ButtonContent(
              label: watchLabel,
              textColor: colorScheme.primary,
            ),
          ),
        ),
      );
    }
  }
}

class _ButtonContent extends StatelessWidget {
  final String label;
  final Color textColor;

  const _ButtonContent({
    required this.label,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        label,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.8,
          color: textColor,
        ),
      ),
    );
  }
}
