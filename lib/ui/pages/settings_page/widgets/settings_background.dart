import 'package:flutter/material.dart';
import 'package:akira/services/theme_service.dart';
import 'dart:math' as math;

class SettingsBackground extends StatefulWidget {
  final Widget child;

  const SettingsBackground({super.key, required this.child});

  @override
  State<SettingsBackground> createState() => _SettingsBackgroundState();
}

class _SettingsBackgroundState extends State<SettingsBackground> with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeService(),
      builder: (context, _) {
        final colorScheme = Theme.of(context).colorScheme;
        final useGlass = ThemeService().useGlassTheme;

        return Container(
          color: colorScheme.surface,
          child: Stack(
            children: [
              if (useGlass) ...[
                _AnimatedBlob(
                  controller: _controller,
                  top: -50,
                  right: -50,
                  size: 350,
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  speed: 1.0,
                  offset: 0,
                ),
                _AnimatedBlob(
                  controller: _controller,
                  top: 300,
                  left: -100,
                  size: 300,
                  color: colorScheme.secondary.withValues(alpha: 0.08),
                  speed: 0.8,
                  offset: math.pi / 2,
                ),
                _AnimatedBlob(
                  controller: _controller,
                  bottom: 100,
                  right: -80,
                  size: 250,
                  color: colorScheme.tertiary.withValues(alpha: 0.06),
                  speed: 1.2,
                  offset: math.pi,
                ),
                _AnimatedBlob(
                  controller: _controller,
                  bottom: -100,
                  left: 20,
                  size: 400,
                  color: colorScheme.primary.withValues(alpha: 0.05),
                  speed: 0.7,
                  offset: 3 * math.pi / 2,
                ),
              ],
              widget.child,
            ],
          ),
        );
      },
    );
  }
}

class _AnimatedBlob extends StatelessWidget {
  final AnimationController controller;
  final double? top, bottom, left, right;
  final double size;
  final Color color;
  final double speed;
  final double offset;

  const _AnimatedBlob({
    required this.controller,
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.size,
    required this.color,
    required this.speed,
    required this.offset,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final val = controller.value * 2 * math.pi * speed + offset;
        final dx = math.sin(val) * 30;
        final dy = math.cos(val) * 30;

        return Positioned(
          top: top != null ? top! + dy : null,
          bottom: bottom != null ? bottom! - dy : null,
          left: left != null ? left! + dx : null,
          right: right != null ? right! - dx : null,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  color,
                  color.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
