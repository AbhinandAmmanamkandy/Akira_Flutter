import 'package:flutter/material.dart';
import '../../services/favorite_service.dart';
import '../../services/theme_service.dart';
import '../anime_list_page/widgets/list_grid.dart';
import '../widgets/glass_container.dart';
import '../widgets/overscroll_pop_handler.dart';

class BookmarksPage extends StatelessWidget {
  const BookmarksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        ThemeService(),
        FavoriteService(),
      ]),
      builder: (context, _) {
        final favorites = FavoriteService().favorites;
        final useGlass = ThemeService().useGlassTheme;
        final colorScheme = Theme.of(context).colorScheme;

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  colorScheme.surface,
                ],
              ),
            ),
            child: Stack(
              children: [
                if (useGlass) ...[
                  Positioned(
                    top: 100,
                    right: -50,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScheme.primary.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 100,
                    left: -50,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScheme.secondary.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                ],
                OverscrollPopHandler(
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    slivers: [
                      SliverAppBar(
                        floating: true,
                        pinned: true,
                        backgroundColor: useGlass
                            ? Colors.transparent
                            : colorScheme.surface.withValues(alpha: 0.8),
                        surfaceTintColor: Colors.transparent,
                        flexibleSpace: useGlass
                            ? const GlassContainer(
                                borderRadius: 0,
                                withBlur: true,
                                opacity: 0.05,
                                child: FlexibleSpaceBar(),
                              )
                            : null,
                        title: const Text(
                          'My Bookmarks',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        centerTitle: true,
                      ),
                      if (favorites.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: GlassContainer(
                                borderRadius: 32,
                                opacity: 0.05,
                                blur: 20,
                                withBlur: useGlass,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 48,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '404',
                                      style: TextStyle(
                                        fontSize: 84,
                                        fontWeight: FontWeight.w900,
                                        color: colorScheme.primary.withValues(alpha: 0.5),
                                        letterSpacing: -5,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'PAGE NOT FOUND',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 4,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 32),
                                    Text(
                                      'YOUR BOOKMARKS ARE MISSING',
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'It seems you haven\'t added any anime to your collection yet. Let\'s fix that!',
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                            height: 1.5,
                                          ),
                                    ),
                                    const SizedBox(height: 40),
                                    FilledButton.icon(
                                      onPressed: () => Navigator.pop(context),
                                      icon: const Icon(Icons.explore_rounded),
                                      label: const Text('BACK TO HOME'),
                                      style: FilledButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 32,
                                          vertical: 18,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      else
                        ListGrid(animeList: favorites),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
