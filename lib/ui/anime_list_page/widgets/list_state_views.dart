import 'package:flutter/material.dart';

class ListErrorView extends StatelessWidget {
  final Object? error;
  final VoidCallback onRetry;

  const ListErrorView({
    super.key,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $error'),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            )
          ],
        ),
      ),
    );
  }
}

class ListEmptyView extends StatelessWidget {
  final bool isSearching;
  final VoidCallback onClearSearch;

  const ListEmptyView({
    super.key,
    required this.isSearching,
    required this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No anime found.'),
            if (isSearching)
              TextButton(
                onPressed: onClearSearch,
                child: const Text('Clear Search'),
              ),
          ],
        ),
      ),
    );
  }
}
