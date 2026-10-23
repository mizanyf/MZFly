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
            color: const Color(0xFF0C1E3C), // Deep dark navy blue
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: const Color(0xFF38BDF8), // Vibrant light cyan/sky blue
              width: 3.5,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFF071530),
                offset: Offset(0, 8),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // "PAUSED" Cartoon Banner (Bright cyan with dark navy text)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF38BDF8), // Light cyan / sky blue
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFF071530),
                    width: 3.0,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xFF0284C7),
                      offset: Offset(0, 4),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: const Text(
                  'PAUSED',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                    color: Color(0xFF071530), // Black/dark navy text
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Resume Button (Bright light blue with black text)
              CartoonButton(
                text: 'RESUME',
                icon: Icons.play_arrow_rounded,
                primaryColor: const Color(0xFF38BDF8), // Light cyan / sky blue
                shadowColor: const Color(0xFF0284C7),  // Royal depth
                textColor: const Color(0xFF071530),    // Bold black/dark navy text
                minWidth: 220,
                onPressed: () {
                  widget.game.resumeGame();
                },
              ),
              const SizedBox(height: 14),

              // Restart Button (Royal blue with white text)
              CartoonButton(
                text: 'RESTART',
                icon: Icons.refresh_rounded,
                primaryColor: const Color(0xFF0284C7), // Royal blue
                shadowColor: const Color(0xFF0A3B74),  // Dark blue depth
                textColor: Colors.white,               // Crisp white text
                minWidth: 220,
                onPressed: () {
                  widget.game.restartGame();
                },
              ),
              const SizedBox(height: 14),

              // Main Menu Button (Deep navy blue with white text)
              CartoonButton(
                text: 'MAIN MENU',
                icon: Icons.home_rounded,
                primaryColor: const Color(0xFF1E40AF), // Deep royal navy
                shadowColor: const Color(0xFF0F2753),  // Deep shadow
                textColor: Colors.white,               // Crisp white text
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
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF0284C7),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF071530), width: 2.5),
                    ),
                    child: IconButton(
                      icon: Icon(
                        _storage.soundEnabled
                            ? Icons.volume_up_rounded
                            : Icons.volume_off_rounded,
                        color: Colors.white,
                      ),
                      onPressed: () async {
                        await _audio.toggleSound();
                        setState(() {});
                      },
                    ),
                  ),
                  const SizedBox(width: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF0284C7),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF071530), width: 2.5),
                    ),
                    child: IconButton(
                      icon: Icon(
                        _storage.musicEnabled
                            ? Icons.music_note_rounded
                            : Icons.music_off_rounded,
                        color: Colors.white,
                      ),
                      onPressed: () async {
                        await _audio.toggleMusic();
                        setState(() {});
                      },
                    ),
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
