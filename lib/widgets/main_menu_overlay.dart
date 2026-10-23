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
              // Top area reserved for the animated hovering cartoon bird
              const Spacer(flex: 4),

              // Main Section: MZ FLY Title -> Best Score -> Play Button -> SFX/BGM
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 3D Cartoon Title matching the MZ FLY logo
                  AnimatedBuilder(
                    animation: _bounceAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _bounceAnimation.value),
                        child: child,
                      );
                    },
                    child: _buildLogoTitle(),
                  ),

                  const SizedBox(height: 18),

                  // Best score pill (Deep dark blue with light blue border & white text)
                  ValueListenableBuilder<int>(
                    valueListenable: widget.game.bestScoreNotifier,
                    builder: (context, best, _) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0C1E3C), // Deep dark navy blue
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: const Color(0xFF38BDF8), // Vibrant light cyan/sky blue
                            width: 2.8,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xFF071530),
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
                              color: Color(0xFFFFD54F), // Gold trophy
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
                                color: Colors.white, // Crisp white text
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 18),

                  // PLAY BUTTON (Vibrant light blue with bold black/dark navy text)
                  CartoonButton(
                    text: 'PLAY NOW',
                    icon: Icons.play_arrow_rounded,
                    primaryColor: const Color(0xFF38BDF8), // Light cyan / sky blue
                    shadowColor: const Color(0xFF0284C7),  // Ocean royal blue depth
                    textColor: const Color(0xFF071530),    // Bold black/dark navy text
                    fontSize: 22,
                    height: 58,
                    minWidth: 220,
                    onPressed: () {
                      widget.game.prepareReady();
                    },
                  ),

                  const SizedBox(height: 18),

                  // Audio Toggles (SFX, BGM)
                  Row(
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
                ],
              ),

              // Bottom Spacer: lifts Play button and Best Score higher up
              const Spacer(flex: 4),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the 3D 'MZ FLY' title matching the logo style
  Widget _buildLogoTitle() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Subtle stylized cartoon cloud/pill perfectly centered behind the text
        Transform.translate(
          offset: const Offset(0, 3.0), // Compensate for 3D depth drop shadow
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(50),
              borderRadius: BorderRadius.circular(38),
              border: Border.all(
                color: Colors.white.withAlpha(90),
                width: 1.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF38BDF8).withAlpha(55),
                  blurRadius: 18,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: const Opacity(
              opacity: 0.0,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'MZ',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 52,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4.0,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'FLY',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 52,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // 3D Words: MZ in bright cyan blue, FLY in crisp white
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _build3DWord(
              'MZ',
              textColor: const Color(0xFF38BDF8), // Bright sky cyan
              bevelColor: const Color(0xFF0284C7), // Royal blue 3D bevel
              shadowColor: const Color(0xFF071530), // Deep midnight navy shadow
            ),
            const SizedBox(width: 12),
            _build3DWord(
              'FLY',
              textColor: Colors.white, // Pure crisp white
              bevelColor: const Color(0xFF94A3B8), // Soft slate bevel
              shadowColor: const Color(0xFF071530), // Deep midnight navy shadow
            ),
          ],
        ),
      ],
    );
  }

  /// Helper to render each 3D word with multi-layer cartoon stroke depth
  Widget _build3DWord(
    String word, {
    required Color textColor,
    required Color bevelColor,
    required Color shadowColor,
  }) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // 1. Bottom deep drop shadow
        Transform.translate(
          offset: const Offset(0, 6.5),
          child: Text(
            word,
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
                ..color = shadowColor,
            ),
          ),
        ),
        // 2. 3D depth bevel
        Transform.translate(
          offset: const Offset(0, 3.5),
          child: Text(
            word,
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
                ..color = bevelColor,
            ),
          ),
        ),
        // 3. Outer dark border stroke
        Text(
          word,
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
              ..color = shadowColor,
          ),
        ),
        // 4. Vibrant face color
        Text(
          word,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 52,
            fontWeight: FontWeight.w900,
            letterSpacing: 4.0,
            color: textColor,
          ),
        ),
      ],
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
                  ? const Color(0xFF0284C7) // Royal blue
                  : const Color(0xFF334155), // Inactive dark slate
              border: Border.all(color: const Color(0xFF071530), width: 2.8),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFF071530),
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
            color: Color(0xFF071530), // Dark black/navy label
          ),
        ),
      ],
    );
  }
}
