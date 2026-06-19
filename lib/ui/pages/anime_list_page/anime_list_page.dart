import 'dart:math';
import 'package:akira/models/anime.dart';
import 'package:akira/ui/pages/bookmarks_page/bookmarks_page.dart';
import 'package:akira/ui/pages/anime_detail_page/anime_detail_page.dart';
import 'widgets/bottom_search_bar.dart';
import 'widgets/list_grid.dart';
import 'widgets/list_state_views.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:akira/services/anime_service.dart';
import 'package:akira/services/manga_service.dart';
import 'package:akira/services/theme_service.dart';
import 'package:akira/theme/akira_colors.dart';
import 'package:akira/gestures/overscroll_dismiss_gesture.dart';
import 'package:akira/gestures/search_symbol_gesture.dart';
import 'package:akira/gestures/m_symbol_gesture.dart';
import 'package:akira/animations/scale_fade_visibility.dart';
import 'widgets/list_app_bar.dart';
import 'widgets/hint_banner.dart';
import 'widgets/floating_filter_bar.dart';
import 'package:akira/ui/widgets/common_chip.dart';
import 'package:akira/ui/widgets/glass_container.dart';
import 'package:akira/ui/widgets/custom_status_indicator.dart';

class AnimeListPage extends StatefulWidget {
  final String? initialSearch;
  final String? initialGenre;
  final bool isManga;

  const AnimeListPage({
    super.key,
    this.initialSearch,
    this.initialGenre,
    this.isManga = false,
  });

  @override
  State<AnimeListPage> createState() => _AnimeListPageState();
}

class _AnimeListPageState extends State<AnimeListPage> {
  static bool _hasShownSessionHint = false;
  bool _isSearching = false;
  double _appBarOpacity = 0.0;
  late Future<List<Anime>> _homeAnimeList;
  late Future<List<Anime>> _animeList;
  final AnimeService _animeService = AnimeService();
  final MangaService _mangaService = MangaService();
  late bool _isManga;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  bool _showHint = false;
  String _hintText = '';

  @override
  void initState() {
    super.initState();
    _isManga = widget.isManga;
    _refreshHomeList();

    if (widget.initialGenre != null) {
      _isSearching = true;
      _searchController.text = widget.initialGenre!;
      _animeList = _isManga
          ? _mangaService.fetchManga(queryText: widget.initialGenre!)
          : _animeService.fetchAnime(genres: [widget.initialGenre!]);
    } else if (widget.initialSearch != null) {
      _isSearching = true;
      _searchController.text = widget.initialSearch!;
      _animeList = _fetchByQuery(widget.initialSearch!);
    } else {
      _animeList = _homeAnimeList;
    }

    _scrollController.addListener(_onScroll);
    _initHint();
  }

  void _refreshHomeList() {
    _homeAnimeList = _isManga
        ? _mangaService.fetchManga()
        : _animeService.fetchAnime();
    if (!_isSearching) {
      _animeList = _homeAnimeList;
    }
  }

  void _toggleMode() {
    setState(() {
      _isManga = !_isManga;
      _refreshHomeList();
      if (_isSearching) {
        _animeList = _fetchByQuery(_searchController.text);
      }
    });
  }

