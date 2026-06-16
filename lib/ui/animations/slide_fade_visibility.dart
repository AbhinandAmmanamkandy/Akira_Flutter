import 'package:flutter/material.dart';

class SlideFadeVisibility extends StatelessWidget {
  final bool isVisible;
  final Widget child;
  final Axis direction;
  final double offset;
  final Duration duration;
  final Curve curve;

  const SlideFadeVisibility({
    super.key,
    required this.isVisible,
    required this.child,
    this.direction = Axis.vertical,
    this.offset = 10.0,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.fastOutSlowIn,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: duration,
      curve: curve,
      alignment: Alignment.topLeft,
      child: AnimatedSwitcher(
        duration: duration,
        switchInCurve: curve,
        switchOutCurve: curve,
        transitionBuilder: (Widget child, Animation<double> animation) {
          final slideAnimation = Tween<Offset>(
            begin: direction == Axis.vertical 
                ? Offset(0, offset / 100) 
                : Offset(offset / 100, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: curve,
          ));

          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: slideAnimation,
              child: child,
            ),
          );
        },
        child: isVisible ? child : const SizedBox.shrink(),
      ),
    );
  }
}
