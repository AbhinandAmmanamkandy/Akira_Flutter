import 'package:flutter/material.dart';
import '../../../../models/anime.dart';
import '../../anime_detail_page/anime_detail_page.dart';
import '../../../../theme/akira_colors.dart';
import '../../../widgets/common_chip.dart';
import 'list_card_thumbnail.dart';

class ListCard extends StatelessWidget {
  final Anime anime;
  final VoidCallback? onTap;
  final bool isManga;

  const ListCard({
    super.key,
    required this.anime,
    this.onTap,
    this.isManga = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () {
        FocusScope.of(context).unfocus();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnimeDetailPage(anime: anime, isManga: isManga),
          ),
        );
      },
      child: AspectRatio(
        aspectRatio: 0.7,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AkiraColors.getShadowColor(Theme.of(context).colorScheme),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                Positioned.fill(
                  child: ListCardThumbnail(
                    imageUrl: anime.thumbnail,
                    heroTag: 'anime_${anime.id}',
                  ),
                ),
                // Gradient for text readability
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.6, 1.0],
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.8),
                        ],
                      ),
                    ),
                  ),
                ),
                if (anime.lastEpisode != null && anime.lastEpisode!.isNotEmpty)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: CommonChip(
                      label: '${isManga ? 'CH' : 'EP'} ${anime.lastEpisode}',
                    ),
                  ),
                Positioned(
                  bottom: 12,
                  left: 12,
                  right: 12,
                  child: Text(
                    (anime.englishName != null && anime.englishName!.isNotEmpty)
                        ? anime.englishName!
                        : anime.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: -0.3,
                      height: 1.1,
                      shadows: [
                        Shadow(
                          color: Colors.black,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
