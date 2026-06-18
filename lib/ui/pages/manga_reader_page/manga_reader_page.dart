import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:akira/models/anime.dart';
import 'package:akira/models/anime_details.dart';
import 'package:akira/services/manga_read_service.dart';
import 'package:akira/services/history_service.dart';
import 'package:akira/services/theme_service.dart';
import 'package:akira/ui/widgets/glass_container.dart';
import 'package:akira/ui/widgets/custom_status_indicator.dart';
import 'package:akira/theme/akira_colors.dart';
import 'widgets/manga_page_view.dart';
import 'widgets/manga_controls.dart';

class MangaReaderPage extends StatefulWidget {
  final Anime anime;
  final AnimeDetails details;

  const MangaReaderPage({
    super.key,
    required this.anime,
    required this.details,
  });

  @override
  State<MangaReaderPage> createState() => _MangaReaderPageState();
}

class _MangaReaderPageState extends State<MangaReaderPage> {
  final HistoryService _historyService = HistoryService();
  final PageController _pageController = PageController();
  ScrollPhysics _physics = const BouncingScrollPhysics();
  
  bool _isLoading = true;
  String? _error;
  List<String> _pages = [];
  String _currentChapter = '1';
  int _currentPage = 0;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _historyService.init().then((_) {
      final history = _historyService.getHistory(widget.anime.id);
      if (history != null) {
        setState(() {
          _currentChapter = history.episode.toString();
          _currentPage = history.position.inSeconds;
        });
      } else if (widget.details.availableEpisodes.isNotEmpty) {
        setState(() {
          // Use the first available chapter if no history
          _currentChapter = widget.details.availableEpisodes.first;
        });
      }
      
      // Double check if _currentChapter exists in availableEpisodes
      // Sometimes history might have an old chapter
      if (widget.details.availableEpisodes.isNotEmpty && 
          !widget.details.availableEpisodes.contains(_currentChapter)) {
        _currentChapter = widget.details.availableEpisodes.first;
      }

      _loadChapter(_currentChapter, initialPage: _currentPage);
    });
  }

  Future<void> _loadChapter(String chapter, {int initialPage = 0}) async {
    setState(() {
      _isLoading = true;
      _error = null;
      _currentChapter = chapter;
    });

    try {
      final response = await AllMangaApi.getChapterResponse(widget.anime.id, chapter);
      final data = jsonDecode(response);
      final tobeparsed = data['data']?['tobeparsed'];
      
      if (tobeparsed == null) {
        setState(() {
          _isLoading = false;
          _error = 'No pages found for Chapter $chapter';
        });
        return;
      }

      final decrypted = AllMangaApi.decryptToBeParsed(tobeparsed);
      final pages = AllMangaApi.parseChapterPages(decrypted);

      if (pages.isEmpty) {
        setState(() {
          _isLoading = false;
          _error = 'Failed to parse pages for Chapter $chapter';
        });
        return;
      }

      setState(() {
        _pages = pages;
        _isLoading = false;
        _currentPage = initialPage.clamp(0, pages.length - 1);
      });
      
      if (_pageController.hasClients) {
        _pageController.jumpToPage(_currentPage);
      } else {
        // If not attached yet, we can't jump, but the PageController(initialPage: ...) handles it
        // actually let's re-init controller if needed or just use state
      }
      
      _saveProgress();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Error loading chapter: $e';
      });
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
    _saveProgress();
  }

  void _saveProgress() {
    _historyService.saveHistory(
      widget.anime.id,
      int.tryParse(_currentChapter) ?? 1,
      Duration(seconds: _currentPage),
      force: true,
    );
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final bgColor = Colors.black; // Typically manga readers use black background

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // Manga Pages
          if (!_isLoading && _error == null)
            MangaPageView(
              pages: _pages,
              controller: _pageController,
              physics: _physics,
              onPageChanged: _onPageChanged,
              onTap: _toggleControls,
              onZoomChanged: (isZoomed) {
                setState(() {
                  _physics = isZoomed 
                      ? const NeverScrollableScrollPhysics() 
                      : const BouncingScrollPhysics();
                });
              },
            ),

          // Loading Indicator
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),

          // Error Message
          if (_error != null)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_error!, style: const TextStyle(color: Colors.white)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _loadChapter(_currentChapter.toString()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),

          // Controls Overlay
          if (_showControls)
            MangaControls(
              anime: widget.anime,
              details: widget.details,
              currentChapter: _currentChapter,
              currentPage: _currentPage,
              totalPages: _pages.length,
              onChapterSelected: (chapter) => _loadChapter(chapter.toString()),
              onPageSelected: (page) {
                _pageController.animateToPage(
                  page,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              onBack: () => Navigator.pop(context),
            ),
        ],
      ),
    );
  }
}
