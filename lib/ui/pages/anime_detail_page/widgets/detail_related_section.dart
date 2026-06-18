import 'package:flutter/material.dart';
import 'package:akira/models/anime.dart';
import 'package:akira/models/anime_details.dart';
import 'package:akira/services/anime_service.dart';
import 'package:akira/services/manga_service.dart';
import 'package:akira/ui/widgets/glass_container.dart';
import '../anime_detail_page.dart';

class DetailRelatedSection extends StatefulWidget {
  final List<RelatedShow> relatedShows;
  final bool isManga;

  const DetailRelatedSection({
    super.key,
    required this.relatedShows,
    this.isManga = false,
  });

  @override
  State<DetailRelatedSection> createState() => _DetailRelatedSectionState();
}

class _DetailRelatedSectionState extends State<DetailRelatedSection> {
  late Future<List<Anime>> _relatedAnimeFuture;
  List<Anime>? _cachedAnimeList;
  Map<String, Anime>? _cachedAnimeMap;
  List<RelatedShow>? _cachedValidRelations;

  @override
  void initState() {
    super.initState();
    _initFuture();
  }

  @override
  void didUpdateWidget(DetailRelatedSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.relatedShows != widget.relatedShows) {
      _cachedAnimeList = null;
      _cachedAnimeMap = null;
      _cachedValidRelations = null;
      _initFuture();
    }
  }

  void _initFuture() {
    final ids = widget.relatedShows.map((s) => s.showId).toList();
    _relatedAnimeFuture = widget.isManga
        ? MangaService().fetchMangaWithIds(ids)
        : AnimeService().fetchAnimeWithIds(ids);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.relatedShows.isEmpty) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;

    return FutureBuilder<List<Anime>>(
      future: _relatedAnimeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && _cachedAnimeList == null) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final animeList = snapshot.data ?? _cachedAnimeList ?? [];
        if (animeList.isEmpty) return const SizedBox.shrink();

        if (_cachedAnimeList != animeList) {
          _cachedAnimeList = animeList;
          _cachedAnimeMap = {for (var a in animeList) a.id: a};
          _cachedValidRelations = widget.relatedShows
              .where((rel) => _cachedAnimeMap!.containsKey(rel.showId))
              .toList();
        }

        if (_cachedValidRelations == null || _cachedValidRelations!.isEmpty) {
          return const SizedBox.shrink();
        }

        return RepaintBoundary(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 3,
                    height: 14,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'RELATIONS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: colorScheme.onSurfaceVariant,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final itemWidth = (constraints.maxWidth - 12) / 2;
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _cachedValidRelations!.map((rel) {
                      return SizedBox(
                        width: itemWidth,
                        height: 66,
                        child: _RelatedShowTile(
                          show: rel,
                          anime: _cachedAnimeMap![rel.showId]!,
                          isManga: widget.isManga,
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RelatedShowTile extends StatelessWidget {
  final RelatedShow show;
  final Anime anime;
  final bool isManga;

  const _RelatedShowTile({
    required this.show,
    required this.anime,
    required this.isManga,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final rel = show.relation.toLowerCase();

    Color accentColor;
    IconData icon;

    if (rel == 'sequel') {
      accentColor = Colors.green;
      icon = Icons.arrow_forward_rounded;
    } else if (rel == 'prequel') {
      accentColor = Colors.blue;
      icon = Icons.arrow_back_rounded;
    } else if (rel == 'summary') {
      accentColor = Colors.teal;
      icon = Icons.summarize_rounded;
    } else if (rel.contains('alternative') || rel.contains('alt')) {
      accentColor = Colors.indigo;
      icon = Icons.swap_horiz_rounded;
    } else if (rel.contains('side story') || rel.contains('sidestory')) {
      accentColor = Colors.purple;
      icon = Icons.auto_stories_rounded;
    } else if (rel.contains('spin-off') || rel.contains('spinoff')) {
      accentColor = Colors.orange;
      icon = Icons.alt_route_rounded;
    } else if (rel.contains('full story')) {
      accentColor = Colors.cyan;
      icon = Icons.library_books_rounded;
    } else if (rel == 'other') {
      accentColor = Colors.blueGrey;
      icon = Icons.more_horiz_rounded;
    } else {
      accentColor = colorScheme.primary;
      icon = Icons.link_rounded;
    }

    final name = (anime.englishName != null && anime.englishName!.isNotEmpty)
        ? anime.englishName!
        : anime.name;

    return InkWell(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AnimeDetailPage(
              anime: anime,
              isManga: isManga,
            ),
          ),
        );
      },
      child: GlassContainer(
        borderRadius: 16,
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      show.relation.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        color: accentColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                Icon(
                  icon,
                  size: 14,
                  color: accentColor.withValues(alpha: 0.5),
                ),
              ],
            ),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
