import 'package:flutter/material.dart';
import 'package:akira/services/manga_read_service.dart';

class MangaPageView extends StatefulWidget {
  final List<String> pages;
  final PageController controller;
  final ScrollPhysics physics;
  final Function(int) onPageChanged;
  final VoidCallback onTap;
  final Function(bool) onZoomChanged;

  const MangaPageView({
    super.key,
    required this.pages,
    required this.controller,
    required this.physics,
    required this.onPageChanged,
    required this.onTap,
    required this.onZoomChanged,
  });

  @override
  State<MangaPageView> createState() => _MangaPageViewState();
}

class _MangaPageViewState extends State<MangaPageView> {
  late List<TransformationController> _transformationControllers;

  @override
  void initState() {
    super.initState();
    _transformationControllers = List.generate(
      widget.pages.length,
      (index) => TransformationController()..addListener(() => _handleTransform(index)),
    );
  }

  void _handleTransform(int index) {
    if (widget.controller.hasClients && widget.controller.page?.round() == index) {
      final isZoomed = _transformationControllers[index].value.row0[0] > 1.01;
      widget.onZoomChanged(isZoomed);
    }
  }

  @override
  void dispose() {
    for (var controller in _transformationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return PageView.builder(
          controller: widget.controller,
          itemCount: widget.pages.length,
          onPageChanged: (index) {
            // Reset previous page zoom when moving to a new page
            for (var i = 0; i < _transformationControllers.length; i++) {
              if (i != index) {
                _transformationControllers[i].value = Matrix4.identity();
              }
            }
            widget.onPageChanged(index);
          },
          physics: widget.physics,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTapUp: (details) {
                final x = details.localPosition.dx;
                // If zoomed in, taps shouldn't navigate (to avoid accidental flips)
                final isZoomed = _transformationControllers[index].value.row0[0] > 1.01;
                
                if (isZoomed) {
                  widget.onTap();
                  return;
                }

                if (x < width * 0.20) {
                  if (widget.controller.page! > 0) {
                    widget.controller.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                } else if (x > width * 0.80) {
                  if (widget.controller.page! < widget.pages.length - 1) {
                    widget.controller.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                } else {
                  widget.onTap();
                }
              },
              child: InteractiveViewer(
                transformationController: _transformationControllers[index],
                minScale: 1.0,
                maxScale: 4.0,
                child: SizedBox.expand(
                  child: Image.network(
                    widget.pages[index],
                    fit: BoxFit.contain,
                    headers: const {'Referer': AllMangaApi.referer},
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(Icons.error_outline,
                            color: Colors.white, size: 48),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
