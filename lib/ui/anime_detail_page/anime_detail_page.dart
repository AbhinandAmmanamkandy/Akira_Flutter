import 'package:flutter/material.dart';
import '../../models/anime.dart';
import '../../services/anime_service.dart';
import '../../models/anime_details.dart';
import '../watch_page/watch_page.dart';
import 'widgets/detail_app_bar.dart';
import 'widgets/detail_stat_pill.dart';
import 'widgets/detail_info_badge.dart';
import 'widgets/detail_genre_tag.dart';

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
    final animeData = _details ?? widget.anime;
    
    return Scaffold(
      body: NotificationListener<ScrollNotification>(
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
    );
  }

  Widget _buildMetadataSection(AnimeDetails details) {
    return Row(
      children: [
        DetailStatPill(
          icon: Icons.wb_sunny_rounded,
          value: details.season?.quarter ?? 'N/A',
          label: 'Season',
        ),
        const SizedBox(width: 10),
        DetailStatPill(
          icon: Icons.calendar_today_rounded,
          value: details.season?.year?.toString() ?? 'N/A',
          label: 'Year',
        ),
        const SizedBox(width: 10),
        DetailStatPill(
          icon: Icons.video_library_rounded,
          value: details.lastEpisode ?? 'N/A',
          label: 'Episodes',
        ),
      ],
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
              // Action Buttons Row
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
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
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('Watch Now'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.bookmark_border_rounded,
                          color: colorScheme.onSecondaryContainer),
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Genres & Status & Rating & Score
              if (_details!.genres.isNotEmpty || _details!.status != null || _details!.rating != null || _details!.averageScore != null) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (_details!.averageScore != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded, size: 14, color: Colors.black87),
                            const SizedBox(width: 4),
                            Text(
                              (_details!.averageScore! / 10).toStringAsFixed(1),
                              style: textTheme.labelSmall?.copyWith(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (_details!.status != null)
                      DetailInfoBadge(
                        text: _details!.status!.toUpperCase(),
                        bgColor: colorScheme.tertiaryContainer,
                        textColor: colorScheme.onTertiaryContainer,
                      ),
                    if (_details!.rating != null)
                      DetailInfoBadge(
                        text: _details!.rating!,
                        bgColor: colorScheme.secondaryContainer,
                        textColor: colorScheme.onSecondaryContainer,
                      ),
                    ..._details!.genres.map((g) => DetailGenreTag(label: g)),
                  ],
                ),
                const SizedBox(height: 24),
              ],

              // Metadata Bar
              _buildMetadataSection(_details!),
              const SizedBox(height: 32),

              // Description Section
              if (_details!.description != null && _details!.description!.isNotEmpty) ...[
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 24,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Overview',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  _details!.description!,
                  style: textTheme.bodyLarge?.copyWith(
                    height: 1.6,
                    color: colorScheme.onSurfaceVariant,
                    letterSpacing: 0.2,
                  ),
                ),
              ] else
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40.0),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.notes_rounded,
                            size: 40, color: colorScheme.outline),
                        const SizedBox(height: 8),
                        const Text('No description available.'),
                      ],
                    ),
                  ),
                ),
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
