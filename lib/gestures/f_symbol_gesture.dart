import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FSymbolGesture extends StatefulWidget {
  final Widget child;
  final VoidCallback onSymbolDetected;

  const FSymbolGesture({
    super.key,
    required this.child,
    required this.onSymbolDetected,
  });

  @override
  State<FSymbolGesture> createState() => _FSymbolGestureState();
}

class _FSymbolGestureState extends State<FSymbolGesture> {
  List<Offset> _gesturePoints = [];

  bool _isFSymbol(List<Offset> points) {
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

    // Minimum size requirements for an 'F'
    if (width < 40 || height < 60) return false;
    
    // An 'F' should be taller than it is wide, but not excessively so
    if (height < width * 0.8) return false;

    List<int> hDirs = [];
    List<int> vDirs = [];
    
    for (int i = 1; i < points.length; i++) {
      double dx = points[i].dx - points[i - 1].dx;
      double dy = points[i].dy - points[i - 1].dy;
      
      if (dx.abs() > 3) hDirs.add(dx > 0 ? 1 : -1);
      if (dy.abs() > 3) vDirs.add(dy > 0 ? 1 : -1);
    }

    if (hDirs.isEmpty || vDirs.isEmpty) return false;

    List<int> redH = _reduce(hDirs);
    List<int> redV = _reduce(vDirs);

    // Single-stroke 'F' detection logic:
    // Typical path: Top-Right -> Left (top bar) -> Down (stem) -> Up (back to middle) -> Right (middle bar)
    // Horizontal directions: [-1, 1]
    // Vertical directions: [1, -1]
    
    bool hasDownThenUp = false;
    for (int i = 0; i < redV.length - 1; i++) {
      if (redV[i] == 1 && redV[i + 1] == -1) {
        hasDownThenUp = true;
        break;
      }
    }

    bool hasHorizontalShift = false;
    // Looking for a change in horizontal direction (the two bars)
    for (int i = 0; i < redH.length - 1; i++) {
      if (redH[i] != redH[i + 1]) {
        hasHorizontalShift = true;
        break;
      }
    }

    // If drawn as: Top-Left -> Right -> Down -> Up -> Right
    // redH: [1, -1, 1] (Right to top-left, then back to stem, then right for middle bar)
    // redV: [1, -1]
    
    return hasDownThenUp && hasHorizontalShift;
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
        if (_isFSymbol(_gesturePoints)) {
          widget.onSymbolDetected();
          HapticFeedback.mediumImpact();
        }
        _gesturePoints = [];
      },
      child: widget.child,
    );
  }
}
