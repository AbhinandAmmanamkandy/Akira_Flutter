import 'package:flutter/material.dart';
import 'package:akira/models/anime.dart';
import 'package:akira/services/anime_service.dart';
import 'package:akira/services/manga_service.dart';
import 'package:akira/services/theme_service.dart';
import 'package:akira/services/favorite_service.dart';
import 'package:akira/services/history_service.dart';
import 'package:akira/models/anime_details.dart';
import 'package:akira/ui/pages/watch_page/watch_page.dart';
import 'package:akira/gestures/overscroll_dismiss_gesture.dart';
import 'package:akira/gestures/f_symbol_gesture.dart';
import 'package:akira/ui/pages/anime_list_page/anime_list_page.dart';
import 'package:akira/ui/pages/manga_reader_page/manga_reader_page.dart';
import 'widgets/detail_app_bar.dart';
import 'widgets/detail_action_row.dart';
import 'widgets/detail_metadata_bar.dart';
import 'widgets/detail_description_section.dart';
import 'widgets/detail_tags_row.dart';
import 'widgets/detail_related_section.dart';
import 'package:akira/ui/widgets/custom_status_indicator.dart';

class AnimeDetailPage extends StatefulWidget {
  final Anime anime;
  final bool isManga;

  const AnimeDetailPage({super.key, required this.anime, this.isManga = false});

  @override
  State<AnimeDetailPage> createState() => _AnimeDetailPageState();
}

class _AnimeDetailPageState extends State<AnimeDetailPage> {
  late Future<AnimeDetails?> _detailsFuture;
  final AnimeService _animeService = AnimeService();
  final MangaService _mangaService = MangaService();
  final FavoriteService _favoriteService = FavoriteService();
  final HistoryService _historyService = HistoryService();
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<bool> _isCollapsed = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _detailsFuture = widget.isManga 
        ? _mangaService.fetchMangaDetails(widget.anime.id)
        : _animeService.fetchAnimeDetails(widget.anime.id);
    _historyService.init();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    // expandedHeight (400) - toolbarHeight (56) - status bar height (~30-40)
    final threshold =
        400 - kToolbarHeight - MediaQuery.of(context).padding.top - 20;
    final isCollapsed = _scrollController.offset > threshold;

    if (isCollapsed != _isCollapsed.value) {
      _isCollapsed.value = isCollapsed;
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _isCollapsed.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final themeService = ThemeService();

    return ListenableBuilder(
      listenable: Listenable.merge([
        themeService,
        _favoriteService,
        _historyService,
      ]),
      builder: (context, _) {
        final useGlass = themeService.useGlassTheme;
        final isFavorite = _favoriteService.isFavorite(widget.anime.id);
        final history = _historyService.getHistory(widget.anime.id);

        return Scaffold(
          body: GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: Stack(
              children: [
                if (useGlass)
                  Positioned.fill(child: Container(color: colorScheme.surface)),
                FSymbolGesture(
                  onSymbolDetected: () {
                    final animeToSave = Anime(
                      id: widget.anime.id,
                      name: widget.anime.name,
                      englishName: widget.anime.englishName,
                      thumbnail: widget.anime.thumbnail,
                      lastEpisode: widget.anime.lastEpisode,
                      isManga: widget.isManga,
                    );
                    _favoriteService.toggleFavorite(animeToSave);
                    CustomStatusIndicator.show(
                      context,
                      isFavorite
                          ? 'Removed from favorites'
                          : 'Added to favorites',
                      isFavorite
                          ? Icons.favorite_border_rounded
                          : Icons.favorite_rounded,
                    );
                  },
                  child: OverscrollDismissGesture(
                    child: CustomScrollView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      slivers: [
                        ValueListenableBuilder<bool>(
                          valueListenable: _isCollapsed,
                          builder: (context, isCollapsed, _) {
                            return DetailAppBar(
                              anime: widget.anime,
                              isFavorite: isFavorite,
                              isCollapsed: isCollapsed,
                              onFavoriteTap: () {
                                final animeToSave = Anime(
                                  id: widget.anime.id,
                                  name: widget.anime.name,
                                  englishName: widget.anime.englishName,
                                  thumbnail: widget.anime.thumbnail,
                                  lastEpisode: widget.anime.lastEpisode,
                                  isManga: widget.isManga,
                                );
                                _favoriteService.toggleFavorite(animeToSave);
                                CustomStatusIndicator.show(
                                  context,
                                  isFavorite
                                      ? 'Removed from favorites'
                                      : 'Added to favorites',
                                  isFavorite
                                      ? Icons.favorite_border_rounded
                                      : Icons.favorite_rounded,
                                );
                              },
                            );
                          },
                        ),
                        SliverToBoxAdapter(
                          child: FutureBuilder<AnimeDetails?>(
                            future: _detailsFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const SizedBox(
                                  height: 300,
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }

                              if (snapshot.hasError || !snapshot.hasData) {
                                final bool isNoInternet = snapshot.error is NoInternetException;
                                return SizedBox(
                                  height: 300,
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          isNoInternet ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
                                          size: 48,
                                          color: colorScheme.error,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          isNoInternet 
                                              ? 'No Internet Connection' 
                                              : 'Failed to load details',
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        if (isNoInternet) ...[
                                          const SizedBox(height: 8),
                                          const Text(
                                            'Please check your connection and try again',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ],
                                        const SizedBox(height: 24),
                                        FilledButton.tonalIcon(
                                          onPressed: () {
                                            setState(() {
                                              _detailsFuture = widget.isManga
                                                  ? _mangaService.fetchMangaDetails(widget.anime.id)
                                                  : _animeService.fetchAnimeDetails(widget.anime.id);
                                            });
                                          },
                                          icon: const Icon(Icons.refresh_rounded),
                                          label: const Text('Retry'),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }

                              final details = snapshot.data!;

                              return Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    RepaintBoundary(
                                      child: DetailTagsRow(
                                        details: details,
                                        onTagTap: (tag) {
                                          FocusManager.instance.primaryFocus
                                              ?.unfocus();
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => AnimeListPage(
                                                initialGenre: tag,
                                                isManga: widget.isManga,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    RepaintBoundary(
                                      child: DetailActionRow(
                                        continueEpisode: history?.episode,
                                        isManga: widget.isManga,
                                        onPlayTap: () async {
                                          if (widget.isManga) {
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => MangaReaderPage(
                                                  anime: widget.anime,
                                                  details: details,
                                                ),
                                              ),
                                            );
                                            return;
                                          }
                                          FocusManager.instance.primaryFocus
                                              ?.unfocus();
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
                                    ),
                                    const SizedBox(height: 24),
                                    RepaintBoundary(
                                      child: DetailMetadataBar(details: details),
                                    ),
                                    const SizedBox(height: 24),
                                    RepaintBoundary(
                                      child: DetailDescriptionSection(
                                        description: details.description,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    DetailRelatedSection(
                                      relatedShows: details.relatedShows,
                                      isManga: widget.isManga,
                                    ),
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
          ),
        );
      },
    );
  }
}
