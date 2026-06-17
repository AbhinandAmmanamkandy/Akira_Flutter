import 'dart:convert';
import 'favorite_service.dart';
import 'history_service.dart';
import 'theme_service.dart';
import '../models/anime.dart';

class BackupService {
  static String exportData() {
    final favorites = FavoriteService().favorites;
    final history = HistoryService().getAllHistory();
    final settings = ThemeService().getSettings();

    final Map<String, dynamic> data = {
      'version': 1,
      'exportDate': DateTime.now().toIso8601String(),
      'favorites': favorites.map((e) => e.toJson()).toList(),
      'history': history.map((key, value) => MapEntry(key, value.toJson())),
      'settings': settings,
    };

    return jsonEncode(data);
  }

  static Future<bool> importData(String jsonString) async {
    try {
      final Map<String, dynamic> data = jsonDecode(jsonString);
      
      if (data['favorites'] != null) {
        final List favoritesJson = data['favorites'];
        final List<Anime> favorites = favoritesJson.map((e) => Anime.fromJson(e)).toList();
        FavoriteService().setFavorites(favorites);
      }

      if (data['history'] != null) {
        final Map<String, dynamic> historyJson = data['history'];
        final Map<String, WatchHistory> history = historyJson.map(
          (key, value) => MapEntry(key, WatchHistory.fromJson(value))
        );
        HistoryService().setAllHistory(history);
      }

      if (data['settings'] != null) {
        await ThemeService().importSettings(data['settings']);
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}
