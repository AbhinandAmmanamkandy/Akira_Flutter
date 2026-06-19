import 'dart:async';
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
      final brightness = await ScreenBrightness().application;
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

  void _showSpeedDialog(BuildContext context) {
    final player = widget.controller?.player;
    if (player == null) return;

    final speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
    final currentSpeed = player.state.rate;
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassContainer(
        borderRadius: 28,
        withBlur: true,
        blur: 25,
        opacity: 0.9,
        color: Colors.black.withValues(alpha: 0.8),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Icon(Icons.speed_rounded, color: colorScheme.primary),
                const SizedBox(width: 12),
                const Text(
                  'Playback Speed',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: speeds.map((speed) {
                final isSelected = currentSpeed == speed;
                return Material(
                  color: isSelected ? colorScheme.primary : Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    onTap: () {
                      player.setRate(speed);
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: (MediaQuery.of(context).size.width - 72) / 3,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        '${speed}x',
                        style: TextStyle(
                          color: isSelected ? colorScheme.onPrimary : Colors.white,
                          fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    return formatDuration(duration);
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
              LayoutBuilder(
                builder: (context, constraints) => MaterialVideoControlsTheme(
                normal: MaterialVideoControlsThemeData(
                  visibleOnMount: true,
                  backdropColor: Colors.black.withValues(alpha: 0.4),
                  buttonBarButtonSize: 28.0,
                  buttonBarButtonColor: Colors.white,
                  seekBarPositionColor: colorScheme.primary,
                  seekBarColor: Colors.white.withValues(alpha: 0.2),
                  seekBarBufferColor: Colors.white.withValues(alpha: 0.3),
                  seekBarThumbColor: colorScheme.primary,
                  seekBarHeight: 4.0,
                  seekBarThumbSize: 12.0,
                  seekBarMargin: const EdgeInsets.only(left: 64, right: 104, bottom: 42),
                  bottomButtonBarMargin: const EdgeInsets.only(left: 20, right: 12, bottom: 16),
                  topButtonBarMargin: const EdgeInsets.only(left: 16, right: 16, top: 16),
                  seekOnDoubleTap: true,
                  volumeGesture: true,
                  brightnessGesture: true,
                  initialBrightness: _brightness,
                  onBrightnessChanged: (value) {
                    ScreenBrightness().setApplicationScreenBrightness(value);
                  },
                  onBrightnessReset: () {
                    ScreenBrightness().resetApplicationScreenBrightness();
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
                      opacity: 0.15,
                      blur: 20,
                      color: Colors.black,
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
                              color: colorScheme.primary.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
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
                              Text(
                                'BUFFERING',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2,
                                ),
                              ),
                              Text(
                                'Syncing stream...',
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
                              maxLines: 1,
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
                                  color: colorScheme.primary,
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
                    MaterialCustomButton(
                      onPressed: () => _showSpeedDialog(context),
                      icon: const Icon(Icons.speed_rounded, size: 20, color: Colors.white),
                    ),
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
                      videoWidth: constraints.maxWidth,
                    ),
                    Transform.translate(
                      offset: const Offset(0, -6),
                      child: _PlayerPosition(
                        player: widget.controller!.player,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                    const Spacer(),
                    Transform.translate(
                      offset: const Offset(0, -6),
                      child: _PlayerDuration(
                        player: widget.controller!.player,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                    const MaterialFullscreenButton(),
                  ],
                ),

                fullscreen: MaterialVideoControlsThemeData(
                  seekBarPositionColor: colorScheme.primary,
                  seekBarColor: Colors.white.withValues(alpha: 0.2),
                  seekBarBufferColor: Colors.white.withValues(alpha: 0.3),
                  seekBarThumbColor: colorScheme.primary,
                  seekBarHeight: 6.0,
                  seekBarThumbSize: 14.0,
                  seekBarMargin: const EdgeInsets.only(left: 80, right: 140, bottom: 56),
                  bottomButtonBarMargin: const EdgeInsets.only(left: 32, right: 24, bottom: 24),
                  topButtonBarMargin: const EdgeInsets.only(left: 24, right: 24, top: 24),
                  seekOnDoubleTap: true,
                  volumeGesture: true,
                  brightnessGesture: true,
                  initialBrightness: _brightness,
                  onBrightnessChanged: (value) {
                    ScreenBrightness().setApplicationScreenBrightness(value);
                  },
                  onBrightnessReset: () {
                    ScreenBrightness().resetApplicationScreenBrightness();
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
                      padding: const EdgeInsets.fromLTRB(16, 16, 32, 16),
                      withBlur: true,
                      opacity: 0.15,
                      blur: 25,
                      color: Colors.black,
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.2),
                        width: 1,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: colorScheme.primary,
                                backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'BUFFERING',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2.5,
                                ),
                              ),
                              Text(
                                'Synchronizing data stream...',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontSize: 10,
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
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 16),
                    if (widget.animeTitle != null)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.animeTitle!,
                              maxLines: 1,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (widget.episodeNumber != null)
                              Text(
                                'EPISODE ${widget.episodeNumber}',
                                style: TextStyle(
                                  color: colorScheme.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5,
                                ),
                              ),
                          ],
                        ),
                      )
                    else
                      const Spacer(),
                    MaterialCustomButton(
                      onPressed: () => _showSpeedDialog(context),
                      icon: const Icon(Icons.speed_rounded, size: 24, color: Colors.white),
                    ),
                  ],
                  bottomButtonBar: [
                    _SeekMarkers(
                      player: widget.controller!.player,
                      resumePosition: widget.resumePosition,
                      videoWidth: MediaQuery.of(context).size.width,
                    ),
                    Transform.translate(
                      offset: const Offset(0, -14),
                      child: _PlayerPosition(
                        player: widget.controller!.player,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                    const Spacer(),
                    Transform.translate(
                      offset: const Offset(0, -14),
                      child: _PlayerDuration(
                        player: widget.controller!.player,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                    const MaterialFullscreenButton(),
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
    final bool isLarge = widget.size > 70;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: widget.colorScheme.primary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: widget.colorScheme.primary.withValues(alpha: isLarge ? 0.35 : 0.25),
            blurRadius: isLarge ? 40 : 25,
            spreadRadius: isLarge ? 8 : 4,
          ),
        ],
      ),
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, animation) {
            return ScaleTransition(scale: animation, child: child);
          },
          child: Icon(
            _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            key: ValueKey(_isPlaying),
            size: widget.size * 0.55,
            color: widget.colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }
}

class _SeekMarkers extends StatelessWidget {
  final Player player;
  final Duration? resumePosition;
  final double videoWidth;

  const _SeekMarkers({
    required this.player,
    this.resumePosition,
    required this.videoWidth,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration>(
      stream: player.stream.duration,
      builder: (context, snapshot) {
        final duration = snapshot.data ?? player.state.duration;
        if (duration.inMilliseconds <= 0) return const SizedBox.shrink();

        final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
        
        final seekBarMargin = isLandscape 
            ? const EdgeInsets.only(left: 80, right: 140, bottom: 56)
            : const EdgeInsets.only(left: 64, right: 104, bottom: 42);
        
        final bottomButtonBarMargin = isLandscape
            ? const EdgeInsets.only(left: 32, right: 24, bottom: 24)
            : const EdgeInsets.only(left: 20, right: 12, bottom: 16);

        final availableWidth = (videoWidth - seekBarMargin.horizontal).clamp(0.0, double.infinity);
        final seekBarHeight = isLandscape ? 6.0 : 4.0;
        const buttonBarHeight = 44.0;
        final dy = (seekBarMargin.bottom - bottomButtonBarMargin.bottom) + (seekBarHeight / 2) - (buttonBarHeight / 2);

        return SizedBox(
          width: 0,
          height: 0,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              if (resumePosition != null)
                Positioned(
                  left: seekBarMargin.left - bottomButtonBarMargin.left + (availableWidth * (resumePosition!.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0)) - 1,
                  bottom: dy - (isLandscape ? 6 : 4), 
                  child: Container(
                    width: 2,
                    height: isLandscape ? 12 : 8,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 2,
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
  }
}

String formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final minutes = twoDigits(duration.inMinutes.remainder(60));
  final seconds = twoDigits(duration.inSeconds.remainder(60));
  final hours = duration.inHours > 0 ? '${duration.inHours}:' : '';
  return '$hours$minutes:$seconds';
}

class _PlayerPosition extends StatelessWidget {
  final Player player;
  final TextStyle style;
  const _PlayerPosition({required this.player, required this.style});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration>(
      stream: player.stream.position,
      builder: (context, snapshot) {
        final position = snapshot.data ?? player.state.position;
        return Text(formatDuration(position), style: style);
      },
    );
  }
}

class _PlayerDuration extends StatelessWidget {
  final Player player;
  final TextStyle style;
  const _PlayerDuration({required this.player, required this.style});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration>(
      stream: player.stream.duration,
      builder: (context, snapshot) {
        final duration = snapshot.data ?? player.state.duration;
        return Text(formatDuration(duration), style: style);
      },
    );
  }
}
