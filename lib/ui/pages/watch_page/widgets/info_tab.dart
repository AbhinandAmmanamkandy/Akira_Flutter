import 'package:flutter/material.dart';
import '../../../../models/anime_details.dart';
import '../../../../services/theme_service.dart';
import '../../../../theme/akira_colors.dart';
import '../../../widgets/glass_container.dart';

class InfoTab extends StatelessWidget {
  final AnimeDetails details;

  const InfoTab({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final useGlass = ThemeService().useGlassTheme;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return SliverPadding(
      padding: const EdgeInsets.all(20),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          if (details.description != null) ...[
            Text(
              'Synopsis',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            _buildContainer(
              context,
              useGlass,
              isLight,
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _stripHtml(details.description!),
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
          
          Text(
            'Information',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          _buildContainer(
            context,
            useGlass,
            isLight,
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildInfoRow(context, 'Status', details.status ?? 'Unknown'),
                  _buildDivider(),
                  _buildInfoRow(context, 'Average Score', details.averageScore?.toString() ?? 'N/A'),
                  _buildDivider(),
                  _buildInfoRow(context, 'Rating', details.rating ?? 'N/A'),
                  if (details.season != null) ...[
                    _buildDivider(),
                    _buildInfoRow(context, 'Season', '${details.season!.quarter} ${details.season!.year}'),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          if (details.genres.isNotEmpty) ...[
            Text(
              'Genres',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: details.genres.map((genre) => _buildGenreChip(context, genre)).toList(),
            ),
            const SizedBox(height: 24),
          ],

          if (details.relatedShows.isNotEmpty) ...[
            Text(
              'Related Shows',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: details.relatedShows.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final related = details.relatedShows[index];
                  return _buildRelatedCard(context, related, useGlass, isLight);
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ]),
      ),
    );
  }

  Widget _buildRelatedCard(BuildContext context, RelatedShow related, bool useGlass, bool isLight) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: useGlass 
            ? colorScheme.primary.withValues(alpha: 0.05) 
            : AkiraColors.getComponentColor(colorScheme, isLight),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            related.relation.toUpperCase(),
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            related.showId, // Show ID might not be a name, but let's show it for now
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildContainer(BuildContext context, bool useGlass, bool isLight, Widget child) {
    final colorScheme = Theme.of(context).colorScheme;
    if (useGlass) {
      return GlassContainer(
        borderRadius: 20,
        opacity: isLight ? 0.05 : 0.03,
        child: child,
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: AkiraColors.getComponentColor(colorScheme, isLight),
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Divider(height: 1, thickness: 0.5),
    );
  }

  Widget _buildGenreChip(BuildContext context, String genre) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
      ),
      child: Text(
        genre,
        style: TextStyle(
          color: colorScheme.primary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _stripHtml(String htmlString) {
    return htmlString.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ' ').trim();
  }
}
