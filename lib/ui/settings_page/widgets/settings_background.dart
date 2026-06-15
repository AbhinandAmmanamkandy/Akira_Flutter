import 'package:flutter/material.dart';

class SettingsBackground extends StatelessWidget {
  final Widget child;

  const SettingsBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            colorScheme.surface,
          ],
        ),
      ),
      child: child,
    );
  }
}
