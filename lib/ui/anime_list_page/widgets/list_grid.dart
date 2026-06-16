import 'package:flutter/material.dart';
import '../../../models/anime.dart';
import 'list_card.dart';

class ListGrid extends StatelessWidget {
  final List<Anime> animeList;
  final Function(Anime)? onAnimeTap;

  const ListGrid({super.key, required this.animeList, this.onAnimeTap});

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
          (context, index) {
            final anime = animeList[index];
            return ListCard(
              anime: anime,
              onTap: onAnimeTap != null ? () => onAnimeTap!(anime) : null,
            );
          },
          childCount: animeList.length,
        ),
      ),
    );
  }
}
