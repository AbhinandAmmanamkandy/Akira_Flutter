import '../../models/anime.dart';
import 'widgets/list_search_bar.dart';
import 'widgets/list_grid.dart';
import 'widgets/list_state_views.dart';
import 'package:flutter/material.dart';
import '../../services/anime_service.dart';
import '../../services/theme_service.dart';
import 'widgets/list_app_bar.dart';

class AnimeListPage extends StatefulWidget {
  const AnimeListPage({super.key});

  @override
  State<AnimeListPage> createState() => _AnimeListPageState();
}

class _AnimeListPageState extends State<AnimeListPage> {
  bool _isSearching = false;
  double _appBarOpacity = 0.0;
  late Future<List<Anime>> _animeList;
  final AnimeService _animeService = AnimeService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animeList = _animeService.fetchAnime();
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
      _animeList = _animeService.fetchAnime(queryText: query);
    });
  }

  void _toggleSearch() {
    setState(() {
      if (_isSearching) {
        _isSearching = false;
        _searchController.clear();
        _animeList = _animeService.fetchAnime();
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
          canPop: !_isSearching,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            if (_isSearching) {
              _toggleSearch();
            }
          },
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            extendBody: true,
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    colorScheme.surface,
                  ],
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
                      return CustomScrollView(
                        controller: _scrollController,
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
                                _animeList = _animeService.fetchAnime(
                                  queryText: _searchController.text,
                                );
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
                            ListGrid(animeList: snapshot.data!),
                          const SliverToBoxAdapter(
                            child: SizedBox(height: 130), // Space for the bottom search bar
                          ),
                        ],
                      );
                    },
                  ),
                  ListSearchBar(
                    controller: _searchController,
                    onSearch: _onSearch,
                    onChanged: (value) {
                      setState(() {
                        _isSearching = value.isNotEmpty;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
