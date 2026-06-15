import 'dart:async';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../models/anime.dart';
import '../../models/anime_details.dart';
import '../../services/anime_stream_service.dart';
import '../../services/theme_service.dart';
import '../../services/history_service.dart';
import '../widgets/glass_container.dart';
import 'widgets/video_section.dart';
import 'widgets/watch_header.dart';
import 'widgets/episode_controls_header.dart';
import 'widgets/episode_range_selector.dart';
import 'widgets/episode_grid.dart';

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
  bool _isFirstLoad = true;
  bool _isSeekingToHistory = false;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _bufferingSubscription;
  Duration? _historyToResume;
  bool _showResumeOverlay = false;
  bool _isBuffering = false;

  @override
  void initState() {
    super.initState();
    _loadInitialHistory();
    _createPlayerIfNeeded();
    _loadVideo();
  }

  void _loadInitialHistory() {
    final history = HistoryService().getHistory(widget.anime.id);
    if (history != null) {
      _selectedEpisode = history.episode;
      _selectedRangeIndex = (history.episode - 1) ~/ 50;
    }
  }

  void _createPlayerIfNeeded() {
    if (_player == null) {
      _player = Player();
      _controller = VideoController(_player!);

      // Listen to position updates to save history
      _positionSubscription = _player!.stream.position.listen((position) {
        // ONLY save if: 
        // 1. We are playing
        // 2. We are NOT currently in the middle of a resume-seek operation
        // 3. The position is significantly far enough (to avoid initial 0:00 resets)
        if (_player!.state.playing && !_isSeekingToHistory && position.inSeconds > 2) {
          HistoryService().saveHistory(
            widget.anime.id,
            _selectedEpisode,
            position,
          );
        }
      });

      _bufferingSubscription = _player!.stream.buffering.listen((buffering) {
        if (mounted) {
          setState(() {
            _isBuffering = buffering;
          });
        }
      });
    }
  }

  Future<void> _loadVideo() async {
    if (widget.anime.id.isEmpty) return;

    _createPlayerIfNeeded();

    setState(() {
      _isLoadingVideo = true;
      _videoError = null;
      _isBuffering = true; // Mark as buffering initially
    });

    try {
      final videoUrl = await AllAnimeApi().getEpisodeVideoUrl(widget.anime.id, _selectedEpisode.toString());

      if (videoUrl == null) {
        throw Exception('No playable video URL found for this episode.');
      }

      // Check history
      final history = HistoryService().getHistory(widget.anime.id);
      final bool hasHistory = history != null && history.episode == _selectedEpisode && history.position.inSeconds > 2;
      
      debugPrint('WatchPage: History check - Has history: $hasHistory, Position: ${history?.position}');

      setState(() {
        _historyToResume = hasHistory ? history.position : null;
        _showResumeOverlay = hasHistory;
      });

      // Open Media
      await _player!.open(
        Media(
          videoUrl, 
          httpHeaders: {
            'Referer': 'https://allanime.day/', 
            'User-Agent': 'Mozilla/5.0'
          },
        ),
        play: true,
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
    // Save history on close
    if (_player != null) {
      HistoryService().saveHistory(
        widget.anime.id,
        _selectedEpisode,
        _player!.state.position,
      );
    }
    _positionSubscription?.cancel();
    _bufferingSubscription?.cancel();
    _player?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeService(),
      builder: (context, _) {
        final colorScheme = Theme.of(context).colorScheme;
        final useGlass = ThemeService().useGlassTheme;
        final totalEpisodes = _parseLastEpisode(widget.anime.lastEpisode);

        return Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Stack(
              children: [
                if (useGlass) ...[
                  Positioned(
                    top: 200,
                    right: -50,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScheme.primary.withValues(alpha: 0.15),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 100,
                    left: -50,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScheme.secondary.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                ],
                Column(
                  children: [
                    VideoSection(
                      controller: _controller,
                      isLoading: _isLoadingVideo,
                      isBuffering: _isBuffering,
                      errorMessage: _videoError,
                      onRetry: _loadVideo,
                      onBack: () => Navigator.pop(context),
                      resumePosition: _showResumeOverlay ? _historyToResume : null,
                      onResume: () async {
                        if (_historyToResume != null && !_isBuffering) {
                          setState(() => _showResumeOverlay = false);
                          await _player!.seek(_historyToResume!);
                        }
                      },
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: useGlass
                              ? colorScheme.surface.withValues(alpha: 0.05)
                              : colorScheme.surface,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            WatchHeader(
                              title: widget.anime.englishName ?? widget.anime.name,
                              currentEpisode: _selectedEpisode,
                            ),
                            const SizedBox(height: 24),
                            EpisodeControlsHeader(
                              totalEpisodes: widget.anime.lastEpisode,
                              isReversed: _isReversed,
                              onToggleSort: () => setState(() => _isReversed = !_isReversed),
                              onJumpToEpisode: () => _showJumpToEpisodeDialog(context, totalEpisodes),
                            ),
                            const SizedBox(height: 8),
                            EpisodeRangeSelector(
                              totalEpisodes: totalEpisodes,
                              selectedRangeIndex: _selectedRangeIndex,
                              onRangeSelected: (index) => setState(() => _selectedRangeIndex = index),
                            ),
                            const SizedBox(height: 12),
                            Expanded(
                              child: EpisodeGrid(
                                episodes: _getEpisodesForRange(totalEpisodes),
                                selectedEpisode: _selectedEpisode,
                                onEpisodeSelected: (ep) {
                                  setState(() => _selectedEpisode = ep);
                                  _loadVideo();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<int> _getEpisodesForRange(int totalEpisodes) {
    final startEpisode = (_selectedRangeIndex * 50) + 1;
    final endEpisode = ((_selectedRangeIndex + 1) * 50).clamp(1, totalEpisodes);
    
    final List<int> episodes = [];
    for (int i = startEpisode; i <= endEpisode; i++) {
      episodes.add(i);
    }
    
    if (_isReversed) {
      episodes.sort((a, b) => b.compareTo(a));
    }
    return episodes;
  }

  int _parseLastEpisode(String? lastEpisode) {
    if (lastEpisode == null) return 12;
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
        child: GlassContainer(
          borderRadius: 32,
          withBlur: true,
          opacity: 0.1,
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
                    GlassContainer(
                      borderRadius: 16,
                      padding: const EdgeInsets.all(12),
                      opacity: 0.1,
                      child: Icon(Icons.bolt_rounded, color: colorScheme.primary),
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
                      child: ThemeService().useGlassTheme
                          ? GlassContainer(
                              borderRadius: 16,
                              opacity: 0.1,
                              child: InkWell(
                                onTap: () {
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
                                borderRadius: BorderRadius.circular(16),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  child: Center(
                                    child: Text(
                                      'Let\'s Go',
                                      style: TextStyle(
                                        color: colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : FilledButton(
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
      ),
    );
  }
}
