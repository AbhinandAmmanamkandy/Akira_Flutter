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
  final String animeId;
  final String animeName;
  final int episode;
  final double progress;
  final bool isPaused;
  final String url;
  final Anime anime;

  DownloadProgress({
    required this.animeId,
    required this.animeName,
    required this.episode,
    required this.progress,
    this.isPaused = false,
    required this.url,
    required this.anime,
  });

  DownloadProgress copyWith({
    double? progress,
    bool? isPaused,
  }) {
    return DownloadProgress(
      animeId: animeId,
      animeName: animeName,
      episode: episode,
      progress: progress ?? this.progress,
      isPaused: isPaused ?? this.isPaused,
      url: url,
      anime: anime,
    );
  }

  Map<String, dynamic> toJson() => {
    'animeId': animeId,
    'animeName': animeName,
    'episode': episode,
    'progress': progress,
    'isPaused': isPaused,
    'url': url,
    'anime': anime.toJson(),
  };

  factory DownloadProgress.fromJson(Map<String, dynamic> json) => DownloadProgress(
    animeId: json['animeId'] as String,
    animeName: json['animeName'] as String,
    episode: json['episode'] as int,
    progress: (json['progress'] as num).toDouble(),
    isPaused: json['isPaused'] as bool? ?? false,
    url: json['url'] as String,
    anime: Anime.fromJson(json['anime'] as Map<String, dynamic>),
  );
}

class DownloadService extends ChangeNotifier {
  static final DownloadService _instance = DownloadService._internal();
  factory DownloadService() => _instance;
  DownloadService._internal();

  final Map<String, DownloadItem> _downloads = {};
  final Map<String, DownloadProgress> _activeDownloads = {};
  final Map<String, StreamSubscription> _subscriptions = {};
  SharedPreferences? _prefs;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    
    // Load completed downloads
    final String? encoded = _prefs!.getString('downloads');
    if (encoded != null) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(encoded);
        decoded.forEach((key, value) {
          _downloads[key] = DownloadItem.fromJson(value);
        });
      } catch (e) {}
    }

    // Load active downloads
    final String? encodedActive = _prefs!.getString('active_downloads');
    if (encodedActive != null) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(encodedActive);
        decoded.forEach((key, value) {
          final progress = DownloadProgress.fromJson(value);
          // All loaded active downloads should start as paused
          _activeDownloads[key] = progress.copyWith(isPaused: true);
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
    if (_downloads.containsKey(key)) return;
    if (_activeDownloads.containsKey(key) && !_activeDownloads[key]!.isPaused) return;

    final notificationId = key.hashCode;
    final notificationService = NotificationService();

    final currentProgress = _activeDownloads[key]?.progress ?? 0;
    _activeDownloads[key] = DownloadProgress(
      animeId: anime.id,
      animeName: anime.name,
      episode: episode,
      progress: currentProgress,
      url: url,
      anime: anime,
      isPaused: false,
    );
    notifyListeners();

    try {
      final dir = await getApplicationDocumentsDirectory();
      final downloadsDir = Directory('${dir.path}/downloads');
      if (!downloadsDir.existsSync()) {
        downloadsDir.createSync();
      }

      String extension = '.mp4';
      if (url.contains('.m3u8')) extension = '.m3u8';
      else if (url.contains('.mkv')) extension = '.mkv';
      else if (url.contains('.webm')) extension = '.webm';

      final fileName = '${anime.id}_$episode$extension';
      final file = File('${downloadsDir.path}/$fileName');
      
      int existingLength = 0;
      if (file.existsSync()) {
        existingLength = file.lengthSync();
      }

      final request = http.Request('GET', Uri.parse(url));
      request.headers['Referer'] = 'https://youtu-chan.com';
      if (existingLength > 0) {
        request.headers['Range'] = 'bytes=$existingLength-';
      }
      
      final response = await http.Client().send(request);

      // If server doesn't support range or we are starting fresh
      final isResuming = response.statusCode == 206;
      final total = (response.contentLength ?? 0) + (isResuming ? existingLength : 0);
      var received = isResuming ? existingLength : 0;
      var lastNotificationProgress = -1;

      final IOSink sink = file.openWrite(mode: isResuming ? FileMode.append : FileMode.write);

      final subscription = response.stream.listen((value) {
        sink.add(value);
        received += value.length;
        if (total > 0) {
          final progress = received / total;
          _activeDownloads[key] = _activeDownloads[key]!.copyWith(progress: progress);
          
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
      });

      _subscriptions[key] = subscription;

      await subscription.asFuture();
      await sink.close();
      _subscriptions.remove(key);

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
        id: notificationId + 1,
        title: 'Download Complete',
        body: '$finalAnimeTitle - Episode $episode',
      );
      
      notifyListeners();
    } catch (e) {
      if (_activeDownloads[key]?.isPaused ?? false) {
        // Handled by pauseDownload
      } else {
        _activeDownloads.remove(key);
        _subscriptions.remove(key);
        await notificationService.cancelNotification(notificationId);
        notifyListeners();
        rethrow;
      }
    }
  }

  void pauseDownload(String animeId, int episode) {
    final key = _getKey(animeId, episode);
    final subscription = _subscriptions[key];
    if (subscription != null) {
      subscription.cancel();
      _subscriptions.remove(key);
    }
    if (_activeDownloads.containsKey(key)) {
      _activeDownloads[key] = _activeDownloads[key]!.copyWith(isPaused: true);
      _saveToDisk();
      notifyListeners();
    }
  }

  void resumeDownload(String animeId, int episode) {
    final key = _getKey(animeId, episode);
    final progress = _activeDownloads[key];
    if (progress != null && progress.isPaused) {
      startDownload(progress.anime, progress.episode, progress.url);
    }
  }

  Future<void> deleteDownload(String animeId, int episode) async {
    final key = _getKey(animeId, episode);
    
    // 1. Handle Active/Paused Download
    final activeProgress = _activeDownloads[key];
    if (activeProgress != null) {
      pauseDownload(animeId, episode);
      
      try {
        final dir = await getApplicationDocumentsDirectory();
        final downloadsDir = Directory('${dir.path}/downloads');
        
        String url = activeProgress.url;
        String extension = '.mp4';
        if (url.contains('.m3u8')) extension = '.m3u8';
        else if (url.contains('.mkv')) extension = '.mkv';
        else if (url.contains('.webm')) extension = '.webm';

        final fileName = '${animeId}_$episode$extension';
        final file = File('${downloadsDir.path}/$fileName');
        if (file.existsSync()) {
          file.deleteSync();
        }
      } catch (e) {}
      
      _activeDownloads.remove(key);
    }

    // 2. Handle Completed Download
    final item = _downloads[key];
    if (item != null) {
      try {
        final file = File(item.localPath);
        if (file.existsSync()) {
          file.deleteSync();
        }
      } catch (e) {}
      _downloads.remove(key);
    }
    
    _saveToDisk();
    notifyListeners();
  }

  void _saveToDisk() {
    if (_prefs == null) return;
    
    // Save completed downloads
    final Map<String, dynamic> toSave = {};
    _downloads.forEach((key, value) {
      toSave[key] = value.toJson();
    });
    _prefs!.setString('downloads', jsonEncode(toSave));

    // Save active downloads
    final Map<String, dynamic> activeToSave = {};
    _activeDownloads.forEach((key, value) {
      activeToSave[key] = value.toJson();
    });
    _prefs!.setString('active_downloads', jsonEncode(activeToSave));
  }
}
