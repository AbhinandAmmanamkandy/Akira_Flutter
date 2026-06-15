import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../models/anime.dart';
import '../../models/anime_details.dart';
import '../../services/anime_stream_service.dart';
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
  int _selectedRangeIndex = 0;
  bool _isReversed = false;
  Player? _player;
  VideoController? _controller;
  bool _isLoadingVideo = false;
  String? _videoError;

  @override
  void initState() {
    super.initState();
    _createPlayerIfNeeded();
    _loadVideo();
  }

  void _createPlayerIfNeeded() {
    if (_player == null) {
      _player = Player();
      _controller = VideoController(_player!);
    }
  }

  Future<void> _loadVideo() async {
    if (widget.anime.id.isEmpty) return;

    _createPlayerIfNeeded();

    setState(() {
      _isLoadingVideo = true;
      _videoError = null;
    });

    try {
      final videoUrl = await AllAnimeApi().getEpisodeVideoUrl(widget.anime.id, _selectedEpisode.toString());

      if (videoUrl == null) {
        throw Exception('No playable video URL found for this episode.');
      }

      await _player!.open(
        Media(
          videoUrl,
          httpHeaders: const {
            'Referer': 'https://allanime.day/',
            'User-Agent': 'Mozilla/5.0',
          },
        ),
      );
    } catch (e) {
      _videoError = e.toString();
      debugPrint('WatchPage: video load error: $_videoError');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingVideo = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _player?.dispose();
    super.dispose();
  }

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
                    if (_isLoadingVideo)
                      const CircularProgressIndicator(color: Colors.white)
                    else if (_videoError != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          _videoError!,
                          style: const TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      )
                    else if (_controller != null)
                      Video(controller: _controller!)
                    else
                      IconButton(
                        icon: const Icon(Icons.play_circle_filled, size: 64, color: Colors.white),
                        onPressed: _loadVideo,
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
                        children: [
                          Text(
                            'Episodes',
                            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: Icon(_isReversed ? Icons.arrow_upward : Icons.arrow_downward, size: 20),
                            onPressed: () => setState(() => _isReversed = !_isReversed),
                            tooltip: 'Reverse Order',
                          ),
                          IconButton(
                            icon: const Icon(Icons.bolt_rounded, size: 24),
                            onPressed: () => _showJumpToEpisodeDialog(context, _parseLastEpisode(widget.anime.lastEpisode)),
                            tooltip: 'Jump to Episode',
                          ),
                          Text(
                            widget.anime.lastEpisode != null ? '${widget.anime.lastEpisode} Total' : '',
                            style: textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 8),

                    // Range Selector
                    _buildRangeSelector(context, _parseLastEpisode(widget.anime.lastEpisode)),

                    const SizedBox(height: 12),

                    // Episode List
                    Expanded(
                      child: _buildEpisodeList(_parseLastEpisode(widget.anime.lastEpisode)),
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

  Widget _buildRangeSelector(BuildContext context, int totalEpisodes) {
    if (totalEpisodes <= 50) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final int chunks = (totalEpisodes / 50).ceil();

    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: chunks,
        itemBuilder: (context, index) {
          final start = (index * 50) + 1;
          final end = ((index + 1) * 50).clamp(1, totalEpisodes);
          final isSelected = _selectedRangeIndex == index;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text('$start - $end'),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) setState(() => _selectedRangeIndex = index);
              },
              showCheckmark: false,
              selectedColor: colorScheme.primary,
              labelStyle: TextStyle(
                color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(
                color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEpisodeList(int totalEpisodes) {
    final startEpisode = (_selectedRangeIndex * 50) + 1;
    final endEpisode = ((_selectedRangeIndex + 1) * 50).clamp(1, totalEpisodes);
    
    final List<int> episodes = [];
    for (int i = startEpisode; i <= endEpisode; i++) {
      episodes.add(i);
    }
    
    if (_isReversed) {
      episodes.sort((a, b) => b.compareTo(a));
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: episodes.length,
      itemBuilder: (context, index) {
        final episodeNum = episodes[index];
        return EpisodeCard(
          episodeNum: episodeNum,
          isSelected: _selectedEpisode == episodeNum,
          onTap: () {
            setState(() => _selectedEpisode = episodeNum);
            _loadVideo();
          },
        );
      },
    );
  }

  int _parseLastEpisode(String? lastEpisode) {
    if (lastEpisode == null) return 12; // Default fallback
    return int.tryParse(lastEpisode) ?? 12;
  }

  void _showJumpToEpisodeDialog(BuildContext context, int total) {
    final controller = TextEditingController();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 12,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(Icons.bolt_rounded, color: colorScheme.onPrimaryContainer),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Jump to Episode',
                          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Select 1 - $total',
                          style: textTheme.bodySmall?.copyWith(color: colorScheme.outline),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                autofocus: true,
                textAlign: TextAlign.center,
                style: textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
                decoration: InputDecoration(
                  hintText: '000',
                  hintStyle: TextStyle(color: colorScheme.outlineVariant),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: colorScheme.outlineVariant, width: 2),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: colorScheme.primary, width: 3),
                  ),
                ),
                onSubmitted: (value) {
                  final ep = int.tryParse(value);
                  if (ep != null && ep >= 1 && ep <= total) {
                    setState(() {
                      _selectedEpisode = ep;
                      _selectedRangeIndex = (ep - 1) ~/ 50;
                    });
                    _loadVideo();
                    Navigator.pop(context);
                  }
                },
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        final ep = int.tryParse(controller.text);
                        if (ep != null && ep >= 1 && ep <= total) {
                          setState(() {
                            _selectedEpisode = ep;
                            _selectedRangeIndex = (ep - 1) ~/ 50;
                          });
                          _loadVideo();
                          Navigator.pop(context);
                        }
                      },
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: const Text('Let\'s Go'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
