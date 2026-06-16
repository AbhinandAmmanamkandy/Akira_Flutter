import 'package:flutter/material.dart';
import '../../../../theme/akira_colors.dart';
import '../../../widgets/glass_container.dart';
import '../../../widgets/common_chip.dart';

class ListSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final bool isExpanded;
  final VoidCallback onExpand;
  final Function(String) onSearch;
  final Function(String) onChanged;

  const ListSearchBar({
    super.key,
    required this.controller,
    required this.isExpanded,
    required this.onExpand,
    required this.onSearch,
    required this.onChanged,
  });

  @override
  State<ListSearchBar> createState() => _ListSearchBarState();
}

class _ListSearchBarState extends State<ListSearchBar> {
  final FocusNode _focusNode = FocusNode();
  static final List<Map<String, dynamic>> _quickSearches = [
    {'label': 'Trending', 'icon': Icons.trending_up_rounded},
    {'label': 'Action', 'icon': Icons.local_fire_department_rounded},
    {'label': 'Comedy', 'icon': Icons.emoji_emotions_rounded},
    {'label': 'Romance', 'icon': Icons.favorite_rounded},
    {'label': 'Fantasy', 'icon': Icons.auto_awesome_rounded},
  ];

  @override
  void didUpdateWidget(ListSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded && !oldWidget.isExpanded) {
      if (ModalRoute.of(context)?.isCurrent ?? false) {
        _focusNode.requestFocus();
      }
    } else if (!widget.isExpanded && oldWidget.isExpanded) {
      _focusNode.unfocus();
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final screenWidth = MediaQuery.of(context).size.width;
    final expandedWidth = screenWidth - 40;
    const collapsedWidth = 130.0;

    return Positioned(
      bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      right: 20,
      child: Hero(
        tag: 'search_bar',
        child: Material(
          color: Colors.transparent,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.fastOutSlowIn,
            width: widget.isExpanded ? expandedWidth : collapsedWidth,
            height: widget.isExpanded ? 120 : 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.isExpanded ? 24 : 30),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: widget.isExpanded ? 0.08 : 0.18),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: GlassContainer(
              borderRadius: widget.isExpanded ? 24 : 30,
              blur: 20,
              opacity: 0.85,
              color: AkiraColors.getFloatingColor(colorScheme, isLight),
              withBlur: true,
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: widget.isExpanded ? 0.5 : 0.8),
                width: 2.0,
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: widget.isExpanded
                    ? OverflowBox(
                        key: const ValueKey('expanded'),
                        alignment: Alignment.topCenter,
                        minHeight: 0,
                        maxHeight: 120,
                        child: SizedBox(
                          height: 120,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextField(
                                    focusNode: _focusNode,
                                    controller: widget.controller,
                                    style: TextStyle(
                                      color: colorScheme.primary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    cursorColor: colorScheme.primary,
                                    decoration: InputDecoration(
                                      hintText: 'Search for anime...',
                                      hintStyle: TextStyle(
                                        color: colorScheme.primary.withValues(alpha: 0.6),
                                      ),
                                      border: InputBorder.none,
                                      prefixIcon: IconButton(
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        icon: Icon(
                                          Icons.arrow_back_rounded,
                                          color: colorScheme.primary,
                                        ),
                                        onPressed: widget.onExpand,
                                      ),
                                      suffixIcon: widget.controller.text.isNotEmpty
                                          ? IconButton(
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(),
                                              icon: Icon(Icons.close_rounded, size: 20, color: colorScheme.primary),
                                              onPressed: () {
                                                widget.controller.clear();
                                                widget.onSearch('');
                                              },
                                            )
                                          : null,
                                      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                                    ),
                                    onSubmitted: widget.onSearch,
                                    onChanged: widget.onChanged,
                                  ),
                                  Divider(
                                    height: 1,
                                    thickness: 1,
                                    color: colorScheme.primary.withValues(alpha: 0.1),
                                    indent: 16,
                                    endIndent: 16,
                                  ),
                                ],
                              ),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                child: Row(
                                  children: _quickSearches.map((data) => Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: CommonChip(
                                      label: data['label'],
                                      icon: data['icon'],
                                      onTap: () {
                                        widget.controller.text = data['label'];
                                        widget.onSearch(data['label']);
                                      },
                                    ),
                                  )).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : InkWell(
                        key: const ValueKey('collapsed'),
                        onTap: widget.onExpand,
                        borderRadius: BorderRadius.circular(30),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'SEARCH',
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.search_rounded,
                              color: colorScheme.primary.withValues(alpha: 0.7),
                              size: 24,
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
