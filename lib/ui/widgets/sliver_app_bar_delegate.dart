import 'package:flutter/material.dart';

class SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final Color? backgroundColor;

  SliverAppBarDelegate({
    required this.child,
    this.backgroundColor,
  });

  @override
  double get minExtent => (child as PreferredSizeWidget).preferredSize.height;
  @override
  double get maxExtent => (child as PreferredSizeWidget).preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: backgroundColor?.withValues(alpha: overlapsContent ? 1.0 : 0.0),
      child: child,
    );
  }

  @override
  bool shouldRebuild(SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
