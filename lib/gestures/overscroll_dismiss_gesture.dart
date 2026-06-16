import 'package:flutter/material.dart';
import '../services/theme_service.dart';

class OverscrollDismissGesture extends StatelessWidget {
  final Widget child;
  final VoidCallback? onDismiss;

  const OverscrollDismissGesture({
    super.key,
    required this.child,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (ThemeService().useOverscrollToClose && 
            notification is ScrollUpdateNotification) {
          if (notification.metrics.pixels < -80 && 
              notification.dragDetails != null) {
            if (onDismiss != null) {
              onDismiss!();
            } else {
              Navigator.of(context).maybePop();
            }
            return true;
          }
        }
        return false;
      },
      child: child,
    );
  }
}
