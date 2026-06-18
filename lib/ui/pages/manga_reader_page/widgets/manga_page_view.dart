import 'package:flutter/material.dart';
import 'package:akira/services/manga_read_service.dart';

class MangaPageView extends StatelessWidget {
  final List<String> pages;
  final PageController controller;
  final Function(int) onPageChanged;
  final VoidCallback onTap;

  const MangaPageView({
    super.key,
    required this.pages,
    required this.controller,
    required this.onPageChanged,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return PageView.builder(
          controller: controller,
          itemCount: pages.length,
          onPageChanged: onPageChanged,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            return Stack(
              children: [
                GestureDetector(
                  onTap: onTap,
                  child: InteractiveViewer(
                    minScale: 1.0,
                    maxScale: 4.0,
                    child: Center(
                      child: Image.network(
                        pages[index],
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
                ),
                // Left tap area for previous page
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: width * 0.25,
                  child: GestureDetector(
                    onTap: () {
                      if (controller.page! > 0) {
                        controller.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    behavior: HitTestBehavior.translucent,
                  ),
                ),
                // Right tap area for next page
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  width: width * 0.25,
                  child: GestureDetector(
                    onTap: () {
                      if (controller.page! < pages.length - 1) {
                        controller.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    behavior: HitTestBehavior.translucent,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
