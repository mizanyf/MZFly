import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../game/game_status.dart';
import '../game/mz_fly_game.dart';
import '../services/audio_service.dart';
import '../widgets/game_hud.dart';
import '../widgets/game_over_overlay.dart';
import '../widgets/main_menu_overlay.dart';
import '../widgets/pause_overlay.dart';
import '../widgets/ready_overlay.dart';

/// The primary Game Screen hosting the Flame GameWidget and all Flutter UI overlays.
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with WidgetsBindingObserver {
  late final MzFlyGame _game;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _game = MzFlyGame();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      AudioService.instance.pauseBgm();
      if (_game.status == GameStatus.playing) {
        _game.pauseGame();
      }
    } else if (state == AppLifecycleState.resumed) {
      if (_game.status != GameStatus.paused) {
        AudioService.instance.resumeBgm();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        // Smart Back Button behavior
        if (_game.status == GameStatus.playing) {
          _game.pauseGame();
        } else if (_game.status == GameStatus.paused ||
            _game.status == GameStatus.ready ||
            _game.status == GameStatus.gameOver) {
          _game.returnToMenu();
        } else {
          // Allow exit from Main Menu
          Navigator.of(context).maybePop();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0A1E3F),
        body: GameWidget<MzFlyGame>.controlled(
          gameFactory: () => _game,
          overlayBuilderMap: {
            'menu': (context, game) => MainMenuOverlay(game: game),
            'ready': (context, game) => ReadyOverlay(game: game),
            'hud': (context, game) => GameHud(game: game),
            'pause': (context, game) => PauseOverlay(game: game),
            'gameOver': (context, game) => GameOverOverlay(game: game),
          },
          initialActiveOverlays: const ['menu'],
        ),
      ),
    );
  }
}
