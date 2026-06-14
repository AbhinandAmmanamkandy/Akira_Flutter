import 'package:flutter/material.dart';
import '../models/anime.dart';
import '../services/anime_service.dart';
import '../widgets/anime_card.dart';
import '../widgets/anime_grid.dart';
import '../widgets/anime_list_header.dart';
import '../widgets/search_bar.dart';
import '../widgets/state_widgets.dart';
import 'settings_page.dart';

class AnimeListPage extends StatefulWidget {
  const AnimeListPage({super.key});

  @override
  State<AnimeListPage> createState() => _AnimeListPageState();
}

class _AnimeListPageState extends State<AnimeListPage> {
  final AnimeService _animeService = AnimeService();
  late Future<List<Anime>> _animeList;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSearching = false;
  double _appBarOpacity = 0.0;

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
                Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                Theme.of(context).colorScheme.surface,
              ],
            ),
          ),
          child: Stack(
            children: [
              FutureBuilder<List<Anime>>(
                future: _animeList,
                builder: (context, snapshot) {
                  return CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      AnimeListHeader(appBarOpacity: _appBarOpacity),
                      if (snapshot.connectionState == ConnectionState.waiting)
                        const SliverFillRemaining(
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (snapshot.hasError)
                        ErrorStateWidget(
                          error: snapshot.error,
                          onRetry: () => setState(() {
                            _animeList = _animeService.fetchAnime(
                              queryText: _searchController.text,
                            );
                          }),
                        )
                      else if (!snapshot.hasData || snapshot.data!.isEmpty)
                        EmptyStateWidget(
                          isSearching: _isSearching,
                          onClearSearch: () {
                            _searchController.clear();
                            _toggleSearch();
                          },
                        )
                      else
                        AnimeGrid(animeList: snapshot.data!),
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 130), // Space for the bottom search bar
                      ),
                    ],
                  );
                },
              ),
              BottomSearchBar(
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
  }
}
