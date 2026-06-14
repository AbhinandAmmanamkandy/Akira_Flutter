import 'package:flutter/material.dart';

class ThemeService extends ChangeNotifier {
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();

  bool _isMaterialUI = true;
  bool get isMaterialUI => _isMaterialUI;

  bool _useSystemAccent = true;
  bool get useSystemAccent => _useSystemAccent;

  int _accentShade = 0; // 0: Primary, 1: Secondary, 2: Tertiary
  int get accentShade => _accentShade;

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  void toggleMaterialUI() {
    _isMaterialUI = !_isMaterialUI;
    if (!_isMaterialUI) {
      _useSystemAccent = false;
    }
    notifyListeners();
  }

  void setAccentShade(int shade) {
    _accentShade = shade;
    notifyListeners();
  }

  void toggleSystemAccent() {
    _useSystemAccent = !_useSystemAccent;
    notifyListeners();
  }

  void toggleFollowSystem(bool follow) {
    _themeMode = follow ? ThemeMode.system : ThemeMode.dark;
    notifyListeners();
  }

  void toggleDarkMode(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}
