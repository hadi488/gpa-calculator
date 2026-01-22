import 'package:flutter/material.dart';
import 'package:cgpacalculator/data/services/storage_service.dart';

/// Provider for managing app theme state
class ThemeProvider extends ChangeNotifier {
  final StorageService _storageService;
  ThemeMode _themeMode = ThemeMode.system;

  ThemeProvider({required StorageService storageService})
    : _storageService = storageService;

  /// Current theme mode
  ThemeMode get themeMode => _themeMode;

  /// Loads the saved theme mode from storage
  Future<void> loadTheme() async {
    final savedMode = await _storageService.getThemeMode();
    _themeMode = _intToThemeMode(savedMode);
    notifyListeners();
  }

  /// Sets and saves the theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    notifyListeners();
    await _storageService.saveThemeMode(_themeModeToInt(mode));
  }

  /// Converts integer to ThemeMode
  ThemeMode _intToThemeMode(int value) {
    switch (value) {
      case 1:
        return ThemeMode.light;
      case 2:
        return ThemeMode.dark;
      case 0:
      default:
        return ThemeMode.system;
    }
  }

  /// Converts ThemeMode to integer
  int _themeModeToInt(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 1;
      case ThemeMode.dark:
        return 2;
      case ThemeMode.system:
        return 0;
    }
  }
}
