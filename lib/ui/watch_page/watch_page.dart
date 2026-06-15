import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../models/EpisodeSource.dart';
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
  final AllAnimeApi _animeStreamService = AllAnimeApi();
  int _selectedEpisode = 1;
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
      var videoUrl = "https://test-videos.co.uk/vids/bigbuckbunny/mp4/h264/1080/Big_Buck_Bunny_1080_10s_1MB.mp44";

      videoUrl = 'https://tools.fast4speed.rsvp/media9/videos/Gcou36nB8su3KWXrr/sub/1_1775983352880?Authorization=3_20260614122223_4ffa0a7b5636c163db749135_03785ff46dd0c873f7ec236bd81d84c8b9bf99f6_000_20260617122223_0055_dnld, decodedUrl=https://tools.fast4speed.rsvp/media9/videos/Gcou36nB8su3KWXrr/sub/1_1775983352880?Authorization';

      videoUrl = 'https://tools.fast4speed.rsvp/media9/videos/Gcou36nB8su3KWXrr/sub/1_1775983352880?Authorization=3_20260614122223_4ffa0a7b5636c163db749135_03785ff46dd0c873f7ec236bd81d84c8b9bf99f6_000_20260617122223_0055_dnld';

      // videoUrl = 'https://tools.fast4speed.rsvp/media9/videos/Gcou36nB8su3KWXrr/sub/1_1775983352880?Authorization';


      if (videoUrl == null) {
        throw Exception('No playable video URL found for this episode.');
      }

      debugPrint('WatchPage: opening media URL in player');
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
                              _loadVideo();
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
