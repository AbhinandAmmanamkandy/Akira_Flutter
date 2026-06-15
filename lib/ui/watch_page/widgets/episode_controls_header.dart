import 'package:flutter/material.dart';

class EpisodeControlsHeader extends StatelessWidget {
  final String? totalEpisodes;
  final bool isReversed;
  final VoidCallback onToggleSort;
  final VoidCallback onJumpToEpisode;

  const EpisodeControlsHeader({
    super.key,
    this.totalEpisodes,
    required this.isReversed,
    required this.onToggleSort,
    required this.onJumpToEpisode,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Text(
            'Episodes',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(isReversed ? Icons.arrow_upward : Icons.arrow_downward, size: 20),
            onPressed: onToggleSort,
            tooltip: 'Reverse Order',
          ),
          IconButton(
            icon: const Icon(Icons.bolt_rounded, size: 24),
            onPressed: onJumpToEpisode,
            tooltip: 'Jump to Episode',
          ),
          if (totalEpisodes != null)
            Text(
              '$totalEpisodes Total',
              style: textTheme.bodySmall,
            ),
        ],
      ),
    );
  }
}
