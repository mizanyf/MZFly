import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../game/mz_fly_game.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';
import 'cartoon_button.dart';

/// The Main Menu overlay showing the game logo, title, best score, play button, and audio toggles.
class MainMenuOverlay extends StatefulWidget {
  final MzFlyGame game;

  const MainMenuOverlay({super.key, required this.game});

  @override
  State<MainMenuOverlay> createState() => _MainMenuOverlayState();
}

class _MainMenuOverlayState extends State<MainMenuOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  final StorageService _storage = StorageService.instance;
  final AudioService _audio = AudioService.instance;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: -8.0, end: 8.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );

    // Start background music if enabled
    _audio.startBgm();
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          // Content column
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(height: 12),

                  // Animated Logo & Title Banner
                  AnimatedBuilder(
                    animation: _bounceAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _bounceAnimation.value),
                        child: child,
                      );
                    },
                    child: Column(
                      children: [
                        // User Logo
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF0F172A),
                              width: 3.5,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0xFF0F172A),
                                offset: Offset(0, 6),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/logo.png',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: const Color(0xFFFFCA28),
                                  child: const Icon(
                                    Icons.flight_takeoff_rounded,
                                    size: 54,
                                    color: Color(0xFFD84315),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Title Banner
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 26,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFCA28),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: const Color(0xFF0F172A),
                              width: 3.5,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0xFFE65100),
                                offset: Offset(0, 5),
                                blurRadius: 0,
                              ),
                              BoxShadow(
                                color: Color(0xFF0F172A),
                                offset: Offset(0, 8),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: Text(
                            'MZ FLY',
                            style: GoogleFonts.poppins(
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2.0,
                              color: const Color(0xFFD84315),
                              shadows: const [
                                Shadow(
                                  offset: Offset(2, 2),
                                  color: Colors.white,
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(225),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF01579B),
                              width: 1.8,
                            ),
                          ),
                          child: Text(
                            'One-Touch Cartoon Flying',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF01579B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Middle spacing (bird hovers here)
                  const Spacer(),

                  // Best Score Badge & Play Button
                  Column(
                    children: [
                      // Best score pill
                      ValueListenableBuilder<int>(
                        valueListenable: widget.game.bestScoreNotifier,
                        builder: (context, best, _) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 22),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 22,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: const Color(0xFFFFD54F),
                                width: 2.5,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  offset: Offset(0, 4),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.emoji_events_rounded,
                                  color: Color(0xFFFFD54F),
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'BEST SCORE: $best',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.2,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      // PLAY BUTTON
                      CartoonButton(
                        text: 'PLAY NOW',
                        icon: Icons.play_arrow_rounded,
                        primaryColor: const Color(0xFF4CAF50),
                        shadowColor: const Color(0xFF2E7D32),
                        fontSize: 22,
                        height: 58,
                        minWidth: 220,
                        onPressed: () {
                          widget.game.prepareReady();
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Bottom Controls (Sound, Music)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // SFX Toggle
                        _CircleIconButton(
                          icon: _storage.soundEnabled
                              ? Icons.volume_up_rounded
                              : Icons.volume_off_rounded,
                          label: 'SFX',
                          isActive: _storage.soundEnabled,
                          onPressed: () async {
                            await _audio.toggleSound();
                            setState(() {});
                          },
                        ),
                        const SizedBox(width: 22),

                        // BGM Toggle
                        _CircleIconButton(
                          icon: _storage.musicEnabled
                              ? Icons.music_note_rounded
                              : Icons.music_off_rounded,
                          label: 'BGM',
                          isActive: _storage.musicEnabled,
                          onPressed: () async {
                            await _audio.toggleMusic();
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onPressed;

  const _CircleIconButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? const Color(0xFF42A5F5) : const Color(0xFF94A3B8),
              border: Border.all(color: const Color(0xFF0F172A), width: 2.5),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFF0F172A),
                  offset: Offset(0, 3),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}
