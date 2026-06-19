import 'package:flutter/material.dart';
import 'package:akira/services/history_service.dart';
import 'package:akira/services/theme_service.dart';
import 'package:akira/theme/akira_colors.dart';
import 'package:akira/ui/widgets/glass_container.dart';
import 'package:akira/gestures/overscroll_dismiss_gesture.dart';
import 'package:akira/models/anime.dart';
import 'package:akira/ui/pages/anime_detail_page/anime_detail_page.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([ThemeService(), HistoryService()]),
      builder: (context, _) {
        final allHistory = HistoryService().getAllHistory();
        final historyList = allHistory.entries.toList()
          ..sort((a, b) => b.value.timestamp.compareTo(a.value.timestamp));

        final useGlass = ThemeService().useGlassTheme;
        final colorScheme = Theme.of(context).colorScheme;

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              color: AkiraColors.getBackground(
                colorScheme,
                Theme.of(context).brightness == Brightness.light,
              ),
            ),
            child: OverscrollDismissGesture(
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  SliverAppBar(
                    floating: true,
                    pinned: true,
                    backgroundColor: useGlass
                        ? Colors.transparent
                        : colorScheme.surface.withValues(alpha: 0.8),
                    surfaceTintColor: Colors.transparent,
                    foregroundColor: colorScheme.onSurface,
                    elevation: 0,
                    iconTheme: IconThemeData(color: colorScheme.onSurface),
                    flexibleSpace: useGlass
                        ? const GlassContainer(
                            borderRadius: 0,
                            withBlur: true,
                            opacity: 0.05,
                            child: FlexibleSpaceBar(),
                          )
                        : null,
                    title: const Text(
                      'Watch History',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    centerTitle: true,
                    actions: [
                      if (historyList.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.delete_sweep_rounded),
                          onPressed: () => _showClearAllDialog(context),
                          tooltip: 'Clear All',
                        ),
                    ],
                  ),
                  if (historyList.isEmpty)
                    SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.history_rounded,
                              size: 84,
                              color: colorScheme.primary.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'NO HISTORY YET',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Start watching to see your history here!',
                              style: TextStyle(color: colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final entry = historyList[index];
                            final id = entry.key;
                            final history = entry.value;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _HistoryCard(
                                animeId: id,
                                history: history,
                              ),
                            );
                          },
                          childCount: historyList.length,
                        ),
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showClearAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All History'),
        content: const Text('Are you sure you want to clear all your watch history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              HistoryService().clearHistory();
              Navigator.pop(context);
            },
            child: const Text('Clear All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final String animeId;
  final WatchHistory history;

  const _HistoryCard({
    required this.animeId,
    required this.history,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final useGlass = ThemeService().useGlassTheme;

    return GlassContainer(
      borderRadius: 16,
      opacity: 0.05,
      withBlur: useGlass,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AnimeDetailPage(
                anime: Anime(
                  id: animeId,
                  name: history.name ?? 'Unknown',
                  thumbnail: history.thumbnail ?? '',
                  isManga: history.isManga,
                ),
                isManga: history.isManga,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  history.thumbnail ?? '',
                  width: 60,
                  height: 80,
                  fit: BoxFit.cover,
                  headers: const {'Referer': 'https://youtu-chan.com'},
                  errorBuilder: (context, _, __) => Container(
                    width: 60,
                    height: 80,
                    color: colorScheme.surfaceContainerHighest,
                    child: const Icon(Icons.image_not_supported_rounded),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      history.name ?? 'Unknown Anime',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${history.isManga ? 'Chapter' : 'Episode'} ${history.episode}',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              // Delete Button
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded),
                onPressed: () {
                  HistoryService().deleteHistory(animeId);
                },
                color: colorScheme.error,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
