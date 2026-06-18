import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';
import '../../../widgets/glass_container.dart';
import 'package:akira/theme/akira_colors.dart';

class VideoSection extends StatefulWidget {
  final VideoController? controller;
  final GlobalKey<VideoState>? videoKey;
  final bool isLoading;
  final bool isBuffering;
  final String? errorMessage;
  final VoidCallback onRetry;
  final VoidCallback onBack;
  final Duration? resumePosition;
  final bool canShowResume;
  final VoidCallback? onResume;
  final VoidCallback? onDismissResume;
  final String? animeTitle;
  final int? episodeNumber;

  const VideoSection({
    super.key,
    this.videoKey,
    required this.controller,
    required this.isLoading,
    this.isBuffering = false,
    this.errorMessage,
    required this.onRetry,
    required this.onBack,
    this.resumePosition,
    this.canShowResume = false,
    this.onResume,
    this.onDismissResume,
    this.animeTitle,
    this.episodeNumber,
  });

  @override
  State<VideoSection> createState() => _VideoSectionState();
}

class _VideoSectionState extends State<VideoSection> with SingleTickerProviderStateMixin {
  double _brightness = 0.5;
  double _volume = 0.5;
  late AnimationController _resumeTimerController;
  bool _resumeTimerStarted = false;

  bool get _shouldShowResume => widget.resumePosition != null && 
                                widget.resumePosition!.inSeconds > 0 &&
                                widget.onResume != null && 
                                widget.errorMessage == null && 
                                !widget.isLoading && 
                                !widget.isBuffering &&
                                widget.canShowResume;

