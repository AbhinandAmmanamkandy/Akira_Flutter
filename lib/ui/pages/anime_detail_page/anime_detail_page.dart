import 'package:flutter/material.dart';
import 'package:akira/models/anime.dart';
import 'package:akira/services/anime_service.dart';
import 'package:akira/services/theme_service.dart';
import 'package:akira/services/favorite_service.dart';
import 'package:akira/services/history_service.dart';
import 'package:akira/models/anime_details.dart';
import 'package:akira/ui/pages/watch_page/watch_page.dart';
import 'package:akira/gestures/overscroll_dismiss_gesture.dart';
import 'package:akira/gestures/f_symbol_gesture.dart';
import 'package:akira/ui/pages/anime_list_page/anime_list_page.dart';
import 'widgets/detail_app_bar.dart';
import 'widgets/detail_action_row.dart';
import 'widgets/detail_metadata_bar.dart';
import 'widgets/detail_description_section.dart';
import 'widgets/detail_tags_row.dart';
import 'package:akira/ui/widgets/custom_status_indicator.dart';

class AnimeDetailPage extends StatefulWidget {
  final Anime anime;

  const AnimeDetailPage({super.key, required this.anime});

  @override
  State<AnimeDetailPage> createState() => _AnimeDetailPageState();
}

class _AnimeDetailPageState extends State<AnimeDetailPage> {
  late Future<AnimeDetails?> _detailsFuture;
  final AnimeService _animeService = AnimeService();
  final FavoriteService _favoriteService = FavoriteService();
  final HistoryService _historyService = HistoryService();

  @override
  void initState() {
    super.initState();
    _detailsFuture = _animeService.fetchAnimeDetails(widget.anime.id);
    _historyService.init();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final themeService = ThemeService();

    return ListenableBuilder(
      listenable: Listenable.merge([themeService, _favoriteService, _historyService]),
      builder: (context, _) {
        final useGlass = themeService.useGlassTheme;
        final isFavorite = _favoriteService.isFavorite(widget.anime.id);
        final history = _historyService.getHistory(widget.anime.id);

        return Scaffold(
          body: Stack(
            children: [
              if (useGlass)
                Positioned.fill(
                  child: Container(
                    color: colorScheme.surface,
                  ),
                ),
              FSymbolGesture(
                onSymbolDetected: () {
                  _favoriteService.toggleFavorite(widget.anime);
                  CustomStatusIndicator.show(
                    context,
                    isFavorite ? 'Removed from favorites' : 'Added to favorites',
                    isFavorite ? Icons.favorite_border_rounded : Icons.favorite_rounded,
                  );
                },
                child: OverscrollDismissGesture(
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    slivers: [
                      DetailAppBar(
                        anime: widget.anime,
                        isFavorite: isFavorite,
                        onFavoriteTap: () {
                          _favoriteService.toggleFavorite(widget.anime);
                          CustomStatusIndicator.show(
                            context,
                            isFavorite ? 'Removed from favorites' : 'Added to favorites',
                            isFavorite ? Icons.favorite_border_rounded : Icons.favorite_rounded,
                          );
                        },
                      ),
                      SliverToBoxAdapter(
                        child: FutureBuilder<AnimeDetails?>(
                          future: _detailsFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const SizedBox(
                                height: 300,
                                child: Center(child: CircularProgressIndicator()),
                              );
                            }

                            if (snapshot.hasError || !snapshot.hasData) {
                              return const SizedBox(
                                height: 300,
                                child: Center(child: Text('Failed to load details')),
                              );
                            }

                            final details = snapshot.data!;

                            return Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  DetailTagsRow(
                                    details: details,
                                    onTagTap: (tag) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AnimeListPage(initialSearch: tag),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 24),
                                  DetailActionRow(
                                    continueEpisode: history?.episode,
                                    onPlayTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => WatchPage(
                                            anime: widget.anime,
                                            details: details,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 24),
                                  DetailMetadataBar(details: details),
                                  const SizedBox(height: 24),
                                  DetailDescriptionSection(description: details.description),
                                  const SizedBox(height: 100),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
