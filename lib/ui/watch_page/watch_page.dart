import 'package:flutter/material.dart';
import '../../models/anime.dart';
import '../../models/anime_details.dart';
import 'widgets/episode_card.dart';

class WatchPage extends StatefulWidget {
  final Anime anime;
  final AnimeDetails? details;

  const WatchPage({
    super.key,
    required this.anime,
    this.details,
  });

  @override
  State<WatchPage> createState() => _WatchPageState();
}

class _WatchPageState extends State<WatchPage> {
  int _selectedEpisode = 1;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Video Player Placeholder
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                color: Colors.grey[900],
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.play_circle_filled, size: 64, color: Colors.white),
                      onPressed: () {},
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.anime.englishName ?? widget.anime.name,
                            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Episode $_selectedEpisode',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    
                    // Episodes Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Episodes',
                            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            widget.anime.lastEpisode != null ? '${widget.anime.lastEpisode} Episodes' : '',
                            style: textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 12),

                    // Episode List
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        itemCount: _parseLastEpisode(widget.anime.lastEpisode),
                        itemBuilder: (context, index) {
                          final episodeNum = index + 1;
                          return EpisodeCard(
                            episodeNum: episodeNum,
                            isSelected: _selectedEpisode == episodeNum,
                            onTap: () {
                              setState(() {
                                _selectedEpisode = episodeNum;
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _parseLastEpisode(String? lastEpisode) {
    if (lastEpisode == null) return 12; // Default fallback
    return int.tryParse(lastEpisode) ?? 12;
  }
}
