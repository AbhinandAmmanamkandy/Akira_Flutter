import 'package:flutter/material.dart';
import '../../services/theme_service.dart';

class OverscrollPopHandler extends StatelessWidget {
  final Widget child;

  const OverscrollPopHandler({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (ThemeService().useOverscrollToClose && notification is ScrollUpdateNotification) {
          if (notification.metrics.pixels < -80 && notification.dragDetails != null) {
            Navigator.of(context).maybePop();
            return true;
          }
        }
        return false;
      },
      child: child,
    );
  }
}
