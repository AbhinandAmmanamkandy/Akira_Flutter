import 'package:flutter/material.dart';
import '../../../widgets/glass_container.dart';
import '../../../../services/theme_service.dart';

class DetailActionRow extends StatelessWidget {
  final VoidCallback onPlayTap;
  final VoidCallback? onClearProgress;
  final String watchLabel;
  final int? continueEpisode;
  final bool isManga;

  const DetailActionRow({
    super.key,
    required this.onPlayTap,
    this.onClearProgress,
    this.watchLabel = 'Watch Now',
    this.continueEpisode,
    this.isManga = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final useGlass = ThemeService().useGlassTheme;

    final defaultLabel = isManga ? 'Read Now' : watchLabel;
    final unitLabel = isManga ? 'Chapter' : 'Episode';

    final label = continueEpisode != null 
        ? 'Continue $unitLabel $continueEpisode' 
        : defaultLabel;

    return Row(
      children: [
        Expanded(
          child: _buildMainButton(context, label, isLight, colorScheme, useGlass),
        ),
        if (continueEpisode != null && onClearProgress != null) ...[
          const SizedBox(width: 12),
          _buildClearButton(context, isLight, colorScheme, useGlass),
        ],
      ],
    );
  }

  Widget _buildMainButton(BuildContext context, String label, bool isLight, ColorScheme colorScheme, bool useGlass) {
    if (isLight) {
      return Container(
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
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
            label: label,
            textColor: colorScheme.onPrimary,
          ),
        ),
      );
    } else {
      return Container(
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
        ),
        child: GlassContainer(
          borderRadius: 16,
          opacity: 0.1,
          blur: 10,
          withBlur: useGlass,
          border: Border.all(
            color: colorScheme.primary.withValues(alpha: 0.2),
            width: 1.5,
          ),
          child: InkWell(
            onTap: onPlayTap,
            borderRadius: BorderRadius.circular(16),
            child: _ButtonContent(
              label: label,
              textColor: colorScheme.primary,
            ),
          ),
        ),
      );
    }
  }

  Widget _buildClearButton(BuildContext context, bool isLight, ColorScheme colorScheme, bool useGlass) {
    if (isLight) {
      return Container(
        height: 56,
        width: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: colorScheme.errorContainer,
        ),
        child: IconButton(
          onPressed: onClearProgress,
          icon: Icon(Icons.history_rounded, color: colorScheme.onErrorContainer),
          tooltip: 'Clear Progress',
        ),
      );
    } else {
      return Container(
        height: 56,
        width: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
        ),
        child: GlassContainer(
          borderRadius: 16,
          opacity: 0.1,
          blur: 10,
          withBlur: useGlass,
          border: Border.all(
            color: colorScheme.error.withValues(alpha: 0.2),
            width: 1.5,
          ),
          child: IconButton(
            onPressed: onClearProgress,
            icon: Icon(Icons.history_rounded, color: colorScheme.error),
            tooltip: 'Clear Progress',
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
