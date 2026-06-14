import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import '../models/anime.dart';
import '../widgets/custom_chips.dart';
import '../widgets/info_tile.dart';
import '../widgets/rating_badge.dart';
import '../widgets/anime_detail_header.dart';

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
          if (notification is ScrollUpdateNotification) {
            if (notification.metrics.pixels < -80 && notification.dragDetails != null) {
              Navigator.of(context).pop();
              return true;
            }
          }
          return false;
        },
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            AnimeDetailHeader(anime: widget.anime),
            _buildContent(context),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.anime.genres != null && widget.anime.genres!.isNotEmpty) ...[
              GenreList(genres: widget.anime.genres!),
              const SizedBox(height: 24),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InfoTile(label: 'SCORE', value: widget.anime.score?.toString() ?? 'N/A'),
                InfoTile(label: 'TYPE', value: widget.anime.type ?? 'N/A'),
                InfoTile(label: 'STATUS', value: widget.anime.status ?? 'N/A'),
                InfoTile(label: 'SEASON', value: widget.anime.season ?? 'N/A'),
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
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            widget.anime.description != null && widget.anime.description!.isNotEmpty
                ? HtmlWidget(
                    widget.anime.description!,
                    textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          height: 1.5,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  )
                : Text(
                    'No description available.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          height: 1.5,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
            const SizedBox(height: 24),
            if (widget.anime.rating != null) RatingBadge(rating: widget.anime.rating!),
          ],
        ),
      ),
    );
  }
}
