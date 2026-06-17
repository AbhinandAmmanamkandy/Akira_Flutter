import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/anime.dart';

class FavoriteService extends ChangeNotifier {
  static final FavoriteService _instance = FavoriteService._internal();
  factory FavoriteService() => _instance;
  FavoriteService._internal();

  final List<Anime> _favorites = [];
  SharedPreferences? _prefs;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    final String? encoded = _prefs!.getString('favorites');
    if (encoded != null) {
      try {
        final List decoded = jsonDecode(encoded);
        _favorites.addAll(decoded.map((item) => Anime.fromJson(item)));
      } catch (e) {
        // Silent error
      }
    }
    _initialized = true;
    notifyListeners();
  }

  List<Anime> get favorites => List.unmodifiable(_favorites);

  bool isFavorite(String id) {
    return _favorites.any((anime) => anime.id == id);
  }

  void toggleFavorite(Anime anime) {
    final index = _favorites.indexWhere((item) => item.id == anime.id);
    if (index >= 0) {
      _favorites.removeAt(index);
    } else {
      _favorites.add(anime);
    }
    _saveToDisk();
    notifyListeners();
  }

  void _saveToDisk() {
    if (_prefs == null) return;
    final List<Map<String, dynamic>> toSave = _favorites.map((e) => e.toJson()).toList();
    _prefs!.setString('favorites', jsonEncode(toSave));
  }

  // Helper for backup/restore
  void setFavorites(List<Anime> newFavorites) {
    _favorites.clear();
    _favorites.addAll(newFavorites);
    _saveToDisk();
    notifyListeners();
  }
}
