import 'package:flutter/material.dart';
import '../../../models/anime_details.dart';
import 'detail_info_badge.dart';
import 'detail_genre_tag.dart';

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
          DetailInfoBadge(
            text: details.status!.toUpperCase(),
            bgColor: colorScheme.tertiaryContainer,
            textColor: colorScheme.onTertiaryContainer,
          ),
        if (details.rating != null)
          DetailInfoBadge(
            text: details.rating!,
            bgColor: colorScheme.secondaryContainer,
            textColor: colorScheme.onSecondaryContainer,
          ),
        ...details.genres.map((g) => DetailGenreTag(label: g)),
      ],
    );
  }
}
