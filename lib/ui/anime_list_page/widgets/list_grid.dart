import 'package:flutter/material.dart';
import '../../../models/anime.dart';
import 'list_card.dart';

class ListGrid extends StatelessWidget {
  final List<Anime> animeList;

  const ListGrid({super.key, required this.animeList});

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
          (context, index) => ListCard(anime: animeList[index]),
          childCount: animeList.length,
        ),
      ),
    );
  }
}
