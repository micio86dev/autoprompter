import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Impostazioni dell'app persistite localmente (tema e default di lettura).
class SettingsStore extends ChangeNotifier {
  static const _kThemeMode = 'theme_mode';
  static const _kFontSize = 'default_font_size';
  static const _kScrollSpeed = 'default_scroll_speed';
  static const _kReadingLine = 'default_reading_line';

  ThemeMode _themeMode = ThemeMode.system;
  double _defaultFontSize = 32;
  double _defaultScrollSpeed = 40;
  double _defaultReadingLine = 0.35;
  bool _loaded = false;

  ThemeMode get themeMode => _themeMode;
  double get defaultFontSize => _defaultFontSize;
  double get defaultScrollSpeed => _defaultScrollSpeed;
  double get defaultReadingLine => _defaultReadingLine;
  bool get loaded => _loaded;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final modeIndex = prefs.getInt(_kThemeMode);
    if (modeIndex != null &&
        modeIndex >= 0 &&
        modeIndex < ThemeMode.values.length) {
      _themeMode = ThemeMode.values[modeIndex];
    }
    _defaultFontSize = prefs.getDouble(_kFontSize) ?? _defaultFontSize;
    _defaultScrollSpeed = prefs.getDouble(_kScrollSpeed) ?? _defaultScrollSpeed;
    _defaultReadingLine = prefs.getDouble(_kReadingLine) ?? _defaultReadingLine;
    _loaded = true;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == _themeMode) return;
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kThemeMode, mode.index);
  }

  Future<void> setDefaultFontSize(double value) async {
    _defaultFontSize = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kFontSize, value);
  }

  Future<void> setDefaultScrollSpeed(double value) async {
    _defaultScrollSpeed = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kScrollSpeed, value);
  }

  Future<void> setDefaultReadingLine(double value) async {
    _defaultReadingLine = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kReadingLine, value);
  }
}
