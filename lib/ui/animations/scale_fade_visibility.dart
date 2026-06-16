import 'package:flutter/material.dart';

class ScaleFadeVisibility extends StatefulWidget {
  final bool isVisible;
  final Widget child;
  final Duration duration;
  final Curve curve;

  const ScaleFadeVisibility({
    super.key,
    required this.isVisible,
    required this.child,
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.fastOutSlowIn,
  });

  @override
  State<ScaleFadeVisibility> createState() => _ScaleFadeVisibilityState();
}

class _ScaleFadeVisibilityState extends State<ScaleFadeVisibility> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );
    if (widget.isVisible) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(ScaleFadeVisibility oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: _animation,
      axis: Axis.vertical,
      axisAlignment: 0.0, // Center expansion
      child: widget.child,
    );
  }
}
