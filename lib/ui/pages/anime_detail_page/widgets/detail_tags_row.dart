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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            if (details.status != null)
              Expanded(
                child: CommonChip(
                  label: details.status!.toUpperCase(),
                  color: colorScheme.tertiary,
                  borderRadius: 8,
                ),
              ),
            if (details.status != null && details.rating != null)
              const SizedBox(width: 10),
            if (details.rating != null)
              Expanded(
                child: CommonChip(
                  label: details.rating!,
                  color: colorScheme.secondary,
                  borderRadius: 8,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (details.averageScore != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded, size: 14, color: Colors.black87),
                    const SizedBox(width: 4),
                    Text(
                      (details.averageScore! / 10).toStringAsFixed(1),
                      style: textTheme.labelSmall?.copyWith(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ...details.genres.map((g) => CommonChip(
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
            )),
          ],
        ),
      ],
    );
  }
}
