import 'package:shared_preferences/shared_preferences.dart';

/// Service managing persistent game data like best score and audio settings.
class StorageService {
  static const String _keyBestScore = 'mzfly_best_score';
  static const String _keySoundEnabled = 'mzfly_sound_enabled';
  static const String _keyMusicEnabled = 'mzfly_music_enabled';

  static final StorageService instance = StorageService._internal();

  StorageService._internal();

  SharedPreferences? _prefs;

  int _bestScore = 0;
  bool _soundEnabled = true;
  bool _musicEnabled = true;

  int get bestScore => _bestScore;
  bool get soundEnabled => _soundEnabled;
  bool get musicEnabled => _musicEnabled;

  /// Initializes the storage service and loads cached values.
  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _bestScore = _prefs?.getInt(_keyBestScore) ?? 0;
      _soundEnabled = _prefs?.getBool(_keySoundEnabled) ?? true;
      _musicEnabled = _prefs?.getBool(_keyMusicEnabled) ?? true;
    } catch (_) {
      // Fallback defaults on any storage error
      _bestScore = 0;
      _soundEnabled = true;
      _musicEnabled = true;
    }
  }

  /// Saves new best score if [score] is higher than current best.
  /// Returns `true` if a new best score was established.
  Future<bool> updateBestScore(int score) async {
    if (score > _bestScore) {
      _bestScore = score;
      try {
        await _prefs?.setInt(_keyBestScore, _bestScore);
      } catch (_) {}
      return true;
    }
    return false;
  }

  /// Sets sound effects enabled/disabled state.
  Future<void> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    try {
      await _prefs?.setBool(_keySoundEnabled, enabled);
    } catch (_) {}
  }

  /// Sets background music enabled/disabled state.
  Future<void> setMusicEnabled(bool enabled) async {
    _musicEnabled = enabled;
    try {
      await _prefs?.setBool(_keyMusicEnabled, enabled);
    } catch (_) {}
  }
}
