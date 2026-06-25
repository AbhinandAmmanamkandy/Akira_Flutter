import 'package:flutter/material.dart';
import '../../../../models/anime.dart';
import '../../../../services/favorite_service.dart';
import '../../../../services/download_service.dart';
import '../../../../services/anime_stream_service.dart';
import '../../../widgets/custom_status_indicator.dart';

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
    final downloadService = DownloadService();
    final api = AllAnimeApi();

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
                listenable: downloadService,
                builder: (context, _) {
                  final downloaded = downloadService.getDownload(anime.id, currentEpisode);
                  final isDownloading = downloadService.isDownloading(anime.id, currentEpisode);
                  final progress = downloadService.getProgress(anime.id, currentEpisode);

                  if (isDownloading) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            value: progress > 0 ? progress : null,
                            strokeWidth: 2,
                            color: colorScheme.primary,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            // Cancel not implemented in simple service, but we can show it's working
                          },
                          icon: Icon(Icons.close_rounded, size: 16, color: colorScheme.primary),
                        ),
                      ],
                    );
                  }

                  return IconButton(
                    onPressed: () async {
                      if (downloaded != null) {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Download?'),
                            content: const Text('Do you want to delete this episode from your downloads?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await downloadService.deleteDownload(anime.id, currentEpisode);
                        }
                      } else {
                        try {
                          CustomStatusIndicator.show(context, 'Starting download...', Icons.downloading_rounded);
                          final url = await api.getEpisodeVideoUrl(anime.id, currentEpisode.toString());
                          if (url != null) {
                            await downloadService.startDownload(anime, currentEpisode, url);
                            if (context.mounted) {
                              CustomStatusIndicator.show(context, 'Download complete!', Icons.download_done_rounded);
                            }
                          } else {
                            if (context.mounted) {
                              CustomStatusIndicator.show(context, 'Could not find stream URL', Icons.error_outline_rounded);
                            }
                          }
                        } catch (e) {
                          if (context.mounted) {
                            CustomStatusIndicator.show(context, 'Download failed: $e', Icons.error_outline_rounded);
                          }
                        }
                      }
                    },
                    icon: Icon(
                      downloaded != null ? Icons.download_done_rounded : Icons.download_for_offline_outlined,
                      color: downloaded != null ? colorScheme.primary : colorScheme.onSurfaceVariant,
                    ),
                  );
                },
              ),
              ListenableBuilder(
                listenable: favoriteService,
                builder: (context, _) {
                  final isFavorite = favoriteService.isFavorite(anime.id);
                  return IconButton(
                    onPressed: () {
                      favoriteService.toggleFavorite(anime);
                      CustomStatusIndicator.show(
                        context,
                        isFavorite ? 'Removed from favorites' : 'Added to favorites',
                        isFavorite ? Icons.favorite_border_rounded : Icons.favorite_rounded,
                      );
                    },
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
            anime.englishName ?? anime.name,
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
