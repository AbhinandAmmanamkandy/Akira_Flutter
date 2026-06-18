import 'package:flutter/material.dart';
import '../../../../theme/akira_colors.dart';
import '../../../widgets/glass_container.dart';

class BottomSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final Function(String) onSearch;
  final Function(String) onChanged;
  final VoidCallback? onClear;
  final bool isManga;

  const BottomSearchBar({
    super.key,
    required this.controller,
    this.focusNode,
    required this.onSearch,
    required this.onChanged,
    this.onClear,
    this.isManga = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Positioned(
      bottom: bottomInset + 20,
      left: 20,
      right: 20,
      child: Material(
        color: Colors.transparent,
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: GlassContainer(
            borderRadius: 30,
            blur: 8,
            opacity: 0.15,
            withBlur: true,
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.2),
              width: 1,
            ),
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              cursorColor: colorScheme.primary,
              decoration: InputDecoration(
                hintText: isManga ? 'Search manga...' : 'Search anime...',
                hintStyle: TextStyle(
                  color: AkiraColors.getHintSubtextColor(colorScheme, isLight),
                  fontWeight: FontWeight.normal,
                ),
                border: InputBorder.none,
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: colorScheme.primary,
                  size: 24,
                ),
                suffixIcon: controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                        onPressed: () {
                          controller.clear();
                          onChanged('');
                          onClear?.call();
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
