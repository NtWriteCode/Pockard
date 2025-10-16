import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  static const String _languageKey = 'app_language';

  Locale? _locale; // null means system default

  Locale? get locale => _locale;

  /// Get current language code ('en', 'hu', or null for system)
  String get languageCode => _locale?.languageCode ?? 'system';

  Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageKey);

    if (languageCode == null || languageCode == 'system') {
      _locale = null; // System default
    } else {
      _locale = Locale(languageCode);
    }
    notifyListeners();
  }

  Future<void> setLanguage(String? languageCode) async {
    final prefs = await SharedPreferences.getInstance();

    if (languageCode == null || languageCode == 'system') {
      _locale = null; // System default
      await prefs.setString(_languageKey, 'system');
    } else {
      _locale = Locale(languageCode);
      await prefs.setString(_languageKey, languageCode);
    }
    notifyListeners();
  }

  /// Convenience methods for setting specific languages
  Future<void> setEnglish() => setLanguage('en');
  Future<void> setHungarian() => setLanguage('hu');
  Future<void> setSystemDefault() => setLanguage(null);
}
