import 'package:flutter/material.dart';
import '../../../../theme/akira_colors.dart';

class HintBanner extends StatelessWidget {
  final String text;

  const HintBanner({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Soft Icon that feels like an ambient light
            Icon(
              Icons.auto_awesome_rounded,
              color: AkiraColors.getHintIconColor(colorScheme, isLight),
              size: 24,
            ),
            const SizedBox(height: 16),
            
            // "Projected" text effect
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AkiraColors.getHintTextColor(colorScheme, isLight),
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
                height: 1.3,
                shadows: [
                  Shadow(
                    color: AkiraColors.getHintShadowColor(colorScheme, isLight),
                    blurRadius: 12,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Fading Horizon Line
            Container(
              width: 120,
              height: 1.2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    AkiraColors.getHintDividerColor(colorScheme, isLight),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
            
            const SizedBox(height: 10),
            
            // Minimalist status bit
            Text(
              "ADVISORY_ACTIVE",
              style: TextStyle(
                color: AkiraColors.getHintSubtextColor(colorScheme, isLight),
                fontWeight: FontWeight.w900,
                fontSize: 10,
                letterSpacing: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
