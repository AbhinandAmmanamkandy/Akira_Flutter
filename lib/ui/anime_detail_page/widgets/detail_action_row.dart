import 'package:flutter/material.dart';
import '../../widgets/glass_container.dart';
import '../../../services/theme_service.dart';

class DetailActionRow extends StatelessWidget {
  final VoidCallback onWatchNow;
  final VoidCallback onBookmark;
  final bool isBookmarked;
  final String watchLabel;

  const DetailActionRow({
    super.key,
    required this.onWatchNow,
    required this.onBookmark,
    this.isBookmarked = false,
    this.watchLabel = 'Watch Now',
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final useGlass = ThemeService().useGlassTheme;

    return Row(
      children: [
        Expanded(
          child: useGlass
              ? GlassContainer(
                  borderRadius: 16,
                  opacity: 0.2,
                  blur: 10,
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                  child: InkWell(
                    onTap: onWatchNow,
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.play_arrow_rounded, color: colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            watchLabel,
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : FilledButton.icon(
                  onPressed: onWatchNow,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text(watchLabel),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
        ),
        const SizedBox(width: 12),
        GlassContainer(
          borderRadius: 16,
          opacity: 0.1,
          child: IconButton(
            onPressed: onBookmark,
            icon: Icon(
                isBookmarked
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
                color: colorScheme.primary),
            padding: const EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }
}
