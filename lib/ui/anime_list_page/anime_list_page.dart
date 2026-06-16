import '../../models/anime.dart';
import '../bookmarks_page/bookmarks_page.dart';
import '../anime_detail_page/anime_detail_page.dart';
import 'widgets/list_search_bar.dart';
import 'widgets/list_grid.dart';
import 'widgets/list_state_views.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/anime_service.dart';
import '../../services/theme_service.dart';
import '../../theme/akira_colors.dart';
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
  List<Offset> _gesturePoints = [];

  @override
  void initState() {
    super.initState();
    _homeAnimeList = _animeService.fetchAnime();
    _animeList = _homeAnimeList;
    _scrollController.addListener(_onScroll);
  }

  bool _isSGesture(List<Offset> points) {
    if (points.length < 15) return false;

    double minX = points[0].dx;
    double maxX = points[0].dx;
    double minY = points[0].dy;
    double maxY = points[0].dy;

    for (var p in points) {
      if (p.dx < minX) minX = p.dx;
      if (p.dx > maxX) maxX = p.dx;
      if (p.dy < minY) minY = p.dy;
      if (p.dy > maxY) maxY = p.dy;
    }

    double width = maxX - minX;
    double height = maxY - minY;

    // Must have a reasonable size
    if (width < 50 || height < 80) return false;

    List<int> horizontalDirections = [];
    for (int i = 1; i < points.length; i++) {
      double diff = points[i].dx - points[i - 1].dx;
      if (diff.abs() > 3) {
        horizontalDirections.add(diff > 0 ? 1 : -1);
      }
    }

    if (horizontalDirections.isEmpty) return false;

    List<int> reduced = [horizontalDirections.first];
    for (int i = 1; i < horizontalDirections.length; i++) {
      if (horizontalDirections[i] != reduced.last) {
        reduced.add(horizontalDirections[i]);
      }
    }

    // Check for "Left -> Right -> Left" sequence for an 'S' shape
    // Or "Right -> Left -> Right" for a mirrored 'S' or 'Z' shape
    bool hasSSequence = false;
    for (int i = 0; i <= reduced.length - 3; i++) {
      if ((reduced[i] == -1 && reduced[i + 1] == 1 && reduced[i + 2] == -1) ||
          (reduced[i] == 1 && reduced[i + 1] == -1 && reduced[i + 2] == 1)) {
        hasSSequence = true;
        break;
      }
    }

    return hasSSequence && (height > width * 0.8);
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
      if (query.isEmpty) {
        _animeList = _homeAnimeList;
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
          child: Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: (event) => _gesturePoints = [event.localPosition],
            onPointerMove: (event) => _gesturePoints.add(event.localPosition),
            onPointerUp: (event) {
              if (_isSGesture(_gesturePoints)) {
                if (!_isSearching) {
                  _toggleSearch();
                  HapticFeedback.mediumImpact();
                }
              }
              _gesturePoints = [];
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
                      return NotificationListener<ScrollNotification>(
                        onNotification: (notification) {
                          if (ThemeService().useOverscrollToClose &&
                              notification is ScrollUpdateNotification &&
                              notification.metrics.pixels < -100 &&
                              notification.dragDetails != null) {
                            FocusScope.of(context).unfocus();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const BookmarksPage(),
                              ),
                            );
                            return true;
                          }
                          return false;
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
                                  final future = _animeService.fetchAnime(
                                    queryText: _searchController.text,
                                  );
                                  _animeList = future;
                                  if (_searchController.text.isEmpty) {
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
