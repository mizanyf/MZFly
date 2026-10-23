import 'package:flutter/material.dart';

import '../game/mz_fly_game.dart';
import '../services/audio_service.dart';

/// The in-game HUD showing live score and the pause button.
class GameHud extends StatelessWidget {
  final MzFlyGame game;

  const GameHud({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Stack(
          children: [
            // Centered Score Display
            Align(
              alignment: Alignment.topCenter,
              child: ValueListenableBuilder<int>(
                valueListenable: game.scoreNotifier,
                builder: (context, score, _) {
                  return TweenAnimationBuilder<double>(
                    key: ValueKey(score),
                    tween: Tween<double>(begin: 1.35, end: 1.0),
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutBack,
                    builder: (context, scale, child) {
                      return Transform.scale(
                        scale: scale,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(90),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withAlpha(200),
                              width: 2.0,
                            ),
                          ),
                          child: Text(
                            '$score',
                            style: const TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2.0,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  offset: Offset(2, 3),
                                  color: Color(0xFF0F172A),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // Top-right Pause Button
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () {
                  AudioService.instance.playClick();
                  game.pauseGame();
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFCA28),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF0F172A),
                      width: 2.6,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFF0F172A),
                        offset: Offset(0, 3),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.pause_rounded,
                    size: 28,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
