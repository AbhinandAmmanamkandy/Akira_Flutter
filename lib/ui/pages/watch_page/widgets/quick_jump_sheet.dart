import 'package:flutter/material.dart';
import 'package:akira/ui/widgets/glass_container.dart';

class QuickJumpSheet extends StatelessWidget {
  final int totalEpisodes;
  final Function(int) onEpisodeSelected;

  const QuickJumpSheet({
    super.key,
    required this.totalEpisodes,
    required this.onEpisodeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final controller = TextEditingController();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: GlassContainer(
        borderRadius: 28,
        withBlur: true,
        blur: 25,
        opacity: isLight ? 0.85 : 0.45,
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.bolt_rounded, color: colorScheme.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Text(
                  'Quick Jump',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '1 - $totalEpisodes',
                    style: textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              textAlign: TextAlign.center,
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: colorScheme.primary,
                letterSpacing: 2,
              ),
              decoration: InputDecoration(
                hintText: '---',
                hintStyle: TextStyle(
                  color: colorScheme.primary.withValues(alpha: 0.15),
                  letterSpacing: 2,
                ),
                filled: true,
                fillColor: colorScheme.primary.withValues(alpha: 0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 20),
                prefixIcon: const SizedBox(width: 48), // Balancing the suffix icon space
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: IconButton.filledTonal(
                    onPressed: () {
                      final ep = int.tryParse(controller.text);
                      if (ep != null && ep > 0 && ep <= totalEpisodes) {
                        Navigator.pop(context);
                        onEpisodeSelected(ep);
                      }
                    },
                    icon: const Icon(Icons.arrow_forward_rounded),
                  ),
                ),
              ),
              onSubmitted: (value) {
                final ep = int.tryParse(value);
                if (ep != null && ep > 0 && ep <= totalEpisodes) {
                  Navigator.pop(context);
                  onEpisodeSelected(ep);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
