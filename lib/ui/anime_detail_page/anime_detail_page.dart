import 'package:flutter/material.dart';
import '../../models/anime.dart';
import '../../services/anime_service.dart';
import '../../services/theme_service.dart';
import '../../services/favorite_service.dart';
import '../../models/anime_details.dart';
import '../watch_page/watch_page.dart';
import '../widgets/glass_container.dart';
import 'widgets/detail_app_bar.dart';
import 'widgets/detail_action_row.dart';
import 'widgets/detail_metadata_bar.dart';
import 'widgets/detail_description_section.dart';
import 'widgets/detail_tags_row.dart';

class AnimeDetailPage extends StatefulWidget {
  final Anime anime;

  const AnimeDetailPage({super.key, required this.anime});

  @override
  State<AnimeDetailPage> createState() => _AnimeDetailPageState();
}

class _AnimeDetailPageState extends State<AnimeDetailPage> {
  final ScrollController _scrollController = ScrollController();
  final AnimeService _animeService = AnimeService();
  bool _isLoadingDetails = false;
  AnimeDetails? _details;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    if (widget.anime.id.isEmpty) return;
    
    setState(() {
      _isLoadingDetails = true;
    });
    
    try {
      final details = await _animeService.fetchAnimeDetails(widget.anime.id);
      if (details != null && mounted) {
        setState(() {
          _details = details;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingDetails = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        ThemeService(),
        FavoriteService(),
      ]),
      builder: (context, _) {
        final animeData = _details ?? widget.anime;
        final colorScheme = Theme.of(context).colorScheme;
        final useGlass = ThemeService().useGlassTheme;

        return Scaffold(
          body: Stack(
            children: [
              if (useGlass) ...[
                Positioned(
                  top: 300,
                  right: -50,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorScheme.primary.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                Positioned(
                  top: 600,
                  left: -50,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorScheme.secondary.withValues(alpha: 0.08),
                    ),
                  ),
                ),
              ],
              NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is ScrollUpdateNotification) {
                    if (notification.metrics.pixels < -80 && notification.dragDetails != null) {
                      Navigator.of(context).pop();
                      return true;
                    }
                  }
                  return false;
                },
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                    DetailAppBar(anime: animeData),
                    _buildContent(context, animeData),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, Anime animeData) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isLoadingDetails)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 60.0),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_details != null) ...[
              DetailActionRow(
                isBookmarked: FavoriteService().isFavorite(animeData.id),
                onWatchNow: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WatchPage(
                        anime: animeData,
                        details: _details,
                      ),
                    ),
                  );
                },
                onBookmark: () {
                  final isAdding = !FavoriteService().isFavorite(animeData.id);
                  FavoriteService().toggleFavorite(animeData);
                  
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      behavior: SnackBarBehavior.floating,
                      content: GlassContainer(
                        borderRadius: 16,
                        opacity: 0.2,
                        blur: 15,
                        withBlur: true,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: Border.all(
                          color: colorScheme.primary.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isAdding ? Icons.bookmark_added_rounded : Icons.bookmark_remove_rounded,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              isAdding ? 'Added to bookmarks' : 'Removed from bookmarks',
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              DetailTagsRow(details: _details!),
              const SizedBox(height: 24),

              DetailMetadataBar(details: _details!),
              const SizedBox(height: 32),

              DetailDescriptionSection(description: _details!.description),
            ] else ...[
              // Error State
              Center(
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    Icon(
                      Icons.error_outline_rounded,
                      size: 64,
                      color: colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Oops! Something went wrong',
                      style: textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'We couldn\'t load the show details.',
                      style: textTheme.bodyMedium?.copyWith(color: colorScheme.outline),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.tonalIcon(
                      onPressed: _fetchDetails,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
