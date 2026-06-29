import 'dart:io';
import 'package:flutter/material.dart';
import '../../../services/download_service.dart';
import '../../../services/theme_service.dart';
import '../../../theme/akira_colors.dart';
import '../../widgets/glass_container.dart';
import '../../../gestures/overscroll_dismiss_gesture.dart';
import '../../../models/anime.dart';
import '../watch_page/watch_page.dart';
import '../../../services/anime_service.dart';
import '../anime_list_page/widgets/list_card_thumbnail.dart';

class DownloadsPage extends StatefulWidget {
  const DownloadsPage({super.key});

  @override
  State<DownloadsPage> createState() => _DownloadsPageState();
}

class _DownloadsPageState extends State<DownloadsPage> {
  final Map<String, bool> _expandedState = {};

  @override
  Widget build(BuildContext context) {
    final downloadService = DownloadService();
    final colorScheme = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final useGlass = ThemeService().useGlassTheme;
    final bgColor = AkiraColors.getBackground(colorScheme, isLight);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Downloads'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: OverscrollDismissGesture(
        child: ListenableBuilder(
          listenable: downloadService,
          builder: (context, _) {
            final downloads = downloadService.getAllDownloads();
            final activeDownloads = downloadService.currentDownloads;

            if (downloads.isEmpty && activeDownloads.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.download_for_offline_outlined,
                      size: 64,
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No downloads yet',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            }

            // Group downloads by animeId
            final Map<String, List<DownloadItem>> groupedDownloads = {};
            for (var download in downloads) {
              if (!groupedDownloads.containsKey(download.animeId)) {
                groupedDownloads[download.animeId] = [];
              }
              groupedDownloads[download.animeId]!.add(download);
            }

            final animeIds = groupedDownloads.keys.toList();

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                if (activeDownloads.isNotEmpty) ...[
                  const _SectionHeader(title: 'DOWNLOADING'),
                  const SizedBox(height: 8),
                  ...activeDownloads.map((progress) => _ActiveDownloadTile(progress: progress)),
                  const SizedBox(height: 24),
                ],
                if (downloads.isNotEmpty) ...[
                  if (activeDownloads.isNotEmpty)
                    const _SectionHeader(title: 'COMPLETED'),
                  const SizedBox(height: 8),
                  ...animeIds.map((animeId) {
                    final animeDownloads = groupedDownloads[animeId]!;
                    animeDownloads.sort((a, b) => a.episode.compareTo(b.episode));
                    return _AnimeDownloadGroup(
                      animeId: animeId,
                      downloads: animeDownloads,
                      isExpanded: _expandedState[animeId] ?? false,
                      onToggle: () {
                        setState(() {
                          _expandedState[animeId] = !(_expandedState[animeId] ?? false);
                        });
                      },
                    );
                  }),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ActiveDownloadTile extends StatelessWidget {
  final DownloadProgress progress;

  const _ActiveDownloadTile({required this.progress});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final useGlass = ThemeService().useGlassTheme;

    Widget buildContent() {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        progress.animeName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Episode ${progress.episode}${progress.isPaused ? ' • Paused' : ''}',
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${(progress.progress * 100).toInt()}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    if (progress.isPaused) {
                      DownloadService().resumeDownload(progress.animeId, progress.episode);
                    } else {
                      DownloadService().pauseDownload(progress.animeId, progress.episode);
                    }
                  },
                  icon: Icon(
                    progress.isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                    color: colorScheme.primary,
                  ),
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    DownloadService().deleteDownload(progress.animeId, progress.episode);
                  },
                  icon: const Icon(Icons.close_rounded, size: 20),
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.progress,
                backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                minHeight: 8,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: useGlass
          ? GlassContainer(
              borderRadius: 20,
              child: buildContent(),
            )
          : Container(
              decoration: BoxDecoration(
                color: AkiraColors.getComponentColor(colorScheme, isLight),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AkiraColors.getShadowColor(colorScheme),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: buildContent(),
            ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: colorScheme.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _AnimeDownloadGroup extends StatelessWidget {
  final String animeId;
  final List<DownloadItem> downloads;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _AnimeDownloadGroup({
    required this.animeId,
    required this.downloads,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final firstItem = downloads.first;
    final colorScheme = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final useGlass = ThemeService().useGlassTheme;
    final themeService = ThemeService();

    final animeTitle = firstItem.englishName ?? firstItem.animeName;

    Widget buildHeader() {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AkiraColors.getShadowColor(colorScheme),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Material(
            color: AkiraColors.getComponentColor(colorScheme, isLight),
            child: InkWell(
              onTap: onToggle,
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      width: 100,
                      child: AspectRatio(
                        aspectRatio: 0.7,
                        child: ListCardThumbnail(
                          imageUrl: firstItem.thumbnail,
                          heroTag: 'download_anime_$animeId',
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              animeTitle,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                letterSpacing: -0.5,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${downloads.length} ${downloads.length == 1 ? 'EPISODE' : 'EPISODES'}',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: colorScheme.primary,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Icon(
                        isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        if (useGlass)
          GlassContainer(
            borderRadius: 20,
            child: buildHeader(),
          )
        else
          buildHeader(),
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            child: Column(
              children: downloads.map((item) => _EpisodeDownloadTile(item: item)).toList(),
            ),
          ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _EpisodeDownloadTile extends StatelessWidget {
  final DownloadItem item;

  const _EpisodeDownloadTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final useGlass = ThemeService().useGlassTheme;

    Widget buildTileContent() {
      return InkWell(
        onTap: () async {
          final anime = Anime(
            id: item.animeId,
            name: item.animeName,
            englishName: item.englishName,
            thumbnail: item.thumbnail,
          );
          
          try {
             final details = await AnimeService().fetchAnimeDetails(item.animeId);
             if (context.mounted && details != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WatchPage(anime: anime, details: details),
                  ),
                );
             } else if (context.mounted) {
               ScaffoldMessenger.of(context).showSnackBar(
                 const SnackBar(content: Text('Could not load anime details')),
               );
             }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Connect to internet to load details')),
              );
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${item.episode}',
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Episode ${item.episode}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      _getFileSize(item.localPath),
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 20),
                onPressed: () {
                  DownloadService().deleteDownload(item.animeId, item.episode);
                },
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 6),
      child: useGlass
          ? GlassContainer(
              borderRadius: 16,
              opacity: 0.05,
              child: buildTileContent(),
            )
          : Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.onSurface.withValues(alpha: 0.05),
                ),
              ),
              child: buildTileContent(),
            ),
    );
  }

  String _getFileSize(String path) {
    try {
      final file = File(path);
      if (file.existsSync()) {
        final bytes = file.lengthSync();
        if (bytes < 1024) return '$bytes B';
        if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
        return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
      }
    } catch (e) {}
    return 'Unknown size';
  }
}
