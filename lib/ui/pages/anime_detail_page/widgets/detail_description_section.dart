import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import '../../../widgets/glass_container.dart';

class DetailDescriptionSection extends StatelessWidget {
  final String? description;

  const DetailDescriptionSection({super.key, this.description});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (description == null || description!.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.notes_rounded, size: 40, color: colorScheme.outline),
              const SizedBox(height: 8),
              const Text('No description available.'),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Overview',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GlassContainer(
          borderRadius: 20,
          padding: const EdgeInsets.all(16),
          opacity: 0.05,
          withBlur: false, // Disabled blur for better scroll performance
          child: HtmlWidget(
            description!,
            textStyle: textTheme.bodyLarge?.copyWith(
              height: 1.6,
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ],
    );
  }
}
