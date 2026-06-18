import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
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

  static Future<void> exportToFile() async {
    final data = exportData();
    final date = DateTime.now().toString().split(' ')[0];
    final fileName = 'akira_backup_$date.json';

    if (Platform.isAndroid || Platform.isIOS) {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsString(data);
      await Share.shareXFiles([XFile(file.path)], text: 'Akira Backup Data');
    } else {
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Backup',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        final file = File(result);
        await file.writeAsString(data);
      }
    }
  }

  static Future<bool> importFromFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      return await importData(content);
    }
    return false;
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