  void _initHint() {
    if (_hasShownSessionHint ||
        widget.initialSearch != null ||
        !ThemeService().showTooltips) {
      return;
    }

    final hints = [
      'TIP: Swipe down to summon your Bookmarks',
      'TIP: Draw an F to add anime to favorites',
      'TIP: Draw an S to search instantly',
      'TIP: Draw an M to switch to Manga and to come back',
      'TIP: Long press on genres in search to remove it and in detail long press to add it',
      'TIP: Slide down in player screen to go to full screen',
      'TIP: Slide up or down from the middle of video player to go to full screen and back',
      'TIP: Tap on tags to explore similar worlds',
      'TIP: Scroll down to hide this System Advisory',
    ];
    _hintText = hints[Random().nextInt(hints.length)];

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted && !_hasShownSessionHint) {
        setState(() {
          _showHint = true;
          _hasShownSessionHint = true;
        });
      }
    });

    Future.delayed(const Duration(seconds: 8), () {
      if (mounted && _showHint) {
        setState(() => _showHint = false);
      }
    });
  }

  void _onScroll() {
    final offset = _scrollController.offset;

    if (offset > 20 && _showHint) {
      setState(() => _showHint = false);
    }

    final newOpacity = (offset / 90).clamp(0.0, 1.0);
    if (newOpacity != _appBarOpacity) {
      setState(() {
        _appBarOpacity = newOpacity;
      });
    }
  }

  Future<List<Anime>> _fetchByQuery(String query) {
    final List<String> genres = [
      'Action',
      'Comedy',
      'Romance',
      'Fantasy',
      'Thriller',
      'Horror',
      'Sci-Fi',
      'Mystery',
      'Historical',
      'Isekai',
      'Slice of Life',
      'Supernatural',
      'Psychological',
      'Drama',
      'Adventure',
    ];
    if (query.isEmpty) {
      return _homeAnimeList;
    } else if (query.toLowerCase() == 'trending') {
      return _isManga
          ? _mangaService.fetchPopularManga()
          : _animeService.fetchPopularAnime();
    } else if (genres.contains(query)) {
      return _isManga
          ? _mangaService.fetchManga(queryText: query)
          : _animeService.fetchAnime(genres: [query]);
    } else {
      return _isManga
          ? _mangaService.fetchManga(queryText: query)
          : _animeService.fetchAnime(queryText: query);
    }
  }

  void _onSearch(String query) {
    if (_searchController.text != query) {
      _searchController.text = query;
    }
    setState(() {
      _showHint = false;
      _isSearching = query.isNotEmpty;
      _animeList = _fetchByQuery(query);
      FocusManager.instance.primaryFocus?.unfocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
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

        return Scaffold(
          resizeToAvoidBottomInset: false,
          extendBody: true,
          body: PopScope(
            canPop: !_isSearching && !_searchFocusNode.hasFocus && !_isManga,
            onPopInvokedWithResult: (didPop, result) {
              if (didPop) return;
              if (_searchFocusNode.hasFocus) {
                _searchFocusNode.unfocus();
              } else if (_isSearching) {
                setState(() {
                  _isSearching = false;
                  _searchController.clear();
                  _animeList = _homeAnimeList;
                });
              } else if (_isManga) {
                _toggleMode();
              }
            },
            child: MSymbolGesture(
              onSymbolDetected: () {
                _toggleMode();
                HapticFeedback.heavyImpact();
              },
              child: SearchSymbolGesture(
                onSymbolDetected: () {
                  _searchFocusNode.requestFocus();
                },
                child: GestureDetector(
                  onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AkiraColors.getBackground(
                        colorScheme,
                        Theme.of(context).brightness == Brightness.light,
                      ),
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
                                color: colorScheme.primary.withValues(
                                  alpha: 0.1,
                                ),
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
                                color: colorScheme.secondary.withValues(
                                  alpha: 0.08,
                                ),
                              ),
                            ),
                          ),
                        ],
                        FutureBuilder<List<Anime>>(
                          future: _animeList,
                          builder: (context, snapshot) {
                            return OverscrollDismissGesture(
                              onDismiss: () {
                                FocusManager.instance.primaryFocus?.unfocus();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const BookmarksPage(),
                                  ),
                                );
                              },
                              child: CustomScrollView(
                                controller: _scrollController,
                                keyboardDismissBehavior:
                                    ScrollViewKeyboardDismissBehavior.onDrag,
                                physics: const AlwaysScrollableScrollPhysics(
                                  parent: BouncingScrollPhysics(),
                                ),
                                slivers: [
                                  ListAppBar(
                                    appBarOpacity: _appBarOpacity,
                                    isManga: _isManga,
                                    onToggleMode: _toggleMode,
                                  ),

                                  // Tooltip Hint Banner
                                  if (ThemeService().showTooltips)
                                    SliverToBoxAdapter(
                                      child: ScaleFadeVisibility(
                                        isVisible:
                                            _showHint && _appBarOpacity < 0.1,
                                        child: HintBanner(text: _hintText),
                                      ),
                                    ),

                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting)
                                    const SliverFillRemaining(
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    )
                                  else if (snapshot.hasError)
                                    ListErrorView(
                                      error: snapshot.error,
                                      onRetry: () => setState(() {
                                        _animeList = _fetchByQuery(
                                          _searchController.text,
                                        );
                                      }),
                                    )
                                  else if (!snapshot.hasData ||
                                      snapshot.data!.isEmpty)
                                    ListEmptyView(
                                      isSearching: _isSearching,
                                      onClearSearch: () {
                                        _searchController.clear();
                                        _onSearch('');
                                      },
                                    )
                                  else
                                    ListGrid(
                                      animeList: snapshot.data!,
                                      isManga: _isManga,
                                      onAnimeTap: (anime) async {
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();

                                        if (!mounted) return;

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                AnimeDetailPage(
                                                  anime: anime,
                                                  isManga: _isManga,
                                                ),
                                          ),
                                        );
                                      },
                                    ),
                                  const SliverToBoxAdapter(
                                    child: SizedBox(height: 100),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        FloatingFilterBar(
                          isManga: _isManga,
                          searchText: _searchController.text,
                          onToggleMode: _toggleMode,
                          onSearch: _onSearch,
                        ),
                        BottomSearchBar(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          onSearch: _onSearch,
                          onChanged: (value) => setState(() {}),
                          isManga: _isManga,
                          onToggleMode: _toggleMode,
                          onClear: () {
                            setState(() {
                              _isSearching = false;
                              _animeList = _homeAnimeList;
                              FocusManager.instance.primaryFocus?.unfocus();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

}
