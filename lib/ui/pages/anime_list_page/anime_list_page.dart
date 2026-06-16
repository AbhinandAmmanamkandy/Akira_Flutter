import 'package:akira/models/anime.dart';
import 'package:akira/ui/pages/bookmarks_page/bookmarks_page.dart';
import 'package:akira/ui/pages/anime_detail_page/anime_detail_page.dart';
import 'widgets/list_search_bar.dart';
import 'widgets/list_grid.dart';
import 'widgets/list_state_views.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:akira/services/anime_service.dart';
import 'package:akira/services/theme_service.dart';
import 'package:akira/theme/akira_colors.dart';
import 'package:akira/gestures/search_symbol_gesture.dart';
import 'package:akira/gestures/overscroll_dismiss_gesture.dart';
import 'widgets/list_app_bar.dart';

class AnimeListPage extends StatefulWidget {
  const AnimeListPage({super.key});

  @override
  State<AnimeListPage> createState() => _AnimeListPageState();
}

class _AnimeListPageState extends State<AnimeListPage> {
  bool _isSearching = false;
  double _appBarOpacity = 0.0;
  late Future<List<Anime>> _homeAnimeList;
  late Future<List<Anime>> _animeList;
  final AnimeService _animeService = AnimeService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _homeAnimeList = _animeService.fetchAnime();
    _animeList = _homeAnimeList;
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    final newOpacity = (offset / 120).clamp(0.0, 1.0);
    if (newOpacity != _appBarOpacity) {
      setState(() {
        _appBarOpacity = newOpacity;
      });
    }
  }

  void _onSearch(String query) {
    setState(() {
      final List<String> genres = ['Action', 'Comedy', 'Romance', 'Fantasy'];
      
      if (query.isEmpty) {
        _animeList = _homeAnimeList;
      } else if (query.toLowerCase() == 'trending') {
        _animeList = _animeService.fetchPopularAnime();
      } else if (genres.contains(query)) {
        _animeList = _animeService.fetchAnime(genres: [query]);
      } else {
        _animeList = _animeService.fetchAnime(queryText: query);
      }
    });
  }

  void _toggleSearch() {
    setState(() {
      if (_isSearching) {
        _isSearching = false;
        _searchController.clear();
        _animeList = _homeAnimeList;
      } else {
        _isSearching = true;
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeService(),
      builder: (context, _) {
        final colorScheme = Theme.of(context).colorScheme;
        final useGlass = ThemeService().useGlassTheme;

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (_isSearching) {
              _toggleSearch();
            } else {
              SystemNavigator.pop();
            }
          },
          child: SearchSymbolGesture(
            onSymbolDetected: () {
              if (!_isSearching) {
                _toggleSearch();
              }
            },
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              extendBody: true,
              body: Container(
              decoration: BoxDecoration(
                color: AkiraColors.getBackground(colorScheme, Theme.of(context).brightness == Brightness.light),
              ),
              child: Stack(
                children: [
                  if (useGlass) ...[
                    Positioned(
                      top: 200,
                      left: -100,
                      child: Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorScheme.primary.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -50,
                      right: -50,
                      child: Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorScheme.secondary.withValues(alpha: 0.08),
                        ),
                      ),
                    ),
                  ],
                  FutureBuilder<List<Anime>>(
                    future: _animeList,
                    builder: (context, snapshot) {
                      return OverscrollDismissGesture(
                        onDismiss: () {
                          FocusScope.of(context).unfocus();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const BookmarksPage(),
                            ),
                          );
                        },
                        child: CustomScrollView(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          slivers: [
                            ListAppBar(appBarOpacity: _appBarOpacity),
                            if (snapshot.connectionState == ConnectionState.waiting)
                              const SliverFillRemaining(
                                child: Center(child: CircularProgressIndicator()),
                              )
                            else if (snapshot.hasError)
                              ListErrorView(
                                error: snapshot.error,
                                onRetry: () => setState(() {
                                  final queryText = _searchController.text;
                                  final List<String> genres = ['Action', 'Comedy', 'Romance', 'Fantasy'];
                                  final Future<List<Anime>> future;
                                  
                                  if (queryText.toLowerCase() == 'trending') {
                                    future = _animeService.fetchPopularAnime();
                                  } else if (genres.contains(queryText)) {
                                    future = _animeService.fetchAnime(genres: [queryText]);
                                  } else {
                                    future = _animeService.fetchAnime(
                                      queryText: queryText,
                                    );
                                  }
                                  
                                  _animeList = future;
                                  if (queryText.isEmpty) {
                                    _homeAnimeList = future;
                                  }
                                }),
                              )
                            else if (!snapshot.hasData || snapshot.data!.isEmpty)
                              ListEmptyView(
                                isSearching: _isSearching,
                                onClearSearch: () {
                                  _searchController.clear();
                                  _toggleSearch();
                                },
                              )
                            else
                              ListGrid(
                                animeList: snapshot.data!,
                                onAnimeTap: (anime) async {
                                  if (_isSearching) {
                                    FocusScope.of(context).unfocus();
                                    _toggleSearch();
                                    // Give the animation a head start to avoid the "oval" glitch
                                    await Future.delayed(const Duration(milliseconds: 100));
                                  } else {
                                    FocusScope.of(context).unfocus();
                                  }
                                  
                                  if (!mounted) return;

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AnimeDetailPage(anime: anime),
                                    ),
                                  );
                                },
                              ),
                            const SliverToBoxAdapter(
                              child: SizedBox(height: 130), // Space for the bottom search bar
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  ListSearchBar(
                    controller: _searchController,
                    isExpanded: _isSearching,
                    onExpand: _toggleSearch,
                    onSearch: _onSearch,
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        );
      },
    );
  }
}
