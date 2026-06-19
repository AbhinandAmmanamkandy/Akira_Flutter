import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MSymbolGesture extends StatefulWidget {
  final Widget child;
  final VoidCallback onSymbolDetected;

  const MSymbolGesture({
    super.key,
    required this.child,
    required this.onSymbolDetected,
  });

  @override
  State<MSymbolGesture> createState() => _MSymbolGestureState();
}

class _MSymbolGestureState extends State<MSymbolGesture> {
  List<Offset> _gesturePoints = [];

  bool _isMSymbol(List<Offset> points) {
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

    // Minimum size requirements for an 'M'
    if (width < 60 || height < 40) return false;

    List<int> hDirs = [];
    List<int> vDirs = [];

    for (int i = 1; i < points.length; i++) {
      double dx = points[i].dx - points[i - 1].dx;
      double dy = points[i].dy - points[i - 1].dy;

      if (dx.abs() > 3) hDirs.add(dx > 0 ? 1 : -1);
      if (dy.abs() > 3) vDirs.add(dy > 0 ? 1 : -1);
    }

    if (hDirs.isEmpty || vDirs.isEmpty) return false;

    List<int> redV = _reduce(vDirs);

    // Continuous 'M' drawn as: Up -> Down-Right -> Up-Right -> Down
    // Vertical directions: [-1, 1, -1, 1]
    // Continuous 'M' drawn as: Down -> Up -> Down -> Up is a 'W'
    // But some might draw M as Down, then Top-Left to Middle-Down, then Middle-Down to Top-Right, then Down.
    // If one continuous stroke: Down (1), then back up to top (very fast or overlapping), then Down-Right (1), then Up-Right (-1), then Down (1).
    // Let's look for the 3 peaks/valleys in vertical direction.

    bool hasMSequence = false;
    for (int i = 0; i <= redV.length - 4; i++) {
      if ((redV[i] == -1 && redV[i + 1] == 1 && redV[i + 2] == -1 && redV[i + 3] == 1) ||
          (redV[i] == 1 && redV[i + 1] == -1 && redV[i + 2] == 1 && redV[i + 3] == -1)) {
        hasMSequence = true;
        break;
      }
    }

    // Also check for W shape just in case users draw it that way? 
    // M: Up, Down, Up, Down.
    
    return hasMSequence && (width > height * 0.5);
  }

  List<int> _reduce(List<int> dirs) {
    if (dirs.isEmpty) return [];
    List<int> reduced = [dirs.first];
    for (int i = 1; i < dirs.length; i++) {
      if (dirs[i] != reduced.last) {
        reduced.add(dirs[i]);
      }
    }
    return reduced;
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (event) => _gesturePoints = [event.localPosition],
      onPointerMove: (event) => _gesturePoints.add(event.localPosition),
      onPointerUp: (event) {
        if (_isMSymbol(_gesturePoints)) {
          widget.onSymbolDetected();
          HapticFeedback.mediumImpact();
        }
        _gesturePoints = [];
      },
      child: widget.child,
    );
  }
}
