import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLanguage {
  final String code;
  final String label;
  const AppLanguage(this.code, this.label);
}

const List<AppLanguage> kSupportedLanguages = [
  AppLanguage('en-US', 'English'),
  AppLanguage('hi-IN', 'Hindi (हिन्दी)'),
  AppLanguage('ta-IN', 'Tamil (தமிழ்)'),
  AppLanguage('te-IN', 'Telugu (తెలుగు)'),
  AppLanguage('kn-IN', 'Kannada (ಕನ್ನಡ)'),
  AppLanguage('bn-IN', 'Bengali (বাংলা)'),
];

class SettingsService extends ChangeNotifier {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  static const _textScaleKey = 'medwise_text_scale';
  static const _languageKey = 'medwise_language_code';

  double _textScale = 1.0;
  double get textScale => _textScale;

  String _languageCode = 'en-US';
  String get languageCode => _languageCode;

  AppLanguage get language => kSupportedLanguages.firstWhere(
        (l) => l.code == _languageCode,
        orElse: () => kSupportedLanguages.first,
      );

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _textScale = prefs.getDouble(_textScaleKey) ?? 1.0;
    _languageCode = prefs.getString(_languageKey) ?? 'en-US';
    notifyListeners();
  }

  Future<void> setTextScale(double value) async {
    _textScale = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_textScaleKey, value);
  }

  Future<void> setLanguage(String code) async {
    _languageCode = code;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, code);
  }
}