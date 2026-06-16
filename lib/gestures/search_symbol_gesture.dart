import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SearchSymbolGesture extends StatefulWidget {
  final Widget child;
  final VoidCallback onSymbolDetected;

  const SearchSymbolGesture({
    super.key,
    required this.child,
    required this.onSymbolDetected,
  });

  @override
  State<SearchSymbolGesture> createState() => _SearchSymbolGestureState();
}

class _SearchSymbolGestureState extends State<SearchSymbolGesture> {
  List<Offset> _gesturePoints = [];

  bool _isSearchSymbol(List<Offset> points) {
    if (points.length < 15) return false;

    double minX = points[0].dx;
    double maxX = points[0].dx;
    double minY = points[0].dy;
    double maxY = points[0].dy;

    for (var p in points) {
      if (p.dx < minX) minX = p.dx;
      if (p.dx > maxX) maxX = p.dx;
      if (p.dy < minY) minY = p.dy;
      if (p.dy > maxY) maxY = p.dy;
    }

    double width = maxX - minX;
    double height = maxY - minY;

    if (width < 50 || height < 80) return false;

    List<int> horizontalDirections = [];
    for (int i = 1; i < points.length; i++) {
      double diff = points[i].dx - points[i - 1].dx;
      if (diff.abs() > 3) {
        horizontalDirections.add(diff > 0 ? 1 : -1);
      }
    }

    if (horizontalDirections.isEmpty) return false;

    List<int> reduced = [horizontalDirections.first];
    for (int i = 1; i < horizontalDirections.length; i++) {
      if (horizontalDirections[i] != reduced.last) {
        reduced.add(horizontalDirections[i]);
      }
    }

    bool hasSSequence = false;
    for (int i = 0; i <= reduced.length - 3; i++) {
      if ((reduced[i] == -1 && reduced[i + 1] == 1 && reduced[i + 2] == -1) ||
          (reduced[i] == 1 && reduced[i + 1] == -1 && reduced[i + 2] == 1)) {
        hasSSequence = true;
        break;
      }
    }

    return hasSSequence && (height > width * 0.8);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (event) => _gesturePoints = [event.localPosition],
      onPointerMove: (event) => _gesturePoints.add(event.localPosition),
      onPointerUp: (event) {
        if (_isSearchSymbol(_gesturePoints)) {
          widget.onSymbolDetected();
          HapticFeedback.mediumImpact();
        }
        _gesturePoints = [];
      },
      child: widget.child,
    );
  }
}
