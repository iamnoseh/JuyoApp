import 'package:flutter/material.dart';
import 'package:juyo/core/storage/local_storage_service.dart';

class ThemeModeController extends ChangeNotifier {
  ThemeModeController(this._localStorageService)
      : _themeMode = _readInitialMode(_localStorageService);

  static const _storageKey = 'theme_mode';

  final LocalStorageService _localStorageService;

  ThemeMode _themeMode;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> toggle() async {
    await setThemeMode(isDarkMode ? ThemeMode.light : ThemeMode.dark);
  }

  Future<void> setThemeMode(ThemeMode value) async {
    if (_themeMode == value) return;
    _themeMode = value;
    await _localStorageService.saveString(_storageKey, value.name);
    notifyListeners();
  }

  static ThemeMode _readInitialMode(LocalStorageService localStorageService) {
    return switch (localStorageService.readString(_storageKey)) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.dark,
    };
  }
}
