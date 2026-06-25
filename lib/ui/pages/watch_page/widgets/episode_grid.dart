import 'package:flutter/material.dart';
import 'episode_card.dart';

class EpisodeGrid extends StatelessWidget {
  final String animeId;
  final List<int> episodes;
  final int selectedEpisode;
  final Function(int) onEpisodeSelected;

  const EpisodeGrid({
    super.key,
    required this.animeId,
    required this.episodes,
    required this.selectedEpisode,
    required this.onEpisodeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final episodeNum = episodes[index];
            return EpisodeCard(
              animeId: animeId,
              episodeNum: episodeNum,
              isSelected: selectedEpisode == episodeNum,
              onTap: () => onEpisodeSelected(episodeNum),
            );
          },
          childCount: episodes.length,
        ),
      ),
    );
  }
}
