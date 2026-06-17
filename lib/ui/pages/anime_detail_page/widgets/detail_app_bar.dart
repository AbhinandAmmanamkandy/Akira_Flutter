import 'package:flutter/material.dart';
import '../../../../models/anime.dart';

class DetailAppBar extends StatelessWidget {
  final Anime anime;
  final bool isFavorite;
  final bool isCollapsed;
  final VoidCallback onFavoriteTap;

  const DetailAppBar({
    super.key,
    required this.anime,
    required this.isFavorite,
    required this.isCollapsed,
    required this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SliverAppBar(
      expandedHeight: 400.0,
      pinned: true,
      stretch: true,
      backgroundColor: colorScheme.surface,
      leading: AnimatedOpacity(
        opacity: isCollapsed ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 250),
        child: IgnorePointer(
          ignoring: isCollapsed,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton.filledTonal(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      actions: [
        AnimatedOpacity(
          opacity: isCollapsed ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 250),
          child: IgnorePointer(
            ignoring: isCollapsed,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton.filledTonal(
                icon: Icon(
                  isFavorite ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                  color: isFavorite ? Colors.red : null,
                ),
                onPressed: onFavoriteTap,
              ),
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
        title: Text(
          (anime.englishName != null && anime.englishName!.isNotEmpty)
              ? anime.englishName!
              : anime.name,
          maxLines: isCollapsed ? 1 : 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: isCollapsed ? colorScheme.onSurface : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: isCollapsed ? 18 : 20,
            shadows: isCollapsed
                ? []
                : [
                    const Shadow(
                      color: Colors.black54,
                      offset: Offset(0, 2),
                      blurRadius: 8,
                    )
                  ],
          ),
        ),
        titlePadding: EdgeInsetsDirectional.only(
          start: 20.0,
          bottom: isCollapsed ? 16.0 : 24.0,
          end: 20.0,
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: 'anime_${anime.id}',
              child: anime.thumbnail != null
                  ? Image.network(
                      anime.thumbnail!,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: colorScheme.surfaceContainerHighest,
                      child: const Icon(Icons.movie_filter_rounded, size: 80),
                    ),
            ),
            // Improved Gradient
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.4, 0.7, 1.0],
                  colors: [
                    Colors.black54,
                    Colors.transparent,
                    Colors.black54,
                    Colors.black87,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
