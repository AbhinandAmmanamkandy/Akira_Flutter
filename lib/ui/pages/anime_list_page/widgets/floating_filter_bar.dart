import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../services/theme_service.dart';
import '../../../widgets/glass_container.dart';
import '../../../widgets/common_chip.dart';
import '../../../widgets/custom_status_indicator.dart';

class FloatingFilterBar extends StatelessWidget {
  final bool isManga;
  final String searchText;
  final VoidCallback onToggleMode;
  final Function(String) onSearch;

  const FloatingFilterBar({
    super.key,
    required this.isManga,
    required this.searchText,
    required this.onToggleMode,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final useGlass = ThemeService().useGlassTheme;

    return Positioned(
      bottom: bottomInset + 90,
      left: 0,
      right: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, bottom: 12),
            child: GlassContainer(
              borderRadius: 20,
              padding: const EdgeInsets.all(2),
              opacity: 0.15,
              blur: 8,
              withBlur: useGlass,
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.2),
                width: 1,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _SmallModeButton(
                    label: 'ANIME',
                    icon: Icons.play_circle_fill_rounded,
                    isSelected: !isManga,
                    onTap: isManga ? onToggleMode : null,
                  ),
                  _SmallModeButton(
                    label: 'MANGA',
                    icon: Icons.menu_book_rounded,
                    isSelected: isManga,
                    onTap: !isManga ? onToggleMode : null,
                  ),
                ],
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ListenableBuilder(
              listenable: ThemeService(),
              builder: (context, _) {
                return Row(
                  children: [
                    CommonChip(
                      label: 'Trending',
                      icon: Icons.trending_up_rounded,
                      color: colorScheme.primary,
                      isSelected: searchText == 'Trending',
                      onTap: () {
                        if (searchText == 'Trending') {
                          onSearch('');
                        } else {
                          onSearch('Trending');
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    ...ThemeService().pinnedChips.map(
                      (genre) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: CommonChip(
                          label: genre,
                          isSelected: searchText == genre,
                          onTap: () {
                            if (searchText == genre) {
                              onSearch('');
                            } else {
                              onSearch(genre);
                            }
                          },
                          onLongPress: () {
                            ThemeService().removePinnedChip(genre);
                            HapticFeedback.mediumImpact();
                            CustomStatusIndicator.show(
                              context,
                              'Removed $genre',
                              Icons.delete_outline_rounded,
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallModeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback? onTap;

  const _SmallModeButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 11,
              color: isSelected
                  ? colorScheme.onPrimary
                  : colorScheme.primary.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.3,
                color: isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.primary.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
