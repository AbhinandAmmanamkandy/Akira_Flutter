import 'package:flutter/material.dart';
import '../models/anime.dart';
import '../services/anime_service.dart';
import '../widgets/anime_card.dart';
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
                      _buildAppBar(context),
                      if (snapshot.connectionState == ConnectionState.waiting)
                        const SliverFillRemaining(
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (snapshot.hasError)
                        _buildErrorState(snapshot.error)
                      else if (!snapshot.hasData || snapshot.data!.isEmpty)
                        _buildEmptyState()
                      else
                        _buildAnimeGrid(snapshot.data!),
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 130), // Space for the bottom search bar
                      ),
                    ],
                  );
                },
              ),
              _buildBottomSearchBar(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SliverAppBar(
      expandedHeight: 170.0,
      pinned: true,
      stretch: true,
      backgroundColor: colorScheme.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
      ),
      automaticallyImplyLeading: false,
      toolbarHeight: 70,
      centerTitle: false,
      title: AnimatedOpacity(
        opacity: _appBarOpacity > 0.8 ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Text(
          'Akira',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      actions: [],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          'Akira',
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w900,
                            fontSize: 56,
                            height: 1.0,
                            letterSpacing: -2.0,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'HUB',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'YOUR ULTIMATE ANIME DESTINATION',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SettingsPage()),
                    );
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    padding: const EdgeInsets.all(12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: Icon(
                    Icons.settings_rounded,
                    size: 24,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSearchBar(BuildContext context) {
    return Positioned(
      bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      left: 20,
      right: 20,
      child: Hero(
        tag: 'search_bar',
        child: Material(
          color: Colors.transparent,
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHigh.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ColorFilter.mode(
                  Colors.white.withValues(alpha: 0.05),
                  BlendMode.overlay,
                ),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search for anime...',
                    hintStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                    ),
                    border: InputBorder.none,
                    prefixIcon: Container(
                      margin: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.search_rounded,
                        size: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              _onSearch('');
                              FocusScope.of(context).unfocus();
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  onSubmitted: _onSearch,
                  onChanged: (value) {
                    setState(() {
                      _isSearching = value.isNotEmpty;
                    });
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(Object? error) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $error'),
            ElevatedButton(
              onPressed: () => setState(() {
                _animeList = _animeService.fetchAnime(queryText: _searchController.text);
              }),
              child: const Text('Retry'),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No anime found.'),
            if (_isSearching)
              TextButton(
                onPressed: () {
                  _searchController.clear();
                  _toggleSearch();
                },
                child: const Text('Clear Search'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimeGrid(List<Anime> data) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.6,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => AnimeCard(anime: data[index]),
          childCount: data.length,
        ),
      ),
    );
  }
}
