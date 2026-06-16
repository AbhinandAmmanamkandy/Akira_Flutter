import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import 'package:akira/models/anime.dart';
import 'package:akira/models/anime_details.dart';
import 'package:akira/services/anime_stream_service.dart';
import 'package:akira/services/theme_service.dart';
import 'package:akira/theme/akira_colors.dart';
import 'package:akira/gestures/overscroll_dismiss_gesture.dart';
import 'widgets/video_section.dart';
import 'widgets/watch_header.dart';
import 'widgets/episode_controls_header.dart';
import 'widgets/episode_range_selector.dart';
import 'widgets/episode_grid.dart';

class WatchPage extends StatefulWidget {
  final Anime anime;
  final AnimeDetails details;

  const WatchPage({
    super.key,
    required this.anime,
    required this.details,
  });

  @override
  State<WatchPage> createState() => _WatchPageState();
}

class _WatchPageState extends State<WatchPage> {
  late final Player player;
  late final VideoController controller;
  final AllAnimeApi _api = AllAnimeApi();
  final ScrollController _scrollController = ScrollController();

  String? _videoUrl;
  bool _isLoading = true;
  String? _error;
  int _currentEpisode = 1;
  int _selectedRangeIndex = 0;
  bool _isReversed = false;

  @override
  void initState() {
    super.initState();
    player = Player();
    controller = VideoController(player);
    
    // Parse last episode from the details
    final lastEpStr = widget.details.lastEpisode?.replaceAll(RegExp(r'[^0-9]'), '') ?? '1';
    _currentEpisode = int.tryParse(lastEpStr) ?? 1;
    _selectedRangeIndex = (_currentEpisode - 1) ~/ 50;
    
    _loadEpisode(_currentEpisode.toString());
  }

  Future<void> _loadEpisode(String ep) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final url = await _api.getEpisodeVideoUrl(widget.anime.id, ep);
      if (url == null) {
        setState(() {
          _isLoading = false;
          _error = 'No stream found for Episode $ep';
        });
        return;
      }

      setState(() {
        _videoUrl = url;
        _isLoading = false;
      });

      await player.open(Media(url, httpHeaders: {'Referer': 'https://youtu-chan.com'}));
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Error loading episode: $e';
      });
    }
  }

  List<int> _getEpisodesForRange(int rangeIndex) {
    final int total = int.tryParse(widget.details.lastEpisode ?? '0') ?? 0;
    final int start = (rangeIndex * 50) + 1;
    final int end = ((rangeIndex + 1) * 50).clamp(1, total);
    
    List<int> eps = [];
    for (int i = start; i <= end; i++) {
      eps.add(i);
    }
    
    if (_isReversed) {
      return eps.reversed.toList();
    }
    return eps;
  }

  @override
  void dispose() {
    player.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final themeService = ThemeService();

    return ListenableBuilder(
      listenable: themeService,
      builder: (context, _) {
        final isLight = Theme.of(context).brightness == Brightness.light;
        final bgColor = AkiraColors.getBackground(colorScheme, isLight);

        return Scaffold(
          backgroundColor: bgColor,
          body: Stack(
            children: [
              // Background Gradient
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        colorScheme.primary.withValues(alpha: isLight ? 0.05 : 0.1),
                        bgColor,
                      ],
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: OverscrollDismissGesture(
                  child: CustomScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    slivers: [
                      // Video Section
                      SliverToBoxAdapter(
                        child: VideoSection(
                          controller: controller,
                          isLoading: _isLoading,
                          errorMessage: _error,
                          onRetry: () => _loadEpisode(_currentEpisode.toString()),
                          onBack: () => Navigator.pop(context),
                        ),
                      ),

                      // Watch Header
                      SliverToBoxAdapter(
                        child: WatchHeader(
                          title: widget.anime.name,
                          currentEpisode: _currentEpisode,
                        ),
                      ),

                      // Episode Controls
                      SliverToBoxAdapter(
                        child: EpisodeControlsHeader(
                          totalEpisodes: widget.details.lastEpisode,
                          isReversed: _isReversed,
                          onToggleSort: () {
                            setState(() => _isReversed = !_isReversed);
                          },
                          onJumpToEpisode: () {
                            // TODO: Implement jump to episode dialog
                          },
                        ),
                      ),

                      // Range Selector
                      SliverToBoxAdapter(
                        child: EpisodeRangeSelector(
                          totalEpisodes: int.tryParse(widget.details.lastEpisode ?? '0') ?? 0,
                          selectedRangeIndex: _selectedRangeIndex,
                          onRangeSelected: (index) {
                            setState(() => _selectedRangeIndex = index);
                          },
                        ),
                      ),

                      // Episode Grid
                      EpisodeGrid(
                        episodes: _getEpisodesForRange(_selectedRangeIndex),
                        selectedEpisode: _currentEpisode,
                        onEpisodeSelected: (ep) {
                          if (ep != _currentEpisode) {
                            setState(() => _currentEpisode = ep);
                            _loadEpisode(ep.toString());
                          }
                        },
                      ),

                      const SliverToBoxAdapter(child: SizedBox(height: 50)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
