import 'dart:ui';
import 'package:flutter/material.dart';
import '../../services/theme_service.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blur;
  final double opacity;
  final EdgeInsetsGeometry? padding;
  final BoxBorder? border;
  final bool withBlur; // New flag for performance

  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.blur = 10, // Reduced from 15 for better performance
    this.opacity = 0.1,
    this.padding,
    this.border,
    this.withBlur = false, // Default to false for better performance
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeService(),
      builder: (context, _) {
        final useGlass = ThemeService().useGlassTheme;
        final colorScheme = Theme.of(context).colorScheme;

        if (!useGlass) {
          return Container(
            padding: padding,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(borderRadius),
              border: border,
            ),
            child: child,
          );
        }

        final boxDecoration = BoxDecoration(
          color: colorScheme.surface.withValues(alpha: opacity),
          borderRadius: BorderRadius.circular(borderRadius),
          border: border ?? Border.all(
            color: colorScheme.onSurface.withValues(alpha: 0.1),
            width: 1.2,
          ),
        );

        if (!withBlur) {
          return Container(
            padding: padding,
            decoration: boxDecoration,
            child: child,
          );
        }

        return ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
            child: Container(
              padding: padding,
              decoration: boxDecoration,
              child: child,
            ),
          ),
        );
      },
    );
  }
}
