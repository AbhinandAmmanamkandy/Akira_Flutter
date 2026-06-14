import 'package:flutter/material.dart';
import '../models/anime.dart';

class AnimeDetailHeader extends StatelessWidget {
  final Anime anime;

  const AnimeDetailHeader({super.key, required this.anime});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300.0,
      pinned: true,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.black.withValues(alpha: 0.3),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          (anime.englishName != null && anime.englishName!.isNotEmpty)
              ? anime.englishName!
              : anime.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            shadows: [Shadow(color: Colors.black, blurRadius: 10)],
          ),
        ),
        titlePadding: const EdgeInsetsDirectional.only(start: 56.0, bottom: 16.0, end: 16.0),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: 'anime_${anime.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.zero,
                child: anime.thumbnail != null
                    ? Image.network(anime.thumbnail!, fit: BoxFit.cover)
                    : Container(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        child: const Icon(Icons.movie, size: 100),
                      ),
              ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black87],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
