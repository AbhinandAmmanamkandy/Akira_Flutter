import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/anime.dart';
import 'notification_service.dart';

class DownloadItem {
  final String animeId;
  final int episode;
  final String animeName;
  final String? englishName;
  final String thumbnail;
  final String localPath;
  final DateTime timestamp;

  DownloadItem({
    required this.animeId,
    required this.episode,
    required this.animeName,
    this.englishName,
    required this.thumbnail,
    required this.localPath,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'animeId': animeId,
    'episode': episode,
    'animeName': animeName,
    'englishName': englishName,
    'thumbnail': thumbnail,
    'localPath': localPath,
    'timestamp': timestamp.toIso8601String(),
  };

  factory DownloadItem.fromJson(Map<String, dynamic> json) => DownloadItem(
    animeId: json['animeId'] as String,
    episode: json['episode'] as int,
    animeName: json['animeName'] as String,
    englishName: json['englishName'] as String?,
    thumbnail: json['thumbnail'] as String,
    localPath: json['localPath'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
  );
}

class DownloadProgress {
  final String animeName;
  final int episode;
  final double progress;

  DownloadProgress({
    required this.animeName,
    required this.episode,
    required this.progress,
  });
}

class DownloadService extends ChangeNotifier {
  static final DownloadService _instance = DownloadService._internal();
  factory DownloadService() => _instance;
  DownloadService._internal();

  final Map<String, DownloadItem> _downloads = {};
  final Map<String, DownloadProgress> _activeDownloads = {};
  SharedPreferences? _prefs;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    final String? encoded = _prefs!.getString('downloads');
    if (encoded != null) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(encoded);
        decoded.forEach((key, value) {
          _downloads[key] = DownloadItem.fromJson(value);
        });
      } catch (e) {}
    }
    _initialized = true;
    notifyListeners();
  }

  String _getKey(String animeId, int episode) => '${animeId}_$episode';

  DownloadItem? getDownload(String animeId, int episode) {
    return _downloads[_getKey(animeId, episode)];
  }

  double getProgress(String animeId, int episode) {
    return _activeDownloads[_getKey(animeId, episode)]?.progress ?? 0;
  }

  bool isDownloading(String animeId, int episode) {
    return _activeDownloads.containsKey(_getKey(animeId, episode));
  }

  List<DownloadProgress> get currentDownloads => _activeDownloads.values.toList();

  List<DownloadItem> getAllDownloads() {
    return _downloads.values.toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<void> startDownload(Anime anime, int episode, String url) async {
    final key = _getKey(anime.id, episode);
    if (_downloads.containsKey(key) || _activeDownloads.containsKey(key)) return;

    final notificationId = key.hashCode;
    final notificationService = NotificationService();

    _activeDownloads[key] = DownloadProgress(
      animeName: anime.name,
      episode: episode,
      progress: 0,
    );
    notifyListeners();

    try {
      final dir = await getApplicationDocumentsDirectory();
      final downloadsDir = Directory('${dir.path}/downloads');
      if (!downloadsDir.existsSync()) {
        downloadsDir.createSync();
      }

      // Determine extension from URL or default to .mp4
      String extension = '.mp4';
      if (url.contains('.m3u8')) extension = '.m3u8';
      else if (url.contains('.mkv')) extension = '.mkv';
      else if (url.contains('.webm')) extension = '.webm';

      final fileName = '${anime.id}_$episode$extension';
      final file = File('${downloadsDir.path}/$fileName');

      final request = http.Request('GET', Uri.parse(url));
      request.headers['Referer'] = 'https://youtu-chan.com';
      final response = await http.Client().send(request);

      final total = response.contentLength ?? 0;
      var received = 0;
      var lastNotificationProgress = -1;

      final IOSink sink = file.openWrite();

      await response.stream.listen((value) {
        sink.add(value);
        received += value.length;
        if (total > 0) {
          final progress = received / total;
          _activeDownloads[key] = DownloadProgress(
            animeName: anime.name,
            episode: episode,
            progress: progress,
          );
          
          // Update notification every 1% to avoid overwhelming the system
          final currentProgressInt = (progress * 100).toInt();
          if (currentProgressInt > lastNotificationProgress) {
            lastNotificationProgress = currentProgressInt;
            final animeTitle = anime.englishName ?? anime.name;
            notificationService.showDownloadProgress(
              id: notificationId,
              title: 'Downloading $animeTitle',
              body: 'Episode $episode • $currentProgressInt%',
              progress: currentProgressInt,
              maxProgress: 100,
            );
          }
          
          notifyListeners();
        }
      }).asFuture();

      await sink.close();

      _downloads[key] = DownloadItem(
        animeId: anime.id,
        episode: episode,
        animeName: anime.name,
        englishName: anime.englishName,
        thumbnail: anime.thumbnail ?? '',
        localPath: file.path,
      );
      _activeDownloads.remove(key);
      _saveToDisk();
      
      await notificationService.cancelNotification(notificationId);
      final finalAnimeTitle = anime.englishName ?? anime.name;
      await notificationService.showDownloadComplete(
        id: notificationId + 1, // Different ID so it doesn't replace the progress one if it's still finishing
        title: 'Download Complete',
        body: '$finalAnimeTitle - Episode $episode',
      );
      
      notifyListeners();
    } catch (e) {
      _activeDownloads.remove(key);
      await notificationService.cancelNotification(notificationId);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteDownload(String animeId, int episode) async {
    final key = _getKey(animeId, episode);
    final item = _downloads[key];
    if (item != null) {
      try {
        final file = File(item.localPath);
        if (file.existsSync()) {
          file.deleteSync();
        }
      } catch (e) {}
      _downloads.remove(key);
      _saveToDisk();
      notifyListeners();
    }
  }

  void _saveToDisk() {
    if (_prefs == null) return;
    final Map<String, dynamic> toSave = {};
    _downloads.forEach((key, value) {
      toSave[key] = value.toJson();
    });
    _prefs!.setString('downloads', jsonEncode(toSave));
  }
}
