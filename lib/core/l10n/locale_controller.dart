import 'package:flutter/material.dart';
import 'package:juyo/core/storage/local_storage_service.dart';

class LocaleController extends ChangeNotifier {
  LocaleController(this._localStorageService)
      : _locale = _readInitialLocale(_localStorageService);

  static const _storageKey = 'app_locale';

  final LocalStorageService _localStorageService;

  Locale _locale;

  Locale get locale => _locale;

  Future<void> setLocale(Locale value) async {
    if (_locale == value) return;
    _locale = value;
    await _localStorageService.saveString(_storageKey, value.languageCode);
    notifyListeners();
  }

  static Locale _readInitialLocale(LocalStorageService localStorageService) {
    return switch (localStorageService.readString(_storageKey)) {
      'ru' => const Locale('ru'),
      'en' => const Locale('en'),
      _ => const Locale('tg'),
    };
  }
}
