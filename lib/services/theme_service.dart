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

  bool _showTooltips = true;
  bool get showTooltips => _showTooltips;
  
  int _downloadThreads = 1;
  int get downloadThreads => _downloadThreads;
  
  bool _isFirstOpen = true;
  bool get isFirstOpen => _isFirstOpen;

  String _username = '';
  String get username => _username;

  String _gender = ''; // 'male', 'female', or ''
  String get gender => _gender;
  
  int? _lastSystemAccentColor;
  int? get lastSystemAccentColor => _lastSystemAccentColor;

  List<String> _pinnedChips = [];
  List<String> get pinnedChips => _pinnedChips;

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
    _showTooltips = _prefs.getBool('showTooltips') ?? true;
    _downloadThreads = _prefs.getInt('downloadThreads') ?? 1;
    _isFirstOpen = _prefs.getBool('isFirstOpen') ?? true;
    _username = _prefs.getString('username') ?? '';
    _gender = _prefs.getString('gender') ?? '';
    _lastSystemAccentColor = _prefs.getInt('lastSystemAccentColor');
    
    _pinnedChips = _prefs.getStringList('pinnedChips') ?? ['Action', 'Comedy', 'Romance', 'Fantasy', 'Horror'];
    
    final themeModeIndex = _prefs.getInt('themeMode') ?? 0;
    _themeMode = ThemeMode.values[themeModeIndex];
    
    notifyListeners();
  }

  Map<String, dynamic> getSettings() {
    return {
      'isMaterialUI': _isMaterialUI,
      'useSystemAccent': _useSystemAccent,
      'accentShade': _accentShade,
      'customColorIndex': _customColorIndex,
      'themeMode': _themeMode.index,
      'allowAdult': _allowAdult,
      'allowUnknown': _allowUnknown,
      'useGlassTheme': _useGlassTheme,
      'useOverscrollToClose': _useOverscrollToClose,
      'showTooltips': _showTooltips,
      'downloadThreads': _downloadThreads,
      'username': _username,
      'gender': _gender,
    };
  }

  Future<void> importSettings(Map<String, dynamic> settings) async {
    if (settings.containsKey('isMaterialUI')) {
      _isMaterialUI = settings['isMaterialUI'];
      _prefs.setBool('isMaterialUI', _isMaterialUI);
    }
    if (settings.containsKey('useSystemAccent')) {
      _useSystemAccent = settings['useSystemAccent'];
      _prefs.setBool('useSystemAccent', _useSystemAccent);
    }
    if (settings.containsKey('accentShade')) {
      _accentShade = settings['accentShade'];
      _prefs.setInt('accentShade', _accentShade);
    }
    if (settings.containsKey('customColorIndex')) {
      _customColorIndex = settings['customColorIndex'];
      _prefs.setInt('customColorIndex', _customColorIndex);
    }
    if (settings.containsKey('themeMode')) {
      final themeModeIndex = settings['themeMode'];
      _themeMode = ThemeMode.values[themeModeIndex];
      _prefs.setInt('themeMode', themeModeIndex);
    }
    if (settings.containsKey('allowAdult')) {
      _allowAdult = settings['allowAdult'];
      _prefs.setBool('allowAdult', _allowAdult);
    }
    if (settings.containsKey('allowUnknown')) {
      _allowUnknown = settings['allowUnknown'];
      _prefs.setBool('allowUnknown', _allowUnknown);
    }
    if (settings.containsKey('useGlassTheme')) {
      _useGlassTheme = settings['useGlassTheme'];
      _prefs.setBool('useGlassTheme', _useGlassTheme);
    }
    if (settings.containsKey('useOverscrollToClose')) {
      _useOverscrollToClose = settings['useOverscrollToClose'];
      _prefs.setBool('useOverscrollToClose', _useOverscrollToClose);
    }
    if (settings.containsKey('showTooltips')) {
      _showTooltips = settings['showTooltips'];
      _prefs.setBool('showTooltips', _showTooltips);
    }
    if (settings.containsKey('downloadThreads')) {
      _downloadThreads = settings['downloadThreads'];
      _prefs.setInt('downloadThreads', _downloadThreads);
    }
    if (settings.containsKey('username')) {
      _username = settings['username'];
      _prefs.setString('username', _username);
    }
    if (settings.containsKey('gender')) {
      _gender = settings['gender'];
      _prefs.setString('gender', _gender);
    }
    
    // Once settings are imported, we consider the first open setup complete
    setFirstOpenComplete();
  }

  void setFirstOpenComplete() {
    _isFirstOpen = false;
    _prefs.setBool('isFirstOpen', false);
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

  void toggleShowTooltips() {
    _showTooltips = !_showTooltips;
    _prefs.setBool('showTooltips', _showTooltips);
    notifyListeners();
  }

  void setDownloadThreads(int threads) {
    _downloadThreads = threads;
    _prefs.setInt('downloadThreads', threads);
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

  void addPinnedChip(String chip) {
    if (!_pinnedChips.contains(chip)) {
      _pinnedChips.add(chip);
      _prefs.setStringList('pinnedChips', _pinnedChips);
      notifyListeners();
    }
  }

  void removePinnedChip(String chip) {
    if (_pinnedChips.contains(chip)) {
      _pinnedChips.remove(chip);
      _prefs.setStringList('pinnedChips', _pinnedChips);
      notifyListeners();
    }
  }
}
