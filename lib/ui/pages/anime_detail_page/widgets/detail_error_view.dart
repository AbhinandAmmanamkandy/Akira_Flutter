import 'package:flutter/material.dart';
import 'package:akira/services/anime_service.dart';

class DetailErrorView extends StatelessWidget {
  final Object? error;
  final VoidCallback onRetry;

  const DetailErrorView({
    super.key,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isNoInternet = error is NoInternetException;

    return SizedBox(
      height: 300,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isNoInternet ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
              size: 48,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              isNoInternet ? 'No Internet Connection' : 'Failed to load details',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (isNoInternet) ...[
              const SizedBox(height: 8),
              const Text(
                'Please check your connection and try again',
                style: TextStyle(fontSize: 12),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton.tonalIcon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
