import 'dart:math';

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../services/audio_service.dart';
import '../services/storage_service.dart';
import 'components/background_component.dart';
import 'components/bird_player.dart';
import 'components/ground_component.dart';
import 'components/obstacle_pair.dart';
import 'game_status.dart';

/// The main Flame game class for MZ Fly.
class MzFlyGame extends FlameGame with HasCollisionDetection, TapCallbacks {
  final AudioService audio = AudioService.instance;
  final StorageService storage = StorageService.instance;

  GameStatus status = GameStatus.menu;

  late final BirdPlayer bird = BirdPlayer();
  late final BackgroundComponent background = BackgroundComponent();
  late final GroundComponent ground = GroundComponent();

  final ValueNotifier<int> scoreNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> bestScoreNotifier = ValueNotifier<int>(0);

  int get score => scoreNotifier.value;
  int get bestScore => bestScoreNotifier.value;
  bool isNewBest = false;

  final Random _random = Random();
  double _pipeSpawnTimer = 0.0;
  static const double pipeInterval = 1.9; // seconds between obstacles
  static const double gapHeight = 175.0; // Playable gap

  double _shakeDuration = 0.0;

  @override
  Color backgroundColor() => const Color(0xFF29B6F6);

  @override
  Future<void> onLoad() async {
    super.onLoad();

    bestScoreNotifier.value = storage.bestScore;

    // 1. Parallax cartoon background
    add(background);

    // 2. Player Character
    add(bird);

    // 3. Ground Platform
    add(ground);

    _positionBirdForMenu();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (!isLoaded) return;
    if (status == GameStatus.menu) {
      _positionBirdForMenu();
    } else if (status == GameStatus.ready) {
      bird.reset(Vector2(size.x * 0.28, size.y * 0.44));
    }
  }

  void _positionBirdForMenu() {
    bird.reset(Vector2(size.x * 0.5, size.y * 0.38));
  }

  /// Called when the player taps to start or flaps during gameplay.
  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);

    if (status == GameStatus.ready) {
      startGame();
    } else if (status == GameStatus.playing) {
      bird.flap();
    }
  }

  /// Sets up ready state before gameplay begins.
  void prepareReady() {
    resumeEngine();
    status = GameStatus.ready;
    scoreNotifier.value = 0;
    isNewBest = false;
    bestScoreNotifier.value = storage.bestScore;

    _clearObstacles();

    bird.reset(Vector2(size.x * 0.28, size.y * 0.44));

    _safeRemoveOverlay('menu');
    _safeRemoveOverlay('pause');
    _safeRemoveOverlay('gameOver');
    _safeAddOverlay('hud');
    _safeAddOverlay('ready');
  }

  /// Begins active gameplay.
  void startGame() {
    status = GameStatus.playing;
    _pipeSpawnTimer = 1.0; // Spawn first pipe shortly after start
    _safeRemoveOverlay('ready');
    bird.flap();
  }

  /// Increments score when passing an obstacle.
  void incrementScore() {
    scoreNotifier.value++;
    audio.playScore();
  }

  /// Handles player collision with obstacles or ground.
  void onPlayerHit() {
    if (status != GameStatus.playing || bird.isDead) return;

    bird.isDead = true;
    status = GameStatus.gameOver;
    audio.playHit();
    audio.playGameOver();

    // Trigger camera screen shake
    _shakeDuration = 0.32;

    // Check high score
    final previousBest = storage.bestScore;
    if (score > previousBest) {
      isNewBest = true;
      storage.updateBestScore(score);
      bestScoreNotifier.value = score;
    }

    _safeAddOverlay('gameOver');
  }

  /// Pauses the game loop.
  void pauseGame() {
    if (status != GameStatus.playing) return;
    status = GameStatus.paused;
    pauseEngine();
    audio.pauseBgm();
    _safeAddOverlay('pause');
  }

  /// Resumes from pause state.
  void resumeGame() {
    if (status != GameStatus.paused) return;
    status = GameStatus.playing;
    resumeEngine();
    audio.resumeBgm();
    _safeRemoveOverlay('pause');
  }

  /// Restarts the game to ready state.
  void restartGame() {
    audio.playClick();
    prepareReady();
  }

  /// Returns to main menu.
  void returnToMenu() {
    resumeEngine();
    audio.playClick();
    status = GameStatus.menu;
    _clearObstacles();
    _positionBirdForMenu();

    _safeRemoveOverlay('hud');
    _safeRemoveOverlay('ready');
    _safeRemoveOverlay('pause');
    _safeRemoveOverlay('gameOver');
    _safeAddOverlay('menu');
  }

  void _safeAddOverlay(String name) {
    try {
      overlays.add(name);
    } on Object catch (_) {}
  }

  void _safeRemoveOverlay(String name) {
    try {
      overlays.remove(name);
    } on Object catch (_) {}
  }

  void _clearObstacles() {
    final obstacles = children.whereType<ObstaclePair>().toList();
    for (final obs in obstacles) {
      obs.removeFromParent();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Camera shake handling
    if (_shakeDuration > 0) {
      _shakeDuration -= dt;
      if (_shakeDuration <= 0) {
        camera.viewfinder.position.setZero();
      } else {
        final intensity = (_shakeDuration / 0.32) * 9.0;
        camera.viewfinder.position.setValues(
          (_random.nextDouble() - 0.5) * intensity * 2,
          (_random.nextDouble() - 0.5) * intensity * 2,
        );
      }
    }

    // Obstacle spawning during active gameplay
    if (status == GameStatus.playing) {
      _pipeSpawnTimer += dt;
      if (_pipeSpawnTimer >= pipeInterval) {
        _pipeSpawnTimer = 0.0;
        _spawnObstacle();
      }
    }
  }

  void _spawnObstacle() {
    final groundY = size.y - GroundComponent.groundHeight;
    const minTop = 60.0;
    final maxTop = max(minTop, groundY - gapHeight - 60.0);

    // Random top height between minTop and maxTop
    final topHeight = minTop + _random.nextDouble() * (maxTop - minTop);

    final obstacle = ObstaclePair(
      startX: size.x + 20.0,
      topHeight: topHeight,
      gapSize: gapHeight,
      groundY: groundY,
    );
    add(obstacle);
  }
}
