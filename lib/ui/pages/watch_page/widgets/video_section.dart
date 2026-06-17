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
  final VoidCallback? onResume;
  final VoidCallback? onDismissResume;

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
    this.onResume,
    this.onDismissResume,
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
                             onResume != null && 
                             errorMessage == null && 
                             !isLoading && 
                             !isBuffering;

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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
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
              )
            else if (controller != null)
              MaterialVideoControlsTheme(
                normal: MaterialVideoControlsThemeData(
                  visibleOnMount: true,
                  backdropColor: Colors.black.withValues(alpha: 0.4),
                  buttonBarButtonSize: 24.0,
                  buttonBarButtonColor: Colors.white,
                  seekBarPositionColor: colorScheme.primary,
                  seekBarThumbColor: colorScheme.primary,
                  seekBarHeight: 3.5,
                  seekBarThumbSize: 14.0,
                  seekBarMargin: const EdgeInsets.only(left: 48, right: 48, bottom: 20),
                  bottomButtonBarMargin: const EdgeInsets.only(left: 48, right: 40, bottom: 12),
                  topButtonBarMargin: const EdgeInsets.only(left: 40, right: 40, top: 8),
                  seekOnDoubleTap: true,
                  volumeGesture: true,
                  brightnessGesture: true,
                  topButtonBar: [
                    MaterialCustomButton(
                      onPressed: onBack,
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    ),
                    const Spacer(),
                    const MaterialFullscreenButton(),
                  ],
                  primaryButtonBar: [
                    const Spacer(flex: 3),
                    const MaterialSkipPreviousButton(iconSize: 36),
                    const Spacer(),
                    MaterialPlayOrPauseButton(iconSize: 72.0, iconColor: colorScheme.primary),
                    const Spacer(),
                    const MaterialSkipNextButton(iconSize: 36),
                    const Spacer(flex: 3),
                  ],
                  bottomButtonBar: [
                    const MaterialPositionIndicator(
                      style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
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
            Positioned(
              bottom: 100,
              child: AnimatedScale(
                scale: showResumeButton ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                child: AnimatedOpacity(
                  opacity: showResumeButton ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Continue where you left off at ${_formatDuration(resumePosition ?? Duration.zero)}?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _ResumeButton(
                              label: 'Yes',
                              isPrimary: true,
                              colorScheme: colorScheme,
                              onTap: onResume ?? () {},
                            ),
                            const SizedBox(width: 8),
                            _ResumeButton(
                              label: 'No',
                              isPrimary: false,
                              colorScheme: colorScheme,
                              onTap: onDismissResume ?? () {},
                            ),
                          ],
                        ),
                      ],
                    ),
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
