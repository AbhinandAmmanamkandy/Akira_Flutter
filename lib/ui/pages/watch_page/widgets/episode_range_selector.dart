import 'package:flutter/material.dart';
import '../../../../theme/akira_colors.dart';

class EpisodeRangeSelector extends StatelessWidget {
  final int totalEpisodes;
  final int selectedRangeIndex;
  final Function(int) onRangeSelected;

  const EpisodeRangeSelector({
    super.key,
    required this.totalEpisodes,
    required this.selectedRangeIndex,
    required this.onRangeSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (totalEpisodes <= 25) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final int chunks = (totalEpisodes / 25).ceil();

    return Container(
      height: 48,
      margin: const EdgeInsets.only(top: 8, bottom: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: chunks,
        itemBuilder: (context, index) {
          final start = (index * 25) + 1;
          final end = ((index + 1) * 25).clamp(1, totalEpisodes);
          final isSelected = selectedRangeIndex == index;

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ChoiceChip(
              label: Text('$start - $end'),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) onRangeSelected(index);
              },
              showCheckmark: false,
              selectedColor: colorScheme.primary,
              backgroundColor: AkiraColors.getComponentColor(colorScheme, isLight),
              labelStyle: TextStyle(
                color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              side: BorderSide.none,
              elevation: isSelected ? 4 : 0,
              shadowColor: colorScheme.primary.withValues(alpha: 0.4),
            ),
          );
        },
      ),
    );
  }
}
