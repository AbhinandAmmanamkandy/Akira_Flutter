import 'package:flutter/material.dart';
import '../../../models/anime.dart';
import 'anime_card.dart';

class AnimeGrid extends StatelessWidget {
  final List<Anime> animeList;

  const AnimeGrid({super.key, required this.animeList});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.6,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => AnimeCard(anime: animeList[index]),
          childCount: animeList.length,
        ),
      ),
    );
  }
}
