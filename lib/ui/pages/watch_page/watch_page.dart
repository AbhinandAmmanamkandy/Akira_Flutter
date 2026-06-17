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
import 'package:akira/ui/widgets/glass_container.dart';
import 'package:akira/theme/akira_colors.dart';
import 'package:akira/gestures/overscroll_dismiss_gesture.dart';
import 'widgets/video_section.dart';
import 'widgets/watch_header.dart';
import 'widgets/episode_controls_header.dart';
import 'widgets/episode_range_selector.dart';
import 'widgets/episode_grid.dart';
import 'widgets/info_tab.dart';

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
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<VideoState> _videoKey = GlobalKey<VideoState>();
  StreamSubscription? _posSubscription;

  String? _videoUrl;
  bool _isLoading = true;
  String? _error;
  int _currentEpisode = 1;
  int _selectedRangeIndex = 0;
  bool _isReversed = false;
  Duration? _resumePosition;

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

    _posSubscription = player.stream.position.listen((pos) {
      if (player.state.playing) {
        HistoryService().saveHistory(widget.anime.id, _currentEpisode, pos);
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

  void _showJumpToEpisodeSheet() {
    final total = int.tryParse(widget.details.lastEpisode ?? '0') ?? 0;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: GlassContainer(
          borderRadius: 28,
          withBlur: true,
          blur: 25,
          opacity: isLight ? 0.85 : 0.45,
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.bolt_rounded, color: colorScheme.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Quick Jump',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.onSurface.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '1 - $total',
                      style: textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                autofocus: true,
                textAlign: TextAlign.center,
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: colorScheme.primary,
                  letterSpacing: 2,
                ),
                decoration: InputDecoration(
                  hintText: '---',
                  hintStyle: TextStyle(
                    color: colorScheme.primary.withValues(alpha: 0.15),
                    letterSpacing: 2,
                  ),
                  filled: true,
                  fillColor: colorScheme.primary.withValues(alpha: 0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 20),
                  prefixIcon: const SizedBox(width: 48), // Balancing the suffix icon space
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: IconButton.filledTonal(
                      onPressed: () {
                        final ep = int.tryParse(controller.text);
                        if (ep != null && ep > 0 && ep <= total) {
                          Navigator.pop(context);
                          _loadEpisode(ep.toString());
                        }
                      },
                      icon: const Icon(Icons.arrow_forward_rounded),
                    ),
                  ),
                ),
                onSubmitted: (value) {
                  final ep = int.tryParse(value);
                  if (ep != null && ep > 0 && ep <= total) {
                    Navigator.pop(context);
                    _loadEpisode(ep.toString());
                  }
                },
              ),
            ],
          ),
        ),
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
      listenable: themeService,
      builder: (context, _) {
        final isLight = Theme.of(context).brightness == Brightness.light;
        final bgColor = AkiraColors.getBackground(colorScheme, isLight);

        return Scaffold(
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
                          errorMessage: _error,
                          onRetry: () => _loadEpisode(_currentEpisode.toString()),
                          onBack: () => Navigator.pop(context),
                          resumePosition: _resumePosition,
                          onResume: () {
                            if (_resumePosition != null) {
                              player.seek(_resumePosition!);
                              setState(() => _resumePosition = null);
                            }
                          },
                          onDismissResume: () {
                            setState(() => _resumePosition = null);
                          },
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
                        delegate: _SliverAppBarDelegate(
                          TabBar(
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
                          bgColor,
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
        );
      },
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar, this.backgroundColor);

  final TabBar _tabBar;
  final Color backgroundColor;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: backgroundColor.withValues(alpha: overlapsContent ? 1.0 : 0.0),
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
