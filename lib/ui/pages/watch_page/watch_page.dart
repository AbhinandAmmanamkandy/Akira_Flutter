import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import 'package:akira/models/anime.dart';
import 'package:akira/models/anime_details.dart';
import 'package:akira/services/anime_stream_service.dart';
import 'package:akira/services/theme_service.dart';
import 'package:akira/services/history_service.dart';
import 'package:akira/services/favorite_service.dart';
import 'package:akira/ui/widgets/glass_container.dart';
import 'package:akira/ui/widgets/custom_status_indicator.dart';
import 'package:akira/ui/widgets/sliver_app_bar_delegate.dart';
import 'package:akira/theme/akira_colors.dart';
import 'package:akira/gestures/overscroll_dismiss_gesture.dart';
import 'package:akira/gestures/f_symbol_gesture.dart';
import 'widgets/video_section.dart';
import 'widgets/watch_header.dart';
import 'widgets/episode_controls_header.dart';
import 'widgets/episode_range_selector.dart';
import 'widgets/episode_grid.dart';
import 'widgets/info_tab.dart';
import 'widgets/quick_jump_sheet.dart';

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

class _WatchPageState extends State<WatchPage> with SingleTickerProviderStateMixin {
  late final Player player;
  late final VideoController controller;
  late final TabController _tabController;
  final AllAnimeApi _api = AllAnimeApi();
  final FavoriteService _favoriteService = FavoriteService();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<VideoState> _videoKey = GlobalKey<VideoState>();
  StreamSubscription? _posSubscription;

  bool _isLoading = true;
  String? _error;
  int _currentEpisode = 1;
  int _selectedRangeIndex = 0;
  bool _isReversed = false;
  Duration? _resumePosition;
  bool _isBuffering = false;
  bool _playedOneSecond = false;

  @override
  void initState() {
    super.initState();
    player = Player();
    controller = VideoController(player);
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    
    // Initialize history service
    HistoryService().init().then((_) {
      final history = HistoryService().getHistory(widget.anime.id);
      if (history != null) {
        setState(() {
          _currentEpisode = history.episode;
          _resumePosition = history.position;
          _selectedRangeIndex = (_currentEpisode - 1) ~/ 25;
        });
      } else {
        setState(() {
          _currentEpisode = 1;
          _selectedRangeIndex = 0;
        });
      }
      _loadEpisode(_currentEpisode.toString(), initial: true);
    });

    player.stream.buffering.listen((buffering) {
      if (mounted) setState(() => _isBuffering = buffering);
    });

    _posSubscription = player.stream.position.listen((pos) {
      if (mounted) {
        if (!_playedOneSecond && pos.inSeconds >= 1) {
          setState(() => _playedOneSecond = true);
        }
        if (player.state.playing) {
          HistoryService().saveHistory(widget.anime.id, _currentEpisode, pos);
        }
      }
    });
  }

