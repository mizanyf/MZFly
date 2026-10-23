import 'package:flutter/material.dart';

import '../game/mz_fly_game.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';
import 'cartoon_button.dart';

/// The Pause menu overlay displayed when gameplay is halted.
class PauseOverlay extends StatefulWidget {
  final MzFlyGame game;

  const PauseOverlay({super.key, required this.game});

  @override
  State<PauseOverlay> createState() => _PauseOverlayState();
}

class _PauseOverlayState extends State<PauseOverlay> {
  final StorageService _storage = StorageService.instance;
  final AudioService _audio = AudioService.instance;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withAlpha(160),
      child: Center(
        child: Container(
          width: 300,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFF0F172A), width: 3.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFF0F172A),
                offset: Offset(0, 8),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // "PAUSED" Cartoon Banner
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFCA28),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFF0F172A),
                    width: 2.8,
                  ),
                ),
                child: const Text(
                  'PAUSED',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Resume Button
              CartoonButton(
                text: 'RESUME',
                icon: Icons.play_arrow_rounded,
                primaryColor: const Color(0xFF4CAF50),
                shadowColor: const Color(0xFF2E7D32),
                minWidth: 220,
                onPressed: () {
                  widget.game.resumeGame();
                },
              ),
              const SizedBox(height: 14),

              // Restart Button
              CartoonButton(
                text: 'RESTART',
                icon: Icons.refresh_rounded,
                primaryColor: const Color(0xFF0288D1),
                shadowColor: const Color(0xFF01579B),
                minWidth: 220,
                onPressed: () {
                  widget.game.restartGame();
                },
              ),
              const SizedBox(height: 14),

              // Main Menu Button
              CartoonButton(
                text: 'MAIN MENU',
                icon: Icons.home_rounded,
                primaryColor: const Color(0xFFFF9800),
                shadowColor: const Color(0xFFE65100),
                minWidth: 220,
                onPressed: () {
                  widget.game.returnToMenu();
                },
              ),
              const SizedBox(height: 20),

              // Quick Sound Toggles in Pause Menu
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      _storage.soundEnabled
                          ? Icons.volume_up_rounded
                          : Icons.volume_off_rounded,
                      color: const Color(0xFF0F172A),
                    ),
                    onPressed: () async {
                      await _audio.toggleSound();
                      setState(() {});
                    },
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: Icon(
                      _storage.musicEnabled
                          ? Icons.music_note_rounded
                          : Icons.music_off_rounded,
                      color: const Color(0xFF0F172A),
                    ),
                    onPressed: () async {
                      await _audio.toggleMusic();
                      setState(() {});
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
