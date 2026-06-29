import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:akira/models/anime.dart';
import 'package:akira/services/download_service.dart';
import 'package:akira/services/anime_stream_service.dart';
import 'package:akira/services/theme_service.dart';
import 'package:akira/ui/widgets/custom_status_indicator.dart';

class DownloadOptionsSheet extends StatefulWidget {
  final Anime anime;
  final int totalEpisodes;

  const DownloadOptionsSheet({
    super.key,
    required this.anime,
    required this.totalEpisodes,
  });

  @override
  State<DownloadOptionsSheet> createState() => _DownloadOptionsSheetState();
}

class _DownloadOptionsSheetState extends State<DownloadOptionsSheet> {
  late final TextEditingController _startController;
  late final TextEditingController _endController;
  int _startEpisode = 1;
  int _endEpisode = 1;
  Timer? _changeTimer;

  @override
  void initState() {
    super.initState();
    _endEpisode = widget.totalEpisodes;
    _startController = TextEditingController(text: '1');
    _endController = TextEditingController(text: widget.totalEpisodes.toString());
  }

  @override
  void dispose() {
    _changeTimer?.cancel();
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  void _onStartChanged(String value) {
    final val = int.tryParse(value);
    if (val != null && val >= 1 && val <= widget.totalEpisodes) {
      setState(() {
        _startEpisode = val;
        if (_startEpisode > _endEpisode) {
          _endEpisode = _startEpisode;
          _endController.text = _endEpisode.toString();
        }
      });
    }
  }

  void _onEndChanged(String value) {
    final val = int.tryParse(value);
    if (val != null && val >= 1 && val <= widget.totalEpisodes) {
      setState(() {
        _endEpisode = val;
        if (_endEpisode < _startEpisode) {
          _startEpisode = _endEpisode;
          _startController.text = _startEpisode.toString();
        }
      });
    }
  }

  void _startContinuousChange({required bool isIncrement, required bool isStartEpisode}) {
    _changeTimer?.cancel();
    _changeTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (isStartEpisode) {
        if (isIncrement) {
          if (_startEpisode < widget.totalEpisodes) {
            _onStartChanged((_startEpisode + 1).toString());
            _startController.text = _startEpisode.toString();
          }
        } else {
          if (_startEpisode > 1) {
            _onStartChanged((_startEpisode - 1).toString());
            _startController.text = _startEpisode.toString();
          }
        }
      } else {
        if (isIncrement) {
          if (_endEpisode < widget.totalEpisodes) {
            _onEndChanged((_endEpisode + 1).toString());
            _endController.text = _endEpisode.toString();
          }
        } else {
          if (_endEpisode > 1) {
            _onEndChanged((_endEpisode - 1).toString());
            _endController.text = _endEpisode.toString();
          }
        }
      }
    });
  }

  void _stopContinuousChange() {
    _changeTimer?.cancel();
    _changeTimer = null;
  }

  Future<void> _startDownloads(int start, int end) async {
    final downloadService = DownloadService();
    final api = AllAnimeApi();
    
    Navigator.pop(context);
    CustomStatusIndicator.show(
      context, 
      'Starting ${end - start + 1} downloads...', 
      Icons.downloading_rounded
    );

    for (int i = start; i <= end; i++) {
      try {
        final url = await api.getEpisodeVideoUrl(widget.anime.id, i.toString());
        if (url != null) {
          await downloadService.startDownload(widget.anime, i, url);
        }
      } catch (e) {
        debugPrint('Failed to download episode $i: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(24, 12, 24, MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Download Episodes',
            style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Select the range of episodes to download (Max: ${widget.totalEpisodes})',
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 32),
          
          Row(
            children: [
              Expanded(
                child: _buildEpisodeInput(
                  label: 'Start Episode',
                  controller: _startController,
                  onChanged: _onStartChanged,
                  onIncrement: () {
                    if (_startEpisode < widget.totalEpisodes) {
                      _onStartChanged((_startEpisode + 1).toString());
                      _startController.text = _startEpisode.toString();
                    }
                  },
                  onDecrement: () {
                    if (_startEpisode > 1) {
                      _onStartChanged((_startEpisode - 1).toString());
                      _startController.text = _startEpisode.toString();
                    }
                  },
                  onLongPressIncrement: () => _startContinuousChange(isIncrement: true, isStartEpisode: true),
                  onLongPressDecrement: () => _startContinuousChange(isIncrement: false, isStartEpisode: true),
                  onLongPressEnd: _stopContinuousChange,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildEpisodeInput(
                  label: 'End Episode',
                  controller: _endController,
                  onChanged: _onEndChanged,
                  onIncrement: () {
                    if (_endEpisode < widget.totalEpisodes) {
                      _onEndChanged((_endEpisode + 1).toString());
                      _endController.text = _endEpisode.toString();
                    }
                  },
                  onDecrement: () {
                    if (_endEpisode > 1) {
                      _onEndChanged((_endEpisode - 1).toString());
                      _endController.text = _endEpisode.toString();
                    }
                  },
                  onLongPressIncrement: () => _startContinuousChange(isIncrement: true, isStartEpisode: false),
                  onLongPressDecrement: () => _startContinuousChange(isIncrement: false, isStartEpisode: false),
                  onLongPressEnd: _stopContinuousChange,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 8,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
            ),
            child: RangeSlider(
              values: RangeValues(_startEpisode.toDouble(), _endEpisode.toDouble()),
              min: 1,
              max: widget.totalEpisodes.toDouble(),
              divisions: widget.totalEpisodes > 1 ? widget.totalEpisodes - 1 : 1,
              onChanged: (values) {
                setState(() {
                  _startEpisode = values.start.toInt();
                  _endEpisode = values.end.toInt();
                  _startController.text = _startEpisode.toString();
                  _endController.text = _endEpisode.toString();
                });
              },
            ),
          ),
          
          const SizedBox(height: 32),
          
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton.icon(
              onPressed: () => _startDownloads(_startEpisode, _endEpisode),
              icon: const Icon(Icons.download_rounded),
              label: Text('Download ${_endEpisode - _startEpisode + 1} Episodes'),
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  _startEpisode = 1;
                  _endEpisode = widget.totalEpisodes;
                  _startController.text = '1';
                  _endController.text = widget.totalEpisodes.toString();
                });
                _startDownloads(1, widget.totalEpisodes);
              },
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.5)),
              ),
              child: const Text('Download All Episodes'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEpisodeInput({
    required String label,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
    required VoidCallback onLongPressIncrement,
    required VoidCallback onLongPressDecrement,
    required VoidCallback onLongPressEnd,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              GestureDetector(
                onLongPressStart: (_) => onLongPressDecrement(),
                onLongPressEnd: (_) => onLongPressEnd(),
                onLongPressCancel: onLongPressEnd,
                child: IconButton(
                  onPressed: onDecrement,
                  icon: const Icon(Icons.remove_rounded, size: 20),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              GestureDetector(
                onLongPressStart: (_) => onLongPressIncrement(),
                onLongPressEnd: (_) => onLongPressEnd(),
                onLongPressCancel: onLongPressEnd,
                child: IconButton(
                  onPressed: onIncrement,
                  icon: const Icon(Icons.add_rounded, size: 20),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
