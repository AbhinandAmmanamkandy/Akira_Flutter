import 'package:flutter/material.dart';
import '../../settings_page/settings_page.dart';
import '../../bookmarks_page/bookmarks_page.dart';
import '../../../services/theme_service.dart';
import '../../widgets/glass_container.dart';

class ListAppBar extends StatelessWidget {
  final double appBarOpacity;

  const ListAppBar({super.key, required this.appBarOpacity});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final useGlass = ThemeService().useGlassTheme;
    final currentRadius = 32.0 * (1.0 - appBarOpacity);

    final appBarColor = Color.lerp(colorScheme.surfaceContainerHighest, Colors.black, 0.03)!;

    return SliverAppBar(
      expandedHeight: 170.0,
      pinned: true,
      stretch: true,
      backgroundColor: useGlass 
          ? appBarColor.withValues(alpha: (appBarOpacity * 0.9).clamp(0, 0.9)) 
          : appBarColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(currentRadius),
        ),
        side: BorderSide(
          color: colorScheme.onSurface.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      automaticallyImplyLeading: false,
      toolbarHeight: 70,
      centerTitle: false,
      title: AnimatedOpacity(
        opacity: appBarOpacity > 0.8 ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: useGlass ? BoxDecoration(
            color: colorScheme.onSurface.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ) : null,
          child: Text(
            'AKIRA',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: ClipRRect(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(currentRadius),
          ),
          child: GlassContainer(
            borderRadius: 0,
            opacity: useGlass ? 0.4 : 1.0,
            color: appBarColor,
            blur: 15,
            withBlur: useGlass,
            border: const Border(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(30, 0, 24, 24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              'AKIRA',
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w900,
                                fontSize: 42,
                                height: 1.0,
                                letterSpacing: -2.0,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'HUB',
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'YOUR ULTIMATE ANIME DESTINATION',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        useGlass
                            ? GlassContainer(
                                borderRadius: 16,
                                opacity: 0.1,
                                border: Border.all(
                                  color: colorScheme.primary.withValues(alpha: 0.5),
                                  width: 1.5,
                                ),
                                child: IconButton(
                                  tooltip: 'Senpai\'s Picks',
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const BookmarksPage()),
                                    );
                                  },
                                  icon: Icon(
                                    Icons.bookmark_rounded,
                                    size: 24,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              )
                            : IconButton(
                                tooltip: 'Senpai\'s Picks',
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const BookmarksPage()),
                                  );
                                },
                                style: IconButton.styleFrom(
                                  backgroundColor: colorScheme
                                      .surfaceContainerHighest
                                      .withValues(alpha: 0.3),
                                  padding: const EdgeInsets.all(12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  side: BorderSide(
                                    color: colorScheme.primary.withValues(alpha: 0.5),
                                    width: 1.5,
                                  ),
                                ),
                                icon: Icon(
                                  Icons.bookmark_rounded,
                                  size: 24,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                        const SizedBox(width: 8),
                        useGlass
                            ? GlassContainer(
                                borderRadius: 16,
                                opacity: 0.1,
                                border: Border.all(
                                  color: colorScheme.primary.withValues(alpha: 0.5),
                                  width: 1.5,
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    FocusScope.of(context).unfocus();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const SettingsPage()),
                                    );
                                  },
                                  icon: Icon(
                                    Icons.settings_rounded,
                                    size: 24,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              )
                            : IconButton(
                                onPressed: () {
                                  FocusScope.of(context).unfocus();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const SettingsPage()),
                                  );
                                },
                                style: IconButton.styleFrom(
                                  backgroundColor: colorScheme
                                      .surfaceContainerHighest
                                      .withValues(alpha: 0.3),
                                  padding: const EdgeInsets.all(12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  side: BorderSide(
                                    color: colorScheme.primary.withValues(alpha: 0.5),
                                    width: 1.5,
                                  ),
                                ),
                                icon: Icon(
                                  Icons.settings_rounded,
                                  size: 24,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                      ],
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
}