  @override
  void initState() {
    super.initState();
    _loadInitialValues();
    _resumeTimerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onDismissResume?.call();
        }
      });

    if (_shouldShowResume) {
      _resumeTimerStarted = true;
      _resumeTimerController.forward();
    }
  }

  @override
  void dispose() {
    _resumeTimerController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(VideoSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (_shouldShowResume && !_resumeTimerStarted) {
      _resumeTimerStarted = true;
      _resumeTimerController.forward(from: 0.0);
    } else if (!_shouldShowResume && _resumeTimerStarted) {
      _resumeTimerStarted = false;
      _resumeTimerController.stop();
    }
  }

  Future<void> _loadInitialValues() async {
    try {
      final brightness = await ScreenBrightness().current;
      final volume = await FlutterVolumeController.getVolume();
      await FlutterVolumeController.updateShowSystemUI(false);
      if (mounted) {
        setState(() {
          _brightness = brightness;
          _volume = volume ?? 0.5;
        });
      }
    } catch (_) {}
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    final hours = duration.inHours > 0 ? '${duration.inHours}:' : '';
    return '$hours$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final showResumeButton = _shouldShowResume;

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: Colors.black,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (widget.isLoading)
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          strokeWidth: 4,
                          color: colorScheme.primary,
                          backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'PREPARING STREAM',
                      style: TextStyle(
                        color: colorScheme.primary.withValues(alpha: 0.8),
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              )
            else if (widget.errorMessage != null)
              Center(
                child: GlassContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                  borderRadius: 24,
                  opacity: 0.1,
                  withBlur: true,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline_rounded, color: colorScheme.error, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        widget.errorMessage!,
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: widget.onRetry,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Try Again'),
                        style: FilledButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (widget.controller != null)
              MaterialVideoControlsTheme(
                normal: MaterialVideoControlsThemeData(
                  visibleOnMount: true,
                  backdropColor: Colors.black.withValues(alpha: 0.5),
                  buttonBarButtonSize: 28.0,
                  buttonBarButtonColor: Colors.white,
                  seekBarPositionColor: colorScheme.primary,
                  seekBarThumbColor: Colors.transparent,
                  seekBarHeight: 4.0,
                  seekBarThumbSize: 0.0,
                  seekBarMargin: const EdgeInsets.only(left: 20, right: 20, bottom: 28),
                  bottomButtonBarMargin: const EdgeInsets.only(left: 20, right: 12, bottom: 16),
                  topButtonBarMargin: const EdgeInsets.only(left: 16, right: 16, top: 16),
                  seekOnDoubleTap: true,
                  volumeGesture: true,
                  brightnessGesture: true,
                  initialBrightness: _brightness,
                  onBrightnessChanged: (value) {
                    ScreenBrightness().setScreenBrightness(value);
                  },
                  onBrightnessReset: () {
                    ScreenBrightness().resetScreenBrightness();
                  },
                  initialVolume: _volume,
                  onVolumeChanged: (value) {
                    try {
                      FlutterVolumeController.setVolume(value);
                    } catch (_) {}
                    widget.controller?.player.setVolume(value * 100);
                  },
                  bufferingIndicatorBuilder: (context) => Center(
                    child: GlassContainer(
                      borderRadius: 100,
                      padding: const EdgeInsets.fromLTRB(12, 12, 24, 12),
                      withBlur: true,
                      opacity: 0.2,
                      blur: 20,
                      color: Colors.black.withValues(alpha: 0.5),
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.2),
                        width: 1,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: colorScheme.primary,
                                backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'BUFFERING',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2,
                                ),
                              ),
                              Text(
                                'Please wait...',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  topButtonBar: [
                    MaterialCustomButton(
                      onPressed: widget.onBack,
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (widget.animeTitle != null)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.animeTitle!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (widget.episodeNumber != null)
                              Text(
                                'EPISODE ${widget.episodeNumber}',
                                style: TextStyle(
                                  color: colorScheme.primary.withValues(alpha: 0.9),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.2,
                                ),
                              ),
                          ],
                        ),
                      )
                    else
                      const Spacer(),
                    const MaterialFullscreenButton(),
                  ],
                  primaryButtonBar: [
                    const Spacer(flex: 3),
                    MaterialCustomButton(
                      onPressed: () {
                        final current = widget.controller?.player.state.position ?? Duration.zero;
                        widget.controller?.player.seek(current - const Duration(seconds: 10));
                      },
                      icon: const Icon(Icons.replay_10_rounded, size: 32, color: Colors.white),
                    ),
                    const Spacer(),
                    MaterialCustomButton(
                      onPressed: () => widget.controller?.player.playOrPause(),
                      icon: _ThemedPlayPauseButton(
                        player: widget.controller?.player,
                        colorScheme: colorScheme,
                        size: 64,
                      ),
                    ),
                    const Spacer(),
                    MaterialCustomButton(
                      onPressed: () {
                        final current = widget.controller?.player.state.position ?? Duration.zero;
                        widget.controller?.player.seek(current + const Duration(seconds: 10));
                      },
                      icon: const Icon(Icons.forward_10_rounded, size: 32, color: Colors.white),
                    ),
                    const Spacer(flex: 3),
                  ],
                  bottomButtonBar: [
                    _SeekMarkers(
                      player: widget.controller!.player,
                      resumePosition: widget.resumePosition,
                    ),
                    const SizedBox(width: 20),
                    const MaterialPositionIndicator(
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
                fullscreen: MaterialVideoControlsThemeData(
                  seekBarPositionColor: colorScheme.primary,
                  seekBarThumbColor: Colors.transparent,
                  seekBarHeight: 5.0,
                  seekBarThumbSize: 0.0,
                  seekBarMargin: const EdgeInsets.only(left: 32, right: 32, bottom: 40),
                  bottomButtonBarMargin: const EdgeInsets.only(left: 32, right: 24, bottom: 24),
                  topButtonBarMargin: const EdgeInsets.only(left: 24, right: 24, top: 24),
                  seekOnDoubleTap: true,
                  volumeGesture: true,
                  brightnessGesture: true,
                  initialBrightness: _brightness,
                  onBrightnessChanged: (value) {
                    ScreenBrightness().setScreenBrightness(value);
                  },
                  onBrightnessReset: () {
                    ScreenBrightness().resetScreenBrightness();
                  },
                  initialVolume: _volume,
                  onVolumeChanged: (value) {
                    try {
                      FlutterVolumeController.setVolume(value);
                    } catch (_) {}
                    widget.controller?.player.setVolume(value * 100);
                  },
                  bufferingIndicatorBuilder: (context) => Center(
                    child: GlassContainer(
                      borderRadius: 100,
                      padding: const EdgeInsets.fromLTRB(12, 12, 24, 12),
                      withBlur: true,
                      opacity: 0.2,
                      blur: 20,
                      color: Colors.black.withValues(alpha: 0.5),
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.2),
                        width: 1,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: colorScheme.primary,
                                backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'BUFFERING',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2,
                                ),
                              ),
                              Text(
                                'Please wait...',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  topButtonBar: [
                    const Spacer(),
                    const MaterialFullscreenButton(),
                  ],
                  bottomButtonBar: [
                    _SeekMarkers(
                      player: widget.controller!.player,
                      resumePosition: widget.resumePosition,
                    ),
                    const SizedBox(width: 20),
                    const MaterialPositionIndicator(
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                    const Spacer(),
                  ],
                  primaryButtonBar: [
                    const Spacer(flex: 3),
                    MaterialCustomButton(
                      onPressed: () {
                        final current = widget.controller?.player.state.position ?? Duration.zero;
                        widget.controller?.player.seek(current - const Duration(seconds: 10));
                      },
                      icon: const Icon(Icons.replay_10_rounded, size: 48, color: Colors.white),
                    ),
                    const Spacer(),
                    MaterialCustomButton(
                      onPressed: () => widget.controller?.player.playOrPause(),
                      icon: _ThemedPlayPauseButton(
                        player: widget.controller?.player,
                        colorScheme: colorScheme,
                        size: 88,
                      ),
                    ),
                    const Spacer(),
                    MaterialCustomButton(
                      onPressed: () {
                        final current = widget.controller?.player.state.position ?? Duration.zero;
                        widget.controller?.player.seek(current + const Duration(seconds: 10));
                      },
                      icon: const Icon(Icons.forward_10_rounded, size: 48, color: Colors.white),
                    ),
                    const Spacer(flex: 3),
                  ],
                ),
                child: Video(
                  key: widget.videoKey,
                  controller: widget.controller!,
                  controls: (state) => Stack(
                    children: [
                      MaterialVideoControls(state),
                      // Vertical Drag for Fullscreen Toggle
                      Positioned.fill(
                        child: Row(
                          children: [
                            const Spacer(flex: 3),
                            Expanded(
                              flex: 4,
                              child: GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onVerticalDragEnd: (details) {
                                  if (details.primaryVelocity != null &&
                                      details.primaryVelocity!.abs() > 300) {
                                    state.toggleFullscreen();
                                  }
                                },
                              ),
                            ),
                            const Spacer(flex: 3),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              IconButton(
                icon: const Icon(Icons.play_circle_filled, size: 64, color: Colors.white),
                onPressed: widget.onRetry,
              ),

            // Resume Overlay
            if (showResumeButton)
              Positioned(
                bottom: 60,
                right: 20,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: Opacity(
                        opacity: value.clamp(0.0, 1.0),
                        child: child,
                      ),
                    );
                  },
                  child: GlassContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    borderRadius: 20,
                    withBlur: true,
                    blur: 25,
                    opacity: 0.2,
                    color: Colors.black.withValues(alpha: 0.4),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                      width: 1,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Left Accent Icon
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AkiraColors.getResumeAccentColor(colorScheme).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.history_toggle_off_rounded,
                            color: AkiraColors.getResumeAccentColor(colorScheme),
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Text Info
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Resume Playback?',
                              style: AkiraColors.getResumeTitleStyle(colorScheme),
                            ),
                            Text(
                              'at ${_formatDuration(widget.resumePosition ?? Duration.zero)}',
                              style: AkiraColors.getResumeSubstyle(colorScheme),
                            ),
                          ],
                        ),
                        const SizedBox(width: 20),
                        // Action Button
                        Material(
                          color: AkiraColors.getResumeAccentColor(colorScheme).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: widget.onResume,
                            child: AnimatedBuilder(
                              animation: _resumeTimerController,
                              builder: (context, child) {
                                return Stack(
                                  children: [
                                    Positioned.fill(
                                      child: FractionallySizedBox(
                                        alignment: Alignment.centerLeft,
                                        widthFactor: _resumeTimerController.value,
                                        child: Container(
                                          color: AkiraColors.getResumeAccentColor(colorScheme),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      child: Text(
                                        'Resume',
                                        style: TextStyle(
                                          color: AkiraColors.getResumeOnAccentColor(colorScheme),
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        // Dismiss Icon
                        IconButton(
                          onPressed: widget.onDismissResume,
                          icon: const Icon(Icons.close_rounded, size: 16),
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(),
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

          ],
        ),
      ),
    );
  }
}

class _ThemedPlayPauseButton extends StatefulWidget {
  final Player? player;
  final ColorScheme colorScheme;
  final double size;

  const _ThemedPlayPauseButton({
    required this.player,
    required this.colorScheme,
    required this.size,
  });

  @override
  State<_ThemedPlayPauseButton> createState() => _ThemedPlayPauseButtonState();
}

class _ThemedPlayPauseButtonState extends State<_ThemedPlayPauseButton> {
  late bool _isPlaying;
  StreamSubscription? _playingSub;
  StreamSubscription? _bufferingSub;

  @override
  void initState() {
    super.initState();
    _isPlaying = widget.player?.state.playing ?? false;
    _initSubscriptions();
  }

  void _initSubscriptions() {
    _playingSub?.cancel();
    _bufferingSub?.cancel();

    _playingSub = widget.player?.stream.playing.listen((playing) {
      if (mounted && _isPlaying != playing) {
        setState(() => _isPlaying = playing);
      }
    });

    // Force refresh playing state when buffering ends
    _bufferingSub = widget.player?.stream.buffering.listen((buffering) {
      if (mounted && !buffering) {
        final currentPlaying = widget.player?.state.playing ?? false;
        if (_isPlaying != currentPlaying) {
          setState(() => _isPlaying = currentPlaying);
        }
      }
    });
  }

  @override
  void didUpdateWidget(_ThemedPlayPauseButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.player != oldWidget.player) {
      _isPlaying = widget.player?.state.playing ?? false;
      _initSubscriptions();
    }
  }

  @override
  void dispose() {
    _playingSub?.cancel();
    _bufferingSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: widget.colorScheme.primary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: widget.colorScheme.primary.withValues(alpha: widget.size > 70 ? 0.4 : 0.3),
            blurRadius: widget.size > 70 ? 30 : 20,
            spreadRadius: widget.size > 70 ? 5 : 2,
          ),
        ],
      ),
      child: Icon(
        _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
        size: widget.size * 0.6,
        color: widget.colorScheme.onPrimary,
      ),
    );
  }
}

class _SeekMarkers extends StatelessWidget {
  final Player player;
  final Duration? resumePosition;

  const _SeekMarkers({
    required this.player,
    this.resumePosition,
  });

  @override
  Widget build(BuildContext context) {
    final videoState = VideoStateInheritedWidget.of(context).state;
    final isFullscreen = videoState.isFullscreen();
    final colorScheme = Theme.of(context).colorScheme;

    return StreamBuilder<Duration>(
      stream: player.stream.duration,
      builder: (context, snapshot) {
        final duration = snapshot.data ?? player.state.duration;
        if (duration.inMilliseconds <= 0) return const SizedBox.shrink();

        return LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = MediaQuery.of(context).size.width;

            // Media-kit default seek bar values
            final seekBarMargin = isFullscreen 
                ? const EdgeInsets.only(left: 32, right: 32, bottom: 40)
                : const EdgeInsets.only(left: 20, right: 20, bottom: 28);
            
            // Button bar margin
            final barLeft = isFullscreen ? 32.0 : 20.0;
            final barBottom = isFullscreen ? 24.0 : 16.0;

            final seekBarHeight = isFullscreen ? 5.0 : 4.0;
            final availableWidth = screenWidth - seekBarMargin.horizontal;

            // Horizontal distance from button bar left to seek bar left
            final dx = seekBarMargin.left - barLeft;

            // Derived Math Equation for Universal Alignment:
            // The markers are hosted in the button bar which has a standard height (usually 56px).
            // We calculate the distance from the center of that bar to the center of the seekbar.
            const buttonBarHeight = 56.0;
            final dy = (seekBarMargin.bottom - barBottom) + (seekBarHeight / 2) - (buttonBarHeight / 2);

            return SizedBox(
              width: 0,
              height: 0,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: dx,
                    bottom: dy,
                    child: SizedBox(
                      width: availableWidth,
                      height: 0,
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.centerLeft,
                        children: [
                          // Resume Position Marker (2px)
                          if (resumePosition != null)
                            Builder(builder: (context) {
                              final ratio = (resumePosition!.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);
                              return Positioned(
                                left: availableWidth * ratio - 1,
                                bottom: -4,
                                child: Container(
                                  width: 2,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(1),
                                  ),
                                ),
                              );
                            }),
                          // Current Position Marker (4px)
                          StreamBuilder<Duration>(
                            stream: player.stream.position,
                            builder: (context, snapshot) {
                              final position = snapshot.data ?? player.state.position;
                              final ratio = (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);
                              return Positioned(
                                left: availableWidth * ratio - 2,
                                bottom: -10,
                                child: Container(
                                  width: 4,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary,
                                    borderRadius: BorderRadius.circular(2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.3),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _ResumeButton extends StatelessWidget {
  final String label;
  final bool isPrimary;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  const _ResumeButton({
    required this.label,
    required this.isPrimary,
    required this.colorScheme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isPrimary ? colorScheme.primary : Colors.white.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          child: Text(
            label,
            style: TextStyle(
              color: isPrimary ? colorScheme.onPrimary : Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
