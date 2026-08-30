import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final settingsServiceProvider = Provider<SettingsService>((ref) {
  throw UnimplementedError('SettingsService must be overridden in ProviderScope');
});

class SettingsService {
  final SharedPreferences _prefs;

  SettingsService(this._prefs);

  static const String _musicKey = 'music_enabled';
  static const String _sfxKey = 'sfx_enabled';
  static const String _vibrationKey = 'vibration_enabled';

  bool get musicEnabled => _prefs.getBool(_musicKey) ?? true;
  bool get sfxEnabled => _prefs.getBool(_sfxKey) ?? true;
  bool get vibrationEnabled => _prefs.getBool(_vibrationKey) ?? true;

  Future<void> setMusicEnabled(bool value) async {
    await _prefs.setBool(_musicKey, value);
  }

  Future<void> setSfxEnabled(bool value) async {
    await _prefs.setBool(_sfxKey, value);
  }

  Future<void> setVibrationEnabled(bool value) async {
    await _prefs.setBool(_vibrationKey, value);
  }

  static const String _tutorialProgressKey = 'tutorial_progress';
  int get tutorialProgress => _prefs.getInt(_tutorialProgressKey) ?? 0;

  Future<void> setTutorialProgress(int value) async {
    await _prefs.setInt(_tutorialProgressKey, value);
  }
}
