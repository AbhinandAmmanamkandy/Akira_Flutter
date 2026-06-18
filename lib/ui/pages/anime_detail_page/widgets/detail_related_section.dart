import 'package:flutter/material.dart';
import 'package:akira/models/anime_details.dart';
import 'package:akira/services/anime_service.dart';
import 'package:akira/ui/widgets/glass_container.dart';
import '../anime_detail_page.dart';

class DetailRelatedSection extends StatelessWidget {
  final List<RelatedShow> relatedShows;

  const DetailRelatedSection({super.key, required this.relatedShows});

  @override
  Widget build(BuildContext context) {
    if (relatedShows.isEmpty) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;

    return Column(
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
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: relatedShows.map((show) {
            return _RelatedShowTile(show: show);
          }).toList(),
        ),
      ],
    );
  }
}

class _RelatedShowTile extends StatelessWidget {
  final RelatedShow show;

  const _RelatedShowTile({required this.show});

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

    return FutureBuilder<AnimeDetails?>(
      future: AnimeService().fetchAnimeDetails(show.showId),
      builder: (context, snapshot) {
        final animeDetails = snapshot.data;
        final name = animeDetails?.name ?? 'Loading...';

        return InkWell(
          onTap: animeDetails != null
              ? () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AnimeDetailPage(anime: animeDetails),
                    ),
                  );
                }
              : null,
          child: SizedBox(
            width: (MediaQuery.of(context).size.width - 52) / 2,
            height: 66,
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
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
          ),
        );
      },
    );
  }
}
