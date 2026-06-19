import 'package:flutter/material.dart';
import 'package:akira/theme/akira_colors.dart';

class HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;

  const HeaderIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: AkiraColors.getComponentColor(colorScheme, isLight),
        padding: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        side: BorderSide(
          color: colorScheme.primary.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      icon: Icon(icon, size: 24, color: colorScheme.onSurface),
    );
  }
}
