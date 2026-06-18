import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:akira/models/anime.dart';
import 'package:akira/models/anime_details.dart';
import 'package:akira/ui/widgets/glass_container.dart';

class MangaControls extends StatelessWidget {
  final Anime anime;
  final AnimeDetails details;
  final int currentChapter;
  final int currentPage;
  final int totalPages;
  final Function(int) onChapterSelected;
  final Function(int) onPageSelected;
  final VoidCallback onBack;

  const MangaControls({
    super.key,
    required this.anime,
    required this.details,
    required this.currentChapter,
    required this.currentPage,
    required this.totalPages,
    required this.onChapterSelected,
    required this.onPageSelected,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        // Top Bar
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: _TopBar(
            title: anime.name,
            subtitle: 'Chapter $currentChapter',
            onBack: onBack,
          ),
        ),

        // Bottom Bar
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _BottomBar(
            currentPage: currentPage,
            totalPages: totalPages,
            currentChapter: currentChapter,
            totalChapters: int.tryParse(details.lastEpisode ?? '0') ?? 0,
            onPageSelected: onPageSelected,
            onChapterSelected: onChapterSelected,
            onChaptersTap: () => _showChapterSelection(context),
          ),
        ),
      ],
    );
  }

  void _showChapterSelection(BuildContext context) {
    final total = int.tryParse(details.lastEpisode ?? '0') ?? 0;
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) => GlassContainer(
          borderRadius: 28,
          withBlur: true,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Select Chapter',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.builder(
                  controller: scrollController,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: total,
                  itemBuilder: (context, index) {
                    final chapter = index + 1;
                    final isSelected = chapter == currentChapter;
                    return InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        onChapterSelected(chapter);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? colorScheme.primary : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$chapter',
                          style: TextStyle(
                            color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onBack;

  const _TopBar({
    required this.title,
    required this.subtitle,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        bottom: 16,
        left: 8,
        right: 16,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.7),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: onBack,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int currentChapter;
  final int totalChapters;
  final Function(int) onPageSelected;
  final Function(int) onChapterSelected;
  final VoidCallback onChaptersTap;

  const _BottomBar({
    required this.currentPage,
    required this.totalPages,
    required this.currentChapter,
    required this.totalChapters,
    required this.onPageSelected,
    required this.onChapterSelected,
    required this.onChaptersTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
        left: 24,
        right: 24,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withValues(alpha: 0.7),
            Colors.transparent,
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (totalPages > 0)
            Row(
              children: [
                Text(
                  '${currentPage + 1}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: Slider(
                    value: currentPage.toDouble(),
                    min: 0,
                    max: (totalPages - 1).toDouble().clamp(0, double.infinity),
                    onChanged: (value) => onPageSelected(value.toInt()),
                    activeColor: Theme.of(context).colorScheme.primary,
                    inactiveColor: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                Text(
                  '$totalPages',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.grid_view_rounded, color: Colors.white),
                onPressed: onChaptersTap,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.skip_previous_rounded, color: Colors.white),
                    onPressed: currentChapter > 1 
                        ? () => onChapterSelected(currentChapter - 1) 
                        : null,
                  ),
                  Text(
                    'Page ${currentPage + 1} of $totalPages',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_next_rounded, color: Colors.white),
                    onPressed: currentChapter < totalChapters
                        ? () => onChapterSelected(currentChapter + 1)
                        : null,
                  ),
                ],
              ),
              const SizedBox(width: 48), // Spacer for balance
            ],
          ),
        ],
      ),
    );
  }
}
