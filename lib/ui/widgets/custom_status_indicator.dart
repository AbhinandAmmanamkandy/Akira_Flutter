import 'package:flutter/material.dart';
import 'glass_container.dart';

class CustomStatusIndicator extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color? iconColor;

  const CustomStatusIndicator({
    super.key,
    required this.message,
    required this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return GlassContainer(
      borderRadius: 100, // Pill shape
      padding: const EdgeInsets.fromLTRB(6, 6, 24, 6),
      withBlur: true,
      opacity: isLight ? 0.95 : 0.85,
      color: isLight ? colorScheme.surface : colorScheme.surfaceContainerHighest,
      border: Border.all(
        color: colorScheme.onSurface.withValues(alpha: 0.1),
        width: 1,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (iconColor ?? colorScheme.primary).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor ?? colorScheme.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                message.toUpperCase(),
                maxLines: 1,
                style: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static void show(BuildContext context, String message, IconData icon, {Color? iconColor}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 20),
        duration: const Duration(milliseconds: 2000),
        content: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: CustomStatusIndicator(
              message: message,
              icon: icon,
              iconColor: iconColor,
            ),
          ),
        ),
      ),
    );
  }
}
