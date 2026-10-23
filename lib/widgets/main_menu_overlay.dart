import 'package:flutter/material.dart';

import '../game/mz_fly_game.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';
import 'cartoon_button.dart';

/// The Main Menu overlay displaying the floating 3D MZ FLY title,
/// best score badge, play button, and audio toggles.
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
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: -7.0, end: 7.0).animate(
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
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              // Top area kept clear for the floating animated cartoon bird
              const Spacer(),

              // Bottom Section: MZ FLY Title -> Best Score -> Play Button -> SFX/BGM
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 3D Cartoon MZ FLY Title (No background box)
                  AnimatedBuilder(
                    animation: _bounceAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _bounceAnimation.value),
                        child: child,
                      );
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Bottom dark 3D drop shadow
                        Transform.translate(
                          offset: const Offset(0, 6.5),
                          child: Text(
                            'MZ FLY',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 52,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 4.0,
                              foreground: Paint()
                                ..style = PaintingStyle.stroke
                                ..strokeWidth = 9.0
                                ..strokeCap = StrokeCap.round
                                ..strokeJoin = StrokeJoin.round
                                ..color = const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        // 3D warm orange depth bevel
                        Transform.translate(
                          offset: const Offset(0, 3.5),
                          child: Text(
                            'MZ FLY',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 52,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 4.0,
                              foreground: Paint()
                                ..style = PaintingStyle.stroke
                                ..strokeWidth = 8.0
                                ..strokeCap = StrokeCap.round
                                ..strokeJoin = StrokeJoin.round
                                ..color = const Color(0xFFE65100),
                            ),
                          ),
                        ),
                        // Outer dark border stroke
                        Text(
                          'MZ FLY',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 52,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 4.0,
                            foreground: Paint()
                              ..style = PaintingStyle.stroke
                              ..strokeWidth = 8.0
                              ..strokeCap = StrokeCap.round
                              ..strokeJoin = StrokeJoin.round
                              ..color = const Color(0xFF0F172A),
                          ),
                        ),
                        // Vibrant golden yellow text face
                        const Text(
                          'MZ FLY',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 52,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 4.0,
                            color: Color(0xFFFFD54F),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Best score pill
                  ValueListenableBuilder<int>(
                    valueListenable: widget.game.bestScoreNotifier,
                    builder: (context, best, _) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: const Color(0xFFFFD54F),
                            width: 2.8,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xFF0F172A),
                              offset: Offset(0, 4.5),
                              blurRadius: 0,
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
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.4,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

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

                  const SizedBox(height: 18),

                  // Audio Toggles (SFX, BGM)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 18.0),
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
                        const SizedBox(width: 24),

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
            ],
          ),
        ),
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
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? const Color(0xFF42A5F5)
                  : const Color(0xFF94A3B8),
              border: Border.all(color: const Color(0xFF0F172A), width: 2.8),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFF0F172A),
                  offset: Offset(0, 3.5),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
            color: Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}
