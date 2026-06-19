import 'package:flutter/material.dart';
import 'package:akira/models/anime.dart';
import 'package:akira/services/favorite_service.dart';
import 'package:akira/services/theme_service.dart';
import 'package:akira/theme/akira_colors.dart';
import 'package:akira/ui/pages/anime_list_page/widgets/list_grid.dart';
import 'package:akira/ui/widgets/glass_container.dart';
import 'package:akira/gestures/overscroll_dismiss_gesture.dart';

class BookmarksPage extends StatefulWidget {
  const BookmarksPage({super.key});

  @override
  State<BookmarksPage> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([ThemeService(), FavoriteService()]),
      builder: (context, _) {
        final allFavorites = FavoriteService().favorites;
        final animeFavorites = allFavorites.where((a) => !a.isManga).toList();
        final mangaFavorites = allFavorites.where((a) => a.isManga).toList();
        
        final useGlass = ThemeService().useGlassTheme;
        final colorScheme = Theme.of(context).colorScheme;

        return Scaffold(
          body: GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: Container(
              decoration: BoxDecoration(
                color: AkiraColors.getBackground(
                  colorScheme,
                  Theme.of(context).brightness == Brightness.light,
                ),
              ),
              child: OverscrollDismissGesture(
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
                    CustomScrollView(
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
                          foregroundColor: colorScheme.onSurface,
                          elevation: 0,
                          iconTheme: IconThemeData(
                            color: colorScheme.onSurface,
                          ),
                          flexibleSpace: useGlass
                              ? const GlassContainer(
                                  borderRadius: 0,
                                  withBlur: true,
                                  opacity: 0.05,
                                  child: FlexibleSpaceBar(),
                                )
                              : null,
                          title: Text(
                            'Senpai\'s Picks',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          centerTitle: true,
                          bottom: TabBar(
                            controller: _tabController,
                            indicatorColor: colorScheme.primary,
                            labelColor: colorScheme.primary,
                            unselectedLabelColor: colorScheme.onSurfaceVariant,
                            indicatorSize: TabBarIndicatorSize.label,
                            tabs: const [
                              Tab(text: 'ANIME'),
                              Tab(text: 'MANGA'),
                            ],
                          ),
                        ),
                        SliverFillRemaining(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildFavoritesList(context, animeFavorites, false),
                              _buildFavoritesList(context, mangaFavorites, true),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFavoritesList(BuildContext context, List<Anime> favorites, bool isManga) {
    if (favorites.isEmpty) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: GlassContainer(
                borderRadius: 32,
                opacity: 0.05,
                blur: 20,
                withBlur: ThemeService().useGlassTheme,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 48,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      size: 84,
                      color: Theme.of(context).colorScheme.primary.withValues(
                        alpha: 0.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'NO ${isManga ? 'MANGA' : 'ANIME'} BOOKMARKED',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Start adding your favorite ${isManga ? 'manga' : 'anime'} to build a collection worthy of Senpai\'s attention!',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: [
        ListGrid(animeList: favorites, isManga: isManga),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}
