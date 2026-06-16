import 'package:flutter/material.dart';
import 'dart:math';
import 'package:akira/ui/pages/settings_page/settings_page.dart';
import 'package:akira/ui/pages/bookmarks_page/bookmarks_page.dart';
import 'package:akira/services/theme_service.dart';
import 'package:akira/theme/akira_colors.dart';
import 'package:akira/ui/widgets/common_chip.dart';
import 'package:akira/ui/animations/slide_fade_visibility.dart';
import 'package:akira/ui/widgets/glass_container.dart';

class ListAppBar extends StatefulWidget {
  final double appBarOpacity;

  const ListAppBar({super.key, required this.appBarOpacity});

  @override
  State<ListAppBar> createState() => _ListAppBarState();
}

class _ListAppBarState extends State<ListAppBar> {
  bool _showHint = false;
  String _hintText = '';

  @override
  void initState() {
    super.initState();
    
    final hints = [
      'Swipe Down For Magic',
      'Draw an S on the screen',
    ];
    _hintText = hints[Random().nextInt(hints.length)];

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() => _showHint = true);
      }
    });
    
    Future.delayed(const Duration(seconds: 7), () {
      if (mounted) {
        setState(() => _showHint = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final useGlass = ThemeService().useGlassTheme;
    final currentRadius = 32.0 * (1.0 - widget.appBarOpacity);
    final isLight = Theme.of(context).brightness == Brightness.light;
    final appBarColor = AkiraColors.getHeaderColor(colorScheme, isLight);

    // Calculate visibility based on both timer and scroll position
    final bool isVisible = _showHint && widget.appBarOpacity < 0.1;

    return SliverAppBar(
      expandedHeight: _showHint ? 210.0 : 170.0,
      pinned: true,
      stretch: true,
      backgroundColor: appBarColor.withValues(alpha: (widget.appBarOpacity * 0.9).clamp(0, 0.9)),
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
        opacity: widget.appBarOpacity > 0.8 ? 1.0 : 0.0,
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
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
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
                          const SizedBox(height: 0),
                          Text(
                            'YOUR ULTIMATE ANIME DESTINATION',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: colorScheme.onSurface.withValues(alpha: 0.8),
                              fontWeight: FontWeight.w900,
                              fontSize: 9,
                              letterSpacing: 1.2,
                            ),
                          ),
                          SlideFadeVisibility(
                            isVisible: isVisible,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: CommonChip(
                                label: _hintText.toUpperCase(),
                                icon: Icons.auto_awesome_rounded,
                                borderRadius: 25,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        IconButton(
                          tooltip: 'Senpai\'s Picks',
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const BookmarksPage())),
                          style: IconButton.styleFrom(
                            backgroundColor: AkiraColors.getComponentColor(colorScheme, isLight),
                            padding: const EdgeInsets.all(12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.5), width: 1.5),
                          ),
                          icon: Icon(Icons.bookmark_rounded, size: 24, color: colorScheme.onSurface),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage()));
                          },
                          style: IconButton.styleFrom(
                            backgroundColor: AkiraColors.getComponentColor(colorScheme, isLight),
                            padding: const EdgeInsets.all(12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.5), width: 1.5),
                          ),
                          icon: Icon(Icons.settings_rounded, size: 24, color: colorScheme.onSurface),
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
