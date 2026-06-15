import 'package:flutter/material.dart';
import '../../widgets/glass_container.dart';
import '../../../services/theme_service.dart';

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
    final colorScheme = Theme.of(context).colorScheme;
    final useGlass = ThemeService().useGlassTheme;

    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: GlassContainer(
            borderRadius: 32,
            opacity: 0.05,
            withBlur: useGlass,
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline_rounded, size: 64, color: colorScheme.error),
                const SizedBox(height: 24),
                Text(
                  'Something went wrong',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Try Again'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                )
              ],
            ),
          ),
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
    final colorScheme = Theme.of(context).colorScheme;
    final useGlass = ThemeService().useGlassTheme;

    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: GlassContainer(
            borderRadius: 32,
            opacity: 0.05,
            withBlur: useGlass,
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSearching ? Icons.search_off_rounded : Icons.movie_filter_rounded,
                  size: 64,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  isSearching ? 'No results found' : 'Nothing to show',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  isSearching 
                      ? 'We couldn\'t find any anime matching your search.' 
                      : 'It looks like there\'s no content available right now.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
                if (isSearching) ...[
                  const SizedBox(height: 32),
                  FilledButton.tonal(
                    onPressed: onClearSearch,
                    child: const Text('Clear Search'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
