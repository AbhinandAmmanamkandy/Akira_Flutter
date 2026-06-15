import 'package:flutter/material.dart';
import '../../widgets/glass_container.dart';

class DetailGenreTag extends StatelessWidget {
  final String label;

  const DetailGenreTag({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return GlassContainer(
      borderRadius: 20,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      opacity: 0.1,
      border: Border.all(
        color: colorScheme.primary.withValues(alpha: 0.2),
        width: 1,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: colorScheme.primary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
