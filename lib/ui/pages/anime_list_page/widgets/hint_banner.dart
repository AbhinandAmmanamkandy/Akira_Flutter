import 'package:flutter/material.dart';

class HintBanner extends StatelessWidget {
  final String text;

  const HintBanner({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
        child: IntrinsicWidth(
          child: Stack(
            children: [
              // HUD Brackets (Corners)
              Positioned(top: 0, left: 0, child: _HUDCorner(isTop: true, isLeft: true, color: colorScheme.primary)),
              Positioned(top: 0, right: 0, child: _HUDCorner(isTop: true, isLeft: false, color: colorScheme.primary)),
              Positioned(bottom: 0, left: 0, child: _HUDCorner(isTop: false, isLeft: true, color: colorScheme.primary)),
              Positioned(bottom: 0, right: 0, child: _HUDCorner(isTop: false, isLeft: false, color: colorScheme.primary)),
              
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 36),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // System Label
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 1.5,
                          color: colorScheme.primary.withValues(alpha: 0.4),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'SYSTEM ADVISORY',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w900,
                            fontSize: 9,
                            letterSpacing: 2.5,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 6,
                          height: 1.5,
                          color: colorScheme.primary.withValues(alpha: 0.4),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Main Hint Text
                    Text(
                      text,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.1,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HUDCorner extends StatelessWidget {
  final bool isTop;
  final bool isLeft;
  final Color color;

  const _HUDCorner({
    required this.isTop, 
    required this.isLeft, 
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        border: Border(
          top: isTop ? BorderSide(color: color, width: 2.0) : BorderSide.none,
          bottom: !isTop ? BorderSide(color: color, width: 2.0) : BorderSide.none,
          left: isLeft ? BorderSide(color: color, width: 2.0) : BorderSide.none,
          right: !isLeft ? BorderSide(color: color, width: 2.0) : BorderSide.none,
        ),
      ),
    );
  }
}
