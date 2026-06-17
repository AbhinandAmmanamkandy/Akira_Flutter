import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WatchHistory {
  final int episode;
  final Duration position;

  WatchHistory({required this.episode, required this.position});

  Map<String, dynamic> toJson() => {
    'episode': episode,
    'position': position.inMilliseconds,
  };

  factory WatchHistory.fromJson(Map<String, dynamic> json) => WatchHistory(
    episode: json['episode'] as int,
    position: Duration(milliseconds: json['position'] as int),
  );
}

class HistoryService extends ChangeNotifier {
  static final HistoryService _instance = HistoryService._internal();
  factory HistoryService() => _instance;
  HistoryService._internal();

  final Map<String, WatchHistory> _history = {};
  SharedPreferences? _prefs;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    final String? encoded = _prefs!.getString('watch_history');
    if (encoded != null) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(encoded);
        decoded.forEach((key, value) {
          _history[key] = WatchHistory.fromJson(value);
        });
      } catch (e) {
        // Silent error
      }
    }
    _initialized = true;
    notifyListeners();
  }

  WatchHistory? getHistory(String animeId) {
    return _history[animeId];
  }

  Map<String, WatchHistory> getAllHistory() {
    return Map.unmodifiable(_history);
  }

  void setAllHistory(Map<String, WatchHistory> newHistory) {
    _history.clear();
    _history.addAll(newHistory);
    _saveToDisk();
    notifyListeners();
  }

  void saveHistory(String animeId, int episode, Duration position) {
    // Only save if we have at least 1 second of progress
    if (position.inSeconds < 1) return;
    
    _history[animeId] = WatchHistory(episode: episode, position: position);
    _saveToDisk();
    notifyListeners();
  }

  void _saveToDisk() {
    if (_prefs == null) return;
    final Map<String, dynamic> toSave = {};
    _history.forEach((key, value) {
      toSave[key] = value.toJson();
    });
    _prefs!.setString('watch_history', jsonEncode(toSave));
  }
}
