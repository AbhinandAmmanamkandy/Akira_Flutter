import 'package:flutter/material.dart';

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
    if (totalEpisodes <= 50) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final int chunks = (totalEpisodes / 50).ceil();

    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: chunks,
        itemBuilder: (context, index) {
          final start = (index * 50) + 1;
          final end = ((index + 1) * 50).clamp(1, totalEpisodes);
          final isSelected = selectedRangeIndex == index;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text('$start - $end'),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) onRangeSelected(index);
              },
              showCheckmark: false,
              selectedColor: colorScheme.primary,
              labelStyle: TextStyle(
                color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(
                color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
              ),
            ),
          );
        },
      ),
    );
  }
}
