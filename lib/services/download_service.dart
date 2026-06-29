import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/anime.dart';
import 'notification_service.dart';
import 'theme_service.dart';

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
  final List<double>? threadProgresses;

  DownloadProgress({
    required this.animeId,
    required this.animeName,
    required this.episode,
    required this.progress,
    this.isPaused = false,
    required this.url,
    required this.anime,
    this.threadProgresses,
  });

  DownloadProgress copyWith({
    double? progress,
    bool? isPaused,
    List<double>? threadProgresses,
  }) {
    return DownloadProgress(
      animeId: animeId,
      animeName: animeName,
      episode: episode,
      progress: progress ?? this.progress,
      isPaused: isPaused ?? this.isPaused,
      url: url,
      anime: anime,
      threadProgresses: threadProgresses ?? this.threadProgresses,
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
    'threadProgresses': threadProgresses,
  };

  factory DownloadProgress.fromJson(Map<String, dynamic> json) => DownloadProgress(
    animeId: json['animeId'] as String,
    animeName: json['animeName'] as String,
    episode: json['episode'] as int,
    progress: (json['progress'] as num).toDouble(),
    isPaused: json['isPaused'] as bool? ?? false,
    url: json['url'] as String,
    anime: Anime.fromJson(json['anime'] as Map<String, dynamic>),
    threadProgresses: (json['threadProgresses'] as List?)?.map((e) => (e as num).toDouble()).toList(),
  );
}

class DownloadService extends ChangeNotifier {
  static final DownloadService _instance = DownloadService._internal();
  factory DownloadService() => _instance;
  DownloadService._internal();

