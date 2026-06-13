import 'package:flutter/material.dart';
import '../models/anime.dart';

class AnimeDetailPage extends StatefulWidget {
  final Anime anime;

  const AnimeDetailPage({super.key, required this.anime});

  @override
  State<AnimeDetailPage> createState() => _AnimeDetailPageState();
}

class _AnimeDetailPageState extends State<AnimeDetailPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          // Detect when user pulls down specifically at the top
          if (notification is ScrollUpdateNotification) {
            if (notification.metrics.pixels < -80 && 
                notification.dragDetails != null) {
              Navigator.of(context).pop();
              return true;
            }
          }
          return false;
        },
        child: CustomScrollView(
          controller: _scrollController,
          // BouncingScrollPhysics allows us to detect negative offsets on Android/iOS
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            SliverAppBar(
              expandedHeight: 300.0,
              pinned: true,
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.black.withValues(alpha: 0.3),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  widget.anime.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    shadows: [
                      Shadow(
                        color: Colors.black,
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
                titlePadding: const EdgeInsetsDirectional.only(
                  start: 56.0,
                  bottom: 16.0,
                  end: 16.0,
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
                      tag: 'anime_${widget.anime.id}',
                      child: ClipRRect(
                        borderRadius: BorderRadius.zero,
                        child: widget.anime.thumbnail != null
                            ? Image.network(
                                widget.anime.thumbnail!,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                child: const Icon(Icons.movie, size: 100),
                              ),
                      ),
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black87,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.anime.genres != null && widget.anime.genres!.isNotEmpty) ...[
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: widget.anime.genres!.map((genre) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              genre,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _DetailInfo(label: 'SCORE', value: widget.anime.score?.toString() ?? 'N/A'),
                        _DetailInfo(label: 'TYPE', value: widget.anime.type ?? 'N/A'),
                        _DetailInfo(label: 'STATUS', value: widget.anime.status ?? 'N/A'),
                        _DetailInfo(label: 'SEASON', value: widget.anime.season ?? 'N/A'),
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (widget.anime.studios != null && widget.anime.studios!.isNotEmpty) ...[
                      Text(
                        'Studios: ${widget.anime.studios!.join(", ")}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.anime.description != null && widget.anime.description!.isNotEmpty
                          ? widget.anime.description!.replaceAll(RegExp(r'<[^>]*>'), '')
                          : 'No description available.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            height: 1.5,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 24),
                    if (widget.anime.rating != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, size: 20),
                            const SizedBox(width: 12),
                            Text(
                              'Rating: ${widget.anime.rating}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
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

class _DetailInfo extends StatelessWidget {
  final String label;
  final String value;

  const _DetailInfo({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            letterSpacing: 1.2,
            color: Theme.of(context).colorScheme.outline,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}
