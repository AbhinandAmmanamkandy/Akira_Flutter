import 'package:akira/services/theme_service.dart';
import 'package:akira/ui/widgets/custom_status_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../models/anime_details.dart';
import '../../../widgets/common_chip.dart';

class DetailTagsRow extends StatelessWidget {
  final AnimeDetails details;
  final Function(String)? onTagTap;

  const DetailTagsRow({super.key, required this.details, this.onTagTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Primary Metadata Row
        Wrap(
          spacing: 12,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (details.averageScore != null)
              _buildMetaBadge(
                Icons.star_rounded,
                (details.averageScore! / 10).toStringAsFixed(1),
                const Color(0xFFFFA000), // Deeper, more "premium" gold
                textTheme,
              ),
            if (details.status != null)
              _buildMetaBadge(
                Icons.info_outline_rounded,
                details.status!.toUpperCase(),
                colorScheme.tertiary,
                textTheme,
              ),
            if (details.rating != null)
              _buildMetaBadge(
                Icons.explicit_outlined,
                details.rating!,
                colorScheme.secondary,
                textTheme,
              ),
          ],
        ),
        const SizedBox(height: 16),
        // Genre Tags
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: details.genres.map((g) => CommonChip(
            label: g,
            onTap: () => onTagTap?.call(g),
            onLongPress: () {
              ThemeService().addPinnedChip(g);
              HapticFeedback.mediumImpact();
              CustomStatusIndicator.show(
                context,
                'Pinned $g',
                Icons.add_circle_outline_rounded,
              );
            },
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildMetaBadge(IconData icon, String label, Color color, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
