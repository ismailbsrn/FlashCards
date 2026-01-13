import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/study_settings.dart';
import '../repositories/settings_repository.dart';

class SettingsProvider with ChangeNotifier {
  final SettingsRepository _repository = SettingsRepository();
  static const String _localeKey = 'app_locale';

  StudySettings? _settings;
  bool _isLoading = false;
  String? _error;
  Locale? _locale;

  StudySettings? get settings => _settings;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Locale? get locale => _locale;

  SettingsProvider() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final localeCode = prefs.getString(_localeKey);
    if (localeCode != null) {
      _locale = Locale(localeCode);
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale newLocale) async {
    _locale = newLocale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, newLocale.languageCode);
    notifyListeners();
  }

  Future<void> loadSettings(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _settings = await _repository.getOrCreateSettings(userId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateSettings(StudySettings settings) async {
    try {
      final updated = settings.copyWith(updatedAt: DateTime.now());
      await _repository.saveSettings(updated);
      _settings = updated;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
