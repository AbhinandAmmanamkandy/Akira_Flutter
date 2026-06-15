import 'package:flutter/material.dart';
import '../models/anime.dart';

class FavoriteService extends ChangeNotifier {
  static final FavoriteService _instance = FavoriteService._internal();
  factory FavoriteService() => _instance;
  FavoriteService._internal();

  final List<Anime> _favorites = [];

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
    notifyListeners();
  }
}
