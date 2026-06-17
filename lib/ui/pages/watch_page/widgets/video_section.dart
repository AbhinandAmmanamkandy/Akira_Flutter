import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../../../widgets/glass_container.dart';

class VideoSection extends StatelessWidget {
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

    final showResumeButton = resumePosition != null && 
                             resumePosition!.inSeconds > 0 &&
                             onResume != null && 
                             errorMessage == null && 
                             !isLoading && 
                             !isBuffering &&
                             canShowResume;

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: Colors.black,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (isLoading)
              const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Colors.white,
                ),
              )
            else if (errorMessage != null)
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
                        errorMessage!,
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: onRetry,
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
            else if (controller != null)
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
                  seekBarMargin: const EdgeInsets.only(left: 48, right: 48, bottom: 24),
                  bottomButtonBarMargin: const EdgeInsets.only(left: 48, right: 40, bottom: 16),
                  topButtonBarMargin: const EdgeInsets.only(left: 24, right: 24, top: 12),
                  seekOnDoubleTap: true,
                  volumeGesture: true,
                  brightnessGesture: true,
                  topButtonBar: [
                    MaterialCustomButton(
                      onPressed: onBack,
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                    ),
                    const SizedBox(width: 8),
                    if (animeTitle != null)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              animeTitle!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (episodeNumber != null)
                              Text(
                                'Episode $episodeNumber',
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
                      iconSize: 64.0,
                      iconColor: Colors.white,
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
                  seekBarMargin: const EdgeInsets.only(left: 64, right: 64, bottom: 32),
                  bottomButtonBarMargin: const EdgeInsets.only(left: 64, right: 56, bottom: 20),
                  seekOnDoubleTap: true,
                  volumeGesture: true,
                  brightnessGesture: true,
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
                    MaterialPlayOrPauseButton(iconSize: 84.0, iconColor: colorScheme.primary),
                    const Spacer(),
                    const MaterialSkipNextButton(iconSize: 48),
                    const Spacer(flex: 3),
                  ],
                ),
                child: Video(
                  key: videoKey,
                  controller: controller!,
                  controls: MaterialVideoControls,
                ),
              )
            else
              IconButton(
                icon: const Icon(Icons.play_circle_filled, size: 64, color: Colors.white),
                onPressed: onRetry,
              ),

            // Resume Overlay
            if (showResumeButton)
              Positioned(
                bottom: 60,
                right: 24,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutBack,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Opacity(
                        opacity: value.clamp(0.0, 1.0),
                        child: child,
                      ),
                    );
                  },
                  child: GlassContainer(
                    padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                    borderRadius: 32,
                    withBlur: true,
                    blur: 15,
                    opacity: 0.2,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Continue watching?',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'at ${_formatDuration(resumePosition ?? Duration.zero)}',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Material(
                          color: colorScheme.primary,
                          shape: const CircleBorder(),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: onResume,
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          onPressed: onDismissResume,
                          icon: const Icon(Icons.close_rounded, size: 18),
                          visualDensity: VisualDensity.compact,
                          color: Colors.white60,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            if (isBuffering && !isLoading)
              const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Colors.white,
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
