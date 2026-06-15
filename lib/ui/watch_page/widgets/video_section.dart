import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';

class VideoSection extends StatelessWidget {
  final VideoController? controller;
  final bool isLoading;
  final bool isBuffering;
  final String? errorMessage;
  final VoidCallback onRetry;
  final VoidCallback onBack;
  final Duration? resumePosition;
  final VoidCallback? onResume;

  const VideoSection({
    super.key,
    required this.controller,
    required this.isLoading,
    this.isBuffering = false,
    this.errorMessage,
    required this.onRetry,
    required this.onBack,
    this.resumePosition,
    this.onResume,
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

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: Colors.black,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (isLoading)
              const CircularProgressIndicator(color: Colors.white)
            else if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      errorMessage!,
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton.tonal(
                      onPressed: onRetry,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            else if (controller != null)
              Video(controller: controller!)
            else
              IconButton(
                icon: const Icon(Icons.play_circle_filled, size: 64, color: Colors.white),
                onPressed: onRetry,
              ),

            // Resume Button Overlay
            if (resumePosition != null && onResume != null && errorMessage == null)
              Positioned(
                bottom: 20, // Moved up slightly from bottom
                child: AnimatedScale(
                  scale: isLoading ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: FilledButton.icon(
                    onPressed: isBuffering ? null : onResume,
                    icon: isBuffering 
                        ? const SizedBox(
                            width: 16, 
                            height: 16, 
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                          )
                        : const Icon(Icons.fast_forward_rounded, size: 18),
                    label: Text(
                      isBuffering 
                          ? 'Buffering...' 
                          : 'Continue from ${_formatDuration(resumePosition!)}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.black.withValues(alpha: 0.8),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.black45,
                      disabledForegroundColor: Colors.white60,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isBuffering ? Colors.white24 : colorScheme.primary,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            Positioned(
              top: 8,
              left: 8,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: onBack,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
