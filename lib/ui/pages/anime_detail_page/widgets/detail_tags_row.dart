import 'package:flutter/material.dart';
import '../../../../models/anime_details.dart';
import '../../../widgets/common_chip.dart';

class DetailTagsRow extends StatelessWidget {
  final AnimeDetails details;

  const DetailTagsRow({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Wrap(
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
        if (details.status != null)
          CommonChip(
            label: details.status!.toUpperCase(),
            color: colorScheme.tertiary,
            borderRadius: 8,
          ),
        if (details.rating != null)
          CommonChip(
            label: details.rating!,
            color: colorScheme.secondary,
            borderRadius: 8,
          ),
        ...details.genres.map((g) => CommonChip(label: g)),
      ],
    );
  }
}
