import 'package:flutter/material.dart';
import '../models/anime.dart';
import '../services/anime_service.dart';
import 'anime_detail_page.dart';

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
    final newOpacity = (offset / 80).clamp(0.0, 0.97);
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
    return Scaffold(
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
        child: FutureBuilder<List<Anime>>(
          future: _animeList,
          builder: (context, snapshot) {
            return CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverAppBar(
                  expandedHeight: _isSearching ? 0 : 160.0,
                  floating: false,
                  pinned: true,
                  stretch: true,
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .surface
                      .withValues(alpha: _appBarOpacity),
                  elevation: 0,
                  centerTitle: true,
                  title: _isSearching
                      ? AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: 48,
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest
                                .withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            autofocus: true,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 16,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search anime...',
                              border: InputBorder.none,
                              prefixIcon: const Icon(Icons.search, size: 22),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.close_rounded, size: 20),
                                      onPressed: () {
                                        _searchController.clear();
                                        _onSearch('');
                                      },
                                    )
                                  : null,
                              contentPadding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onSubmitted: _onSearch,
                            onChanged: (value) => setState(() {}),
                          ),
                        )
                      : null,
                  flexibleSpace: _isSearching
                      ? null
                      : FlexibleSpaceBar(
                          centerTitle: true,
                          expandedTitleScale: 1.5,
                          titlePadding: const EdgeInsets.only(bottom: 24),
                          title: InkWell(
                            onTap: _toggleSearch,
                            borderRadius: BorderRadius.circular(20),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Akira',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.4),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.search,
                                      size: 14,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                  actions: _isSearching
                      ? [
                          const SizedBox(width: 48), // Spacer for balance
                        ]
                      : [],
                ),
                if (snapshot.connectionState == ConnectionState.waiting)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (snapshot.hasError)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 48, color: Colors.red),
                          const SizedBox(height: 16),
                          Text('Error: ${snapshot.error}'),
                          ElevatedButton(
                            onPressed: () => setState(() {
                              _animeList = _animeService.fetchAnime(
                                  queryText: _searchController.text);
                            }),
                            child: const Text('Retry'),
                          )
                        ],
                      ),
                    ),
                  )
                else if (!snapshot.hasData || snapshot.data!.isEmpty)
                  SliverFillRemaining(
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
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.6,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return AnimeCard(anime: snapshot.data![index]);
                        },
                        childCount: snapshot.data!.length,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class AnimeCard extends StatelessWidget {
  final Anime anime;

  const AnimeCard({super.key, required this.anime});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnimeDetailPage(anime: anime),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 0.7,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Hero(
                tag: 'anime_${anime.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: anime.thumbnail != null
                      ? Image.network(
                          anime.thumbnail!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _placeholder(context, Icons.broken_image),
                        )
                      : _placeholder(context, Icons.movie),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                anime.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      height: 1.2,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder(BuildContext context, IconData icon) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(icon, size: 40),
    );
  }
}
