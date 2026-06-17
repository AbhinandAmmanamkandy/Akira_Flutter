import 'package:flutter/material.dart';

class AkiraColors {
  // Brand Colors
  static const Color red = Color(0xFFE53935);
  static const Color black = Color(0xFF121212);
  static const Color white = Color(0xFFF8F9FA);

  // Purple-themed Palette for non-Material You
  static const Map<String, Color> palette = {
    'Electric Purple': Color(0xFFD500F9),
    'Deep Violet': Color(0xFF6200EA),
    'Royal Purple': Color(0xFF7B1FA2),
    'Amethyst': Color(0xFF9C27B0),
    'Lavender': Color(0xFFB39DDB),
    'Grape': Color(0xFF673AB7),
    'Indigo': Color(0xFF3F51B5),
    'Soft Orchid': Color(0xFFCE93D8),
  };

  // Surface & Backgrounds
  static Color getBackground(ColorScheme colorScheme, bool isLight) {
    return Color.lerp(
      colorScheme.surface,
      colorScheme.onSurface,
      isLight ? 0.05 : 0.02,
    )!;
  }

  // Header/App Bar color
  static Color getHeaderColor(ColorScheme colorScheme, bool isLight) {
    if (isLight) {
      return Color.lerp(colorScheme.surfaceContainerHighest, Colors.black, 0.03)!;
    } else {
      return Color.lerp(colorScheme.surfaceContainerHighest, Colors.black, 0.15)!;
    }
  }

  // Floating components color (Search Bar, etc)
  static Color getFloatingColor(ColorScheme colorScheme, bool isLight) {
    return colorScheme.surfaceContainerHighest;
  }

  // Component backgrounds (Cards, Buttons)
  static Color getComponentColor(ColorScheme colorScheme, bool isLight) {
    return colorScheme.surfaceContainerHighest.withValues(alpha: isLight ? 0.8 : 0.3);
  }

  // Shadow colors
  static Color getShadowColor(ColorScheme colorScheme) {
    return Colors.black.withValues(alpha: 0.2);
  }

  // Hint Banner Colors
  static Color getHintIconColor(ColorScheme colorScheme, bool isLight) {
    return colorScheme.primary.withValues(alpha: isLight ? 0.8 : 0.6);
  }

  static Color getHintTextColor(ColorScheme colorScheme, bool isLight) {
    return colorScheme.onSurface.withValues(alpha: isLight ? 0.9 : 0.9);
  }

  static Color getHintShadowColor(ColorScheme colorScheme, bool isLight) {
    return colorScheme.primary.withValues(alpha: isLight ? 0.15 : 0.2);
  }

  static Color getHintDividerColor(ColorScheme colorScheme, bool isLight) {
    return colorScheme.primary.withValues(alpha: isLight ? 0.4 : 0.5);
  }

  static Color getHintSubtextColor(ColorScheme colorScheme, bool isLight) {
    return colorScheme.primary.withValues(alpha: isLight ? 0.6 : 0.5);
  }

  // Resume Toast Theme
  static Color getResumeAccentColor(ColorScheme colorScheme) => colorScheme.primary;
  static Color getResumeOnAccentColor(ColorScheme colorScheme) => colorScheme.onPrimary;
  
  static TextStyle getResumeTitleStyle(ColorScheme colorScheme) {
    return const TextStyle(
      color: Colors.white,
      fontSize: 12,
      fontWeight: FontWeight.bold,
      letterSpacing: 0.2,
    );
  }

  static TextStyle getResumeSubstyle(ColorScheme colorScheme) {
    return TextStyle(
      color: Colors.white.withValues(alpha: 0.7),
      fontSize: 10,
      fontWeight: FontWeight.w500,
    );
  }
}
