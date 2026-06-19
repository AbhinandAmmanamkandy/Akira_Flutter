import 'package:flutter/material.dart';
import 'glass_container.dart';

class CommonChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? color;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double borderRadius;
  final bool isSelected;

  const CommonChip({
    super.key,
    required this.label,
    this.icon,
    this.color,
    this.onTap,
    this.onLongPress,
    this.borderRadius = 20,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final themeColorScheme = Theme.of(context).colorScheme;
    final effectiveColor = color ?? themeColorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: GlassContainer(
        borderRadius: borderRadius,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        opacity: isSelected ? 1.0 : 0.15,
        color: isSelected ? effectiveColor : null,
        withBlur: !isSelected,
        blur: 8,
        border: Border.all(
          color: isSelected ? Colors.transparent : effectiveColor.withValues(alpha: 0.2),
          width: 1,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: isSelected ? themeColorScheme.onPrimary : effectiveColor,
              ),
              const SizedBox(width: 4),
            ],
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? themeColorScheme.onPrimary : effectiveColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
