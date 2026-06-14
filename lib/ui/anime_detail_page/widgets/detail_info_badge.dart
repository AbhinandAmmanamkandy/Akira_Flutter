import 'package:flutter/material.dart';

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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
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
