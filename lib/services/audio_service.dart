import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';

import 'storage_service.dart';

/// Audio service providing SFX and BGM playback with safety fallbacks.
class AudioService {
  static final AudioService instance = AudioService._internal();

  AudioService._internal();

  final StorageService _storage = StorageService.instance;

  static const String sfxFlap = 'sfx/flap.wav';
  static const String sfxScore = 'sfx/score.wav';
  static const String sfxHit = 'sfx/hit.wav';
  static const String sfxClick = 'sfx/click.wav';
  static const String sfxGameOver = 'sfx/gameover.wav';
  static const String bgmTrack = 'music/bgm.wav';

  bool _initialized = false;
  bool _bgmPlaying = false;

  /// Preloads sound effects into memory for instant playback.
  Future<void> init() async {
    if (_initialized) return;
    try {
      await FlameAudio.audioCache.loadAll([
        sfxFlap,
        sfxScore,
        sfxHit,
        sfxClick,
        sfxGameOver,
      ]);
      _initialized = true;
    } catch (e) {
      debugPrint('Audio initialization note: $e');
    }
  }

  /// Plays flap sound effect.
  void playFlap() {
    _playSfx(sfxFlap, volume: 0.8);
  }

  /// Plays score point sound effect.
  void playScore() {
    _playSfx(sfxScore, volume: 0.9);
  }

  /// Plays collision hit sound effect.
  void playHit() {
    _playSfx(sfxHit, volume: 1.0);
  }

  /// Plays button click sound effect.
  void playClick() {
    _playSfx(sfxClick, volume: 0.6);
  }

  /// Plays game over sad sound effect.
  void playGameOver() {
    _playSfx(sfxGameOver, volume: 0.85);
  }

  Future<void> _playSfx(String file, {double volume = 1.0}) async {
    if (!_storage.soundEnabled) return;
    try {
      await FlameAudio.play(file, volume: volume);
    } catch (e) {
      debugPrint('SFX play skipped: $e');
    }
  }

  /// Starts background music looping.
  Future<void> startBgm() async {
    if (!_storage.musicEnabled || _bgmPlaying) return;
    try {
      FlameAudio.bgm.initialize();
      await FlameAudio.bgm.play(bgmTrack, volume: 0.4);
      _bgmPlaying = true;
    } catch (e) {
      debugPrint('BGM play note: $e');
    }
  }

  /// Stops background music.
  Future<void> stopBgm() async {
    if (!_bgmPlaying) return;
    try {
      await FlameAudio.bgm.stop();
    } catch (e) {
      debugPrint('BGM stop note: $e');
    } finally {
      _bgmPlaying = false;
    }
  }

  /// Pauses background music when app is in background.
  Future<void> pauseBgm() async {
    if (!_bgmPlaying) return;
    try {
      await FlameAudio.bgm.pause();
    } catch (e) {
      debugPrint('BGM pause note: $e');
    }
  }

  /// Resumes background music when app returns to foreground.
  Future<void> resumeBgm() async {
    if (_storage.musicEnabled && _bgmPlaying) {
      try {
        await FlameAudio.bgm.resume();
      } catch (e) {
        debugPrint('BGM resume note: $e');
      }
    }
  }

  /// Toggles sound effects and returns new state.
  Future<bool> toggleSound() async {
    final newState = !_storage.soundEnabled;
    await _storage.setSoundEnabled(newState);
    if (newState) {
      playClick();
    }
    return newState;
  }

  /// Toggles music and returns new state.
  Future<bool> toggleMusic() async {
    final newState = !_storage.musicEnabled;
    await _storage.setMusicEnabled(newState);
    if (newState) {
      await startBgm();
    } else {
      await stopBgm();
    }
    return newState;
  }
}