  final Map<String, DownloadItem> _downloads = {};
  final Map<String, DownloadProgress> _activeDownloads = {};
  final Map<String, List<StreamSubscription>> _subscriptions = {};
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
    final item = _downloads[_getKey(animeId, episode)];
    if (item != null && !File(item.localPath).existsSync()) {
      // Clean up if file is missing
      _downloads.remove(_getKey(animeId, episode));
      _saveToDisk();
      return null;
    }
    return item;
  }

  double getProgress(String animeId, int episode) {
    return _activeDownloads[_getKey(animeId, episode)]?.progress ?? 0;
  }

  bool isDownloading(String animeId, int episode) {
    return _activeDownloads.containsKey(_getKey(animeId, episode));
  }

  List<DownloadProgress> get currentDownloads => _activeDownloads.values.toList();

  List<DownloadItem> getAllDownloads() {
    // Filter out items where the file has been deleted manually
    final List<DownloadItem> validDownloads = [];
    bool needsSave = false;

    _downloads.forEach((key, item) {
      if (File(item.localPath).existsSync()) {
        validDownloads.add(item);
      } else {
        needsSave = true;
      }
    });

    if (needsSave) {
      _downloads.removeWhere((key, item) => !File(item.localPath).existsSync());
      _saveToDisk();
    }

    return validDownloads..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<void> startDownload(Anime anime, int episode, String url) async {
    final key = _getKey(anime.id, episode);
    if (_downloads.containsKey(key)) return;
    if (_activeDownloads.containsKey(key) && !_activeDownloads[key]!.isPaused) return;

    final threads = ThemeService().downloadThreads;
    
    // For now, only use multi-threading for new downloads that aren't m3u8
    // Resuming multi-threaded downloads requires metadata which we don't have yet
    bool canUseMultiThreads = threads > 1 && !url.contains('.m3u8');
    
    if (canUseMultiThreads) {
      try {
        await _startMultiThreadedDownload(anime, episode, url, threads);
      } catch (e) {
        // Fallback to single threaded if multi-threaded fails (e.g. Range not supported)
        await _startSingleThreadedDownload(anime, episode, url);
      }
    } else {
      await _startSingleThreadedDownload(anime, episode, url);
    }
  }

  Future<void> _startSingleThreadedDownload(Anime anime, int episode, String url) async {
    final key = _getKey(anime.id, episode);
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

      _subscriptions[key] = [subscription];

      await subscription.asFuture();
      await sink.close();
      _subscriptions.remove(key);

      _finishDownload(anime, episode, file.path, key, notificationId);
    } catch (e) {
      _handleDownloadError(key, notificationId);
      rethrow;
    }
  }

  Future<void> _startMultiThreadedDownload(Anime anime, int episode, String url, int threads) async {
    final key = _getKey(anime.id, episode);
    final notificationId = key.hashCode;
    final notificationService = NotificationService();

    // 1. Get file size and check for Range support
    final headResponse = await http.head(Uri.parse(url), headers: {'Referer': 'https://youtu-chan.com'});
    final total = int.tryParse(headResponse.headers['content-length'] ?? '') ?? 0;
    final acceptRanges = headResponse.headers['accept-ranges'] == 'bytes';

    if (total == 0 || !acceptRanges) {
      throw Exception('Multi-threaded download not supported by server');
    }

    _activeDownloads[key] = DownloadProgress(
      animeId: anime.id,
      animeName: anime.name,
      episode: episode,
      progress: 0,
      url: url,
      anime: anime,
      isPaused: false,
    );
    notifyListeners();

    final dir = await getApplicationDocumentsDirectory();
    final fileName = '${anime.id}_$episode.mp4'; // Default to mp4 for multi-thread
    final file = File('${dir.path}/downloads/$fileName');
    if (!file.parent.existsSync()) file.parent.createSync();

    final raf = await file.open(mode: FileMode.write);
    await raf.truncate(total);

    final chunkSize = (total / threads).ceil();
    final List<StreamSubscription> subs = [];
    _subscriptions[key] = subs;

    int totalReceived = 0;
    var lastNotificationProgress = -1;
    int completedThreads = 0;
    final Completer<void> completer = Completer<void>();
    final List<double> threadProgressValues = List.filled(threads, 0.0);
    
    // Use a lock to prevent concurrent writes to the same RandomAccessFile
    Future<void> writeLock = Future.value();

    for (int i = 0; i < threads; i++) {
      final threadIndex = i;
      final start = i * chunkSize;
      final end = (i == threads - 1) ? total - 1 : (i + 1) * chunkSize - 1;
      final currentThreadTotal = end - start + 1;

      final request = http.Request('GET', Uri.parse(url));
      request.headers['Referer'] = 'https://youtu-chan.com';
      request.headers['Range'] = 'bytes=$start-$end';

      final client = http.Client();
      final response = await client.send(request);
      
      int chunkReceived = 0;

      final sub = response.stream.listen((value) {
        final writeOffset = start + chunkReceived;
        chunkReceived += value.length;
        totalReceived += value.length;
        
        threadProgressValues[threadIndex] = chunkReceived / currentThreadTotal;

        // Serialize the write operation
        writeLock = writeLock.then((_) async {
          await raf.setPosition(writeOffset);
          await raf.writeFrom(value);
        });

        final progress = totalReceived / total;
        _activeDownloads[key] = _activeDownloads[key]!.copyWith(
          progress: progress,
          threadProgresses: List.from(threadProgressValues),
        );
        // ...
        
        final currentProgressInt = (progress * 100).toInt();
        if (currentProgressInt > lastNotificationProgress) {
          lastNotificationProgress = currentProgressInt;
          final animeTitle = anime.englishName ?? anime.name;
          notificationService.showDownloadProgress(
            id: notificationId,
            title: 'Downloading $animeTitle (Multi-thread)',
            body: 'Episode $episode • $currentProgressInt%',
            progress: currentProgressInt,
            maxProgress: 100,
          );
        }
        notifyListeners();
      }, onDone: () {
        completedThreads++;
        if (completedThreads == threads) {
          writeLock.then((_) => completer.complete());
        }
      }, onError: (e) {
        if (!completer.isCompleted) completer.completeError(e);
      });

      subs.add(sub);
    }

    try {
      await completer.future;
      await raf.close();
      _subscriptions.remove(key);
      _finishDownload(anime, episode, file.path, key, notificationId);
    } catch (e) {
      await raf.close();
      _handleDownloadError(key, notificationId);
      rethrow;
    }
  }

  void _finishDownload(Anime anime, int episode, String filePath, String key, int notificationId) {
    _downloads[key] = DownloadItem(
      animeId: anime.id,
      episode: episode,
      animeName: anime.name,
      englishName: anime.englishName,
      thumbnail: anime.thumbnail ?? '',
      localPath: filePath,
    );
    _activeDownloads.remove(key);
    _saveToDisk();
    
    NotificationService().cancelNotification(notificationId);
    final finalAnimeTitle = anime.englishName ?? anime.name;
    NotificationService().showDownloadComplete(
      id: notificationId + 1,
      title: 'Download Complete',
      body: '$finalAnimeTitle - Episode $episode',
    );
    
    notifyListeners();
  }

  void _handleDownloadError(String key, int notificationId) {
    if (_activeDownloads[key]?.isPaused ?? false) {
      // Handled
    } else {
      _activeDownloads.remove(key);
      _subscriptions.remove(key);
      NotificationService().cancelNotification(notificationId);
      notifyListeners();
    }
  }

  void pauseDownload(String animeId, int episode) {
    final key = _getKey(animeId, episode);
    final subs = _subscriptions[key];
    if (subs != null) {
      for (var sub in subs) {
        sub.cancel();
      }
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
