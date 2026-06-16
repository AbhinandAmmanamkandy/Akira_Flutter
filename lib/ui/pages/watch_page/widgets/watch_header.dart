import 'package:flutter/material.dart';
import '../../../../models/anime.dart';
import '../../../../services/favorite_service.dart';

class WatchHeader extends StatelessWidget {
  final Anime anime;
  final int currentEpisode;

  const WatchHeader({
    super.key,
    required this.anime,
    required this.currentEpisode,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final favoriteService = FavoriteService();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.play_circle_filled_rounded, size: 12, color: colorScheme.primary),
                    const SizedBox(width: 4),
                    Text(
                      'NOW PLAYING • EPISODE $currentEpisode',
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              ListenableBuilder(
                listenable: favoriteService,
                builder: (context, _) {
                  final isFavorite = favoriteService.isFavorite(anime.id);
                  return IconButton(
                    onPressed: () => favoriteService.toggleFavorite(anime),
                    icon: Icon(
                      isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: isFavorite ? Colors.red : colorScheme.onSurfaceVariant,
                    ),
                  );
                },
              ),
              IconButton(
                onPressed: () {
                  // TODO: Implement share
                },
                icon: Icon(Icons.share_rounded, color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            anime.name,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
              color: colorScheme.onSurface,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
