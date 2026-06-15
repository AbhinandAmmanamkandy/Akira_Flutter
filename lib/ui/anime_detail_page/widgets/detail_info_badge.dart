import 'package:flutter/material.dart';
import '../../widgets/glass_container.dart';

class DetailInfoBadge extends StatelessWidget {
  final String text;
  final Color bgColor;
  final Color textColor;

  const DetailInfoBadge({
    super.key,
    required this.text,
    required this.bgColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: 8,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      opacity: 0.15,
      border: Border.all(
        color: bgColor.withValues(alpha: 0.3),
        width: 1,
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
      ),
    );
  }
}
