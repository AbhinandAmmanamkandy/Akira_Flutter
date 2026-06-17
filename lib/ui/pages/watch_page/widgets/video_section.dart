import 'package:flutter/material.dart';
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

class _VideoSectionState extends State<VideoSection> {
  double _brightness = 0.5;
  double _volume = 0.5;

  @override
  void initState() {
    super.initState();
    _loadInitialValues();
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

    final showResumeButton = widget.resumePosition != null && 
                             widget.resumePosition!.inSeconds > 0 &&
                             widget.onResume != null && 
                             widget.errorMessage == null && 
                             !widget.isLoading && 
                             !widget.isBuffering &&
                             widget.canShowResume;

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: Colors.black,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (widget.isLoading)
              const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Colors.white,
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
                  backdropColor: Colors.black.withValues(alpha: 0.45),
                  buttonBarButtonSize: 24.0,
                  buttonBarButtonColor: Colors.white,
                  seekBarPositionColor: colorScheme.primary,
                  seekBarThumbColor: colorScheme.primary,
                  seekBarHeight: 4.0,
                  seekBarThumbSize: 14.0,
                  seekBarMargin: const EdgeInsets.only(left: 20, right: 20, bottom: 24),
                  bottomButtonBarMargin: const EdgeInsets.only(left: 20, right: 12, bottom: 16),
                  topButtonBarMargin: const EdgeInsets.only(left: 12, right: 12, top: 12),
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
                  topButtonBar: [
                    MaterialCustomButton(
                      onPressed: widget.onBack,
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                    ),
                    const SizedBox(width: 8),
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
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (widget.episodeNumber != null)
                              Text(
                                'Episode ${widget.episodeNumber}',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
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
                    const MaterialSkipPreviousButton(iconSize: 32),
                    const Spacer(),
                    MaterialPlayOrPauseButton(
                      iconSize: 52.0,
                      iconColor: colorScheme.primary,
                    ),
                    const Spacer(),
                    const MaterialSkipNextButton(iconSize: 32),
                    const Spacer(flex: 3),
                  ],
                  bottomButtonBar: [
                    const MaterialPositionIndicator(
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
                fullscreen: MaterialVideoControlsThemeData(
                  seekBarPositionColor: colorScheme.primary,
                  seekBarThumbColor: colorScheme.primary,
                  seekBarHeight: 4.5,
                  seekBarThumbSize: 16.0,
                  seekBarMargin: const EdgeInsets.only(left: 32, right: 32, bottom: 32),
                  bottomButtonBarMargin: const EdgeInsets.only(left: 32, right: 24, bottom: 20),
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
                  topButtonBar: [
                    const Spacer(),
                    const MaterialFullscreenButton(),
                  ],
                  bottomButtonBar: [
                    const MaterialPositionIndicator(
                      style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                  ],
                  primaryButtonBar: [
                    const Spacer(flex: 3),
                    const MaterialSkipPreviousButton(iconSize: 48),
                    const Spacer(),
                    MaterialPlayOrPauseButton(iconSize: 72.0, iconColor: colorScheme.primary),
                    const Spacer(),
                    const MaterialSkipNextButton(iconSize: 48),
                    const Spacer(flex: 3),
                  ],
                ),
                child: Video(
                  key: widget.videoKey,
                  controller: widget.controller!,
                  controls: (state) => Stack(
                    children: [
                      MaterialVideoControls(state),
                      Positioned.fill(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return Row(
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
                            );
                          },
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
                          color: AkiraColors.getResumeAccentColor(colorScheme),
                          borderRadius: BorderRadius.circular(10),
                          child: InkWell(
                            onTap: widget.onResume,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              child: Text(
                                'Resume',
                                style: TextStyle(
                                  color: AkiraColors.getResumeOnAccentColor(colorScheme),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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
