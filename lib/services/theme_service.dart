import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();

  late SharedPreferences _prefs;

  bool _isMaterialUI = true;
  bool get isMaterialUI => _isMaterialUI;

  bool _useSystemAccent = true;
  bool get useSystemAccent => _useSystemAccent;

  int _accentShade = 0; // 0: Primary, 1: Secondary, 2: Tertiary
  int get accentShade => _accentShade;

  int _customColorIndex = 0;
  int get customColorIndex => _customColorIndex;

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  bool _allowAdult = false;
  bool get allowAdult => _allowAdult;

  bool _allowUnknown = false;
  bool get allowUnknown => _allowUnknown;

  bool _useGlassTheme = false;
  bool get useGlassTheme => _useGlassTheme;
  
  bool _useOverscrollToClose = true;
  bool get useOverscrollToClose => _useOverscrollToClose;
  
  bool _isFirstOpen = true;
  bool get isFirstOpen => _isFirstOpen;

  String _username = '';
  String get username => _username;

  String _gender = ''; // 'male', 'female', or ''
  String get gender => _gender;
  
  int? _lastSystemAccentColor;
  int? get lastSystemAccentColor => _lastSystemAccentColor;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _isMaterialUI = _prefs.getBool('isMaterialUI') ?? true;
    _useSystemAccent = _prefs.getBool('useSystemAccent') ?? true;
    _accentShade = _prefs.getInt('accentShade') ?? 0;
    _customColorIndex = _prefs.getInt('customColorIndex') ?? 0;
    _allowAdult = _prefs.getBool('allowAdult') ?? false;
    _allowUnknown = _prefs.getBool('allowUnknown') ?? false;
    _useGlassTheme = _prefs.getBool('useGlassTheme') ?? false;
    _useOverscrollToClose = _prefs.getBool('useOverscrollToClose') ?? true;
    _isFirstOpen = _prefs.getBool('isFirstOpen') ?? true;
    _username = _prefs.getString('username') ?? '';
    _gender = _prefs.getString('gender') ?? '';
    _lastSystemAccentColor = _prefs.getInt('lastSystemAccentColor');
    
    final themeModeIndex = _prefs.getInt('themeMode') ?? 0;
    _themeMode = ThemeMode.values[themeModeIndex];
    
    notifyListeners();
  }

  void completeFirstOpen(String name, String gender) {
    _isFirstOpen = false;
    _username = name;
    _gender = gender;
    _prefs.setBool('isFirstOpen', false);
    _prefs.setString('username', name);
    _prefs.setString('gender', gender);
    notifyListeners();
  }

  void saveSystemAccentColor(Color color) {
    if (_lastSystemAccentColor != color.toARGB32()) {
      _lastSystemAccentColor = color.toARGB32();
      _prefs.setInt('lastSystemAccentColor', color.toARGB32());
    }
  }

  void toggleGlassTheme() {
    _useGlassTheme = !_useGlassTheme;
    _prefs.setBool('useGlassTheme', _useGlassTheme);
    notifyListeners();
  }
  
  void toggleOverscrollToClose() {
    _useOverscrollToClose = !_useOverscrollToClose;
    _prefs.setBool('useOverscrollToClose', _useOverscrollToClose);
    notifyListeners();
  }

  void toggleMaterialUI() {
    _isMaterialUI = !_isMaterialUI;
    if (!_isMaterialUI) {
      _useSystemAccent = false;
      _prefs.setBool('useSystemAccent', false);
    }
    _prefs.setBool('isMaterialUI', _isMaterialUI);
    notifyListeners();
  }

  void toggleAllowAdult() {
    _allowAdult = !_allowAdult;
    _prefs.setBool('allowAdult', _allowAdult);
    notifyListeners();
  }

  void toggleAllowUnknown() {
    _allowUnknown = !_allowUnknown;
    _prefs.setBool('allowUnknown', _allowUnknown);
    notifyListeners();
  }

  void setAccentShade(int shade) {
    _accentShade = shade;
    _prefs.setInt('accentShade', shade);
    notifyListeners();
  }

  void setCustomColorIndex(int index) {
    _customColorIndex = index;
    _prefs.setInt('customColorIndex', index);
    notifyListeners();
  }

  void toggleSystemAccent() {
    _useSystemAccent = !_useSystemAccent;
    _prefs.setBool('useSystemAccent', _useSystemAccent);
    notifyListeners();
  }

  void toggleFollowSystem(bool follow) {
    _themeMode = follow ? ThemeMode.system : ThemeMode.dark;
    _prefs.setInt('themeMode', _themeMode.index);
    notifyListeners();
  }

  void toggleDarkMode(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    _prefs.setInt('themeMode', _themeMode.index);
    notifyListeners();
  }
}