  Future<void> _loadEpisode(String ep, {bool initial = false}) async {
    final epInt = int.tryParse(ep) ?? 1;
    setState(() {
      _currentEpisode = epInt;
      _selectedRangeIndex = (epInt - 1) ~/ 25;
      _isLoading = true;
      _error = null;
      _playedOneSecond = false;
      if (!initial) {
        _resumePosition = null;
      }
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
        _isLoading = false;
      });

      await player.open(Media(url, httpHeaders: {'Referer': 'https://youtu-chan.com'}), play: true);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Error loading episode: $e';
      });
    }
  }

  void _showJumpToEpisodeSheet() {
    final total = int.tryParse(widget.details.lastEpisode ?? '0') ?? 0;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => QuickJumpSheet(
        totalEpisodes: total,
        onEpisodeSelected: (ep) => _loadEpisode(ep.toString()),
      ),
    );
  }

  List<int> _getEpisodesForRange(int rangeIndex) {
    final int total = int.tryParse(widget.details.lastEpisode ?? '0') ?? 0;
    final int start = (rangeIndex * 25) + 1;
    final int end = ((rangeIndex + 1) * 25).clamp(1, total);
    
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
    _posSubscription?.cancel();
    player.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final themeService = ThemeService();

    return ListenableBuilder(
      listenable: Listenable.merge([themeService, _favoriteService]),
      builder: (context, _) {
        final isLight = Theme.of(context).brightness == Brightness.light;
        final bgColor = AkiraColors.getBackground(colorScheme, isLight);
        final isFavorite = _favoriteService.isFavorite(widget.anime.id);

        return FSymbolGesture(
          onSymbolDetected: () {
            _favoriteService.toggleFavorite(widget.anime);
            CustomStatusIndicator.show(
              context,
              isFavorite ? 'Removed from favorites' : 'Added to favorites',
              isFavorite ? Icons.favorite_border_rounded : Icons.favorite_rounded,
            );
          },
          child: Scaffold(
            backgroundColor: bgColor,
            body: Stack(
            children: [
              // Background Image with Blur
              Positioned.fill(
                child: Opacity(
                  opacity: isLight ? 0.2 : 0.4,
                  child: Image.network(
                    widget.details.thumbnail ?? widget.anime.thumbnail ?? '',
                    fit: BoxFit.cover,
                    headers: const {'Referer': 'https://youtu-chan.com'},
                    errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                  ),
                ),
              ),
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                  child: Container(
                    color: bgColor.withValues(alpha: isLight ? 0.7 : 0.8),
                  ),
                ),
              ),

              SafeArea(
                child: OverscrollDismissGesture(
                  onDismiss: () => _videoKey.currentState?.toggleFullscreen(),
                  child: CustomScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    slivers: [
                      // Video Section
                      SliverToBoxAdapter(
                        child: VideoSection(
                          videoKey: _videoKey,
                          controller: controller,
                          isLoading: _isLoading,
                          isBuffering: _isBuffering,
                          errorMessage: _error,
                          onRetry: () => _loadEpisode(_currentEpisode.toString()),
                          onBack: () => Navigator.pop(context),
                          resumePosition: _resumePosition,
                          canShowResume: _playedOneSecond,
                          onResume: () {
                            if (_resumePosition != null) {
                              player.seek(_resumePosition!);
                              setState(() => _resumePosition = null);
                            }
                          },
                          onDismissResume: () {
                            setState(() => _resumePosition = null);
                          },
                          animeTitle: widget.anime.name,
                          episodeNumber: _currentEpisode,
                        ),
                      ),

                      // Watch Header
                      SliverToBoxAdapter(
                        child: WatchHeader(
                          anime: widget.anime,
                          currentEpisode: _currentEpisode,
                        ),
                      ),

                      const SliverToBoxAdapter(child: SizedBox(height: 16)),

                      // Sticky TabBar
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: SliverAppBarDelegate(
                          child: TabBar(
                            controller: _tabController,
                            indicatorColor: colorScheme.primary,
                            indicatorWeight: 3,
                            indicatorSize: TabBarIndicatorSize.label,
                            labelColor: colorScheme.primary,
                            unselectedLabelColor: colorScheme.onSurfaceVariant,
                            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            tabs: const [
                              Tab(text: 'Episodes'),
                              Tab(text: 'Information'),
                            ],
                          ),
                          backgroundColor: bgColor,
                        ),
                      ),

                      // Tab Content
                      if (_tabController.index == 0) ...[
                        // Episode Controls
                        SliverToBoxAdapter(
                          child: EpisodeControlsHeader(
                          totalEpisodes: widget.details.lastEpisode,
                          isReversed: _isReversed,
                          onToggleSort: () {
                            setState(() => _isReversed = !_isReversed);
                          },
                          onJumpToEpisode: _showJumpToEpisodeSheet,
                        ),
                        ),

                        const SliverToBoxAdapter(child: SizedBox(height: 8)),

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
                      ] else ...[
                        InfoTab(details: widget.details),
                      ],

                      const SliverToBoxAdapter(child: SizedBox(height: 50)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        );
      },
    );
  }
}
