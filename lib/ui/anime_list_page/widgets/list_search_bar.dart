import 'package:flutter/material.dart';
import '../../widgets/glass_container.dart';

class ListSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSearch;
  final Function(String) onChanged;

  const ListSearchBar({
    super.key,
    required this.controller,
    required this.onSearch,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      left: 20,
      right: 20,
      child: Hero(
        tag: 'search_bar',
        child: Material(
          color: Colors.transparent,
          child: GlassContainer(
            borderRadius: 28,
            blur: 20,
            opacity: 0.2,
            withBlur: true,
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
              width: 2.0,
            ),
            child: TextField(
              controller: controller,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                hintText: 'Search for anime...',
                hintStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
                border: InputBorder.none,
                prefixIcon: Container(
                  margin: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.search_rounded,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                suffixIcon: controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        onPressed: () {
                          controller.clear();
                          onSearch('');
                          FocusScope.of(context).unfocus();
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 18),
              ),
              onSubmitted: onSearch,
              onChanged: onChanged,
            ),
          ),
        ),
      ),
    );
  }
}
