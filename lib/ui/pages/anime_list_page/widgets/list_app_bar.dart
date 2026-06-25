import 'package:flutter/material.dart';
import 'package:akira/ui/pages/settings_page/settings_page.dart';
import 'package:akira/ui/pages/bookmarks_page/bookmarks_page.dart';
import 'package:akira/ui/pages/downloads_page/downloads_page.dart';
import 'package:akira/services/theme_service.dart';
import 'package:akira/theme/akira_colors.dart';
import 'package:akira/ui/widgets/glass_container.dart';
import 'header_icon_button.dart';

class ListAppBar extends StatelessWidget {
  final double appBarOpacity;
  final bool isManga;
  final VoidCallback onToggleMode;

  const ListAppBar({
    super.key,
    required this.appBarOpacity,
    required this.isManga,
    required this.onToggleMode,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final useGlass = ThemeService().useGlassTheme;
    final currentRadius = 40.0 * (1.0 - appBarOpacity);
    final isLight = Theme.of(context).brightness == Brightness.light;
    final appBarColor = AkiraColors.getHeaderColor(colorScheme, isLight);

    return SliverAppBar(
      expandedHeight: 160.0,
      pinned: true,
      stretch: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(currentRadius),
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
      flexibleSpace: ClipRRect(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(currentRadius),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Persistent background that doesn't parallax
            GlassContainer(
              borderRadius: 0,
              opacity: useGlass ? (0.4 + appBarOpacity * 0.2).clamp(0, 0.6) : (0.9 + appBarOpacity * 0.1).clamp(0, 1.0),
              color: appBarColor,
              blur: 15,
              withBlur: useGlass,
              border: const Border(),
              child: const SizedBox.expand(),
            ),
            FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
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
                                    fontSize: 44,
                                    height: 0.9,
                                    letterSpacing: -2.5,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'HUB',
                                  style: TextStyle(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 18,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isManga ? 'YOUR ULTIMATE MANGA DESTINATION' : 'YOUR ULTIMATE ANIME DESTINATION',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: colorScheme.onSurface.withValues(alpha: 0.8),
                                fontWeight: FontWeight.w900,
                                fontSize: 9,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          HeaderIconButton(
                            tooltip: ThemeService().showTooltips ? 'Senpai\'s Picks' : null,
                            icon: Icons.favorite_rounded,
                            onPressed: () {
                              FocusManager.instance.primaryFocus?.unfocus();
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const BookmarksPage()));
                            },
                          ),
                          const SizedBox(width: 8),
                          HeaderIconButton(
                            icon: Icons.download_done_rounded,
                            onPressed: () {
                              FocusManager.instance.primaryFocus?.unfocus();
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const DownloadsPage()));
                            },
                          ),
                          const SizedBox(width: 8),
                          HeaderIconButton(
                            icon: Icons.settings_rounded,
                            onPressed: () {
                              FocusManager.instance.primaryFocus?.unfocus();
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage()));
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

