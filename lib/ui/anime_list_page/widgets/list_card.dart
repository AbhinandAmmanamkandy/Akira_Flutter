import 'package:flutter/material.dart';
import '../../../models/anime.dart';
import '../../anime_detail_page/anime_detail_page.dart';

class ListCard extends StatelessWidget {
  final Anime anime;

  const ListCard({super.key, required this.anime});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                AnimeDetailPage(anime: anime),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 300),
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
                  if (anime.lastEpisode != null && anime.lastEpisode!.isNotEmpty)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .secondaryContainer
                              .withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          'EP ${anime.lastEpisode}',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSecondaryContainer,
                              ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                (anime.englishName != null && anime.englishName!.isNotEmpty)
                    ? anime.englishName!
                    : anime.name,
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
