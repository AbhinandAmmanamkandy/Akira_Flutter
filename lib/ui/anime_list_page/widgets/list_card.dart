import 'package:flutter/material.dart';
import '../../../models/anime.dart';
import '../../anime_detail_page/anime_detail_page.dart';
import 'list_card_badge.dart';
import 'list_card_thumbnail.dart';

class ListCard extends StatelessWidget {
  final Anime anime;
  final VoidCallback? onTap;

  const ListCard({super.key, required this.anime, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () {
        FocusScope.of(context).unfocus();
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
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ListCardThumbnail(
                      imageUrl: anime.thumbnail,
                      heroTag: 'anime_${anime.id}',
                    ),
                  ),
                  if (anime.lastEpisode != null && anime.lastEpisode!.isNotEmpty)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: ListCardBadge(text: 'EP ${anime.lastEpisode}'),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text(
                (anime.englishName != null && anime.englishName!.isNotEmpty)
                    ? anime.englishName!
                    : anime.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      letterSpacing: -0.3,
                      height: 1.1,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
