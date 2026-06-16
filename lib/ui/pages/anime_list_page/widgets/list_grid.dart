import 'package:flutter/material.dart';
import '../../../../models/anime.dart';
import 'list_card.dart';

class ListGrid extends StatelessWidget {
  final List<Anime> animeList;
  final Function(Anime)? onAnimeTap;

  const ListGrid({super.key, required this.animeList, this.onAnimeTap});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Calculate columns based on width, minimum 2 columns
    final crossAxisCount = (screenWidth / 180).floor().clamp(2, 6);

    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: 0.7,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
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
