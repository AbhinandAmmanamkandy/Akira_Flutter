import 'package:flutter/material.dart';

class DetailActionRow extends StatelessWidget {
  final VoidCallback onWatchNow;
  final VoidCallback onBookmark;

  const DetailActionRow({
    super.key,
    required this.onWatchNow,
    required this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: onWatchNow,
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Watch Now'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: IconButton(
            onPressed: onBookmark,
            icon: Icon(Icons.bookmark_border_rounded,
                color: colorScheme.onSecondaryContainer),
            padding: const EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }
}
