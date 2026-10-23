import 'package:flutter/material.dart';

import '../game/mz_fly_game.dart';
import 'cartoon_button.dart';

/// The Game Over overlay showing final score, best score, new-record indicator, and replay/home buttons.
class GameOverOverlay extends StatefulWidget {
  final MzFlyGame game;

  const GameOverOverlay({super.key, required this.game});

  @override
  State<GameOverOverlay> createState() => _GameOverOverlayState();
}

class _GameOverOverlayState extends State<GameOverOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _slideAnimation = Tween<double>(begin: -50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeIn));

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Widget _buildMedal(int score) {
    if (score < 5) return const SizedBox.shrink();

    String tier = 'BRONZE';
    Color medalColor = const Color(0xFFCD7F32);
    if (score >= 40) {
      tier = 'PLATINUM';
      medalColor = const Color(0xFF38BDF8); // Cyan platinum
    } else if (score >= 20) {
      tier = 'GOLD';
      medalColor = const Color(0xFFFFD700);
    } else if (score >= 10) {
      tier = 'SILVER';
      medalColor = const Color(0xFF94A3B8);
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: medalColor.withAlpha(40),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: medalColor, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.workspace_premium_rounded, color: medalColor, size: 20),
          const SizedBox(width: 6),
          Text(
            '$tier MEDAL',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
              color: medalColor,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final score = widget.game.score;
    final bestScore = widget.game.bestScore;
    final isNewBest = widget.game.isNewBest;

    return Container(
      color: Colors.black.withAlpha(160),
      child: Center(
        child: AnimatedBuilder(
          animation: _animController,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.translate(
                offset: Offset(0, _slideAnimation.value),
                child: child,
              ),
            );
          },
          child: Container(
            width: 320,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
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
                // Game Over Cartoon Banner (Vibrant royal blue with white text)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0284C7),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF071530),
                      width: 3.0,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFF0A3B74),
                        offset: Offset(0, 4),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: const Text(
                    'GAME OVER',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          offset: Offset(1.5, 1.5),
                          color: Color(0xFF071530),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Scoreboard Box (Ice-blue container)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F9FF), // Ice-blue white card
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFBAE6FD),
                      width: 2.4,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Final Score
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'SCORE',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0369A1), // Slate ocean blue
                            ),
                          ),
                          Text(
                            '$score',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF071530), // Black/dark navy score
                            ),
                          ),
                        ],
                      ),
                      const Divider(
                        height: 20,
                        thickness: 1.5,
                        color: Color(0xFFBAE6FD),
                      ),
                      // Best Score
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'BEST SCORE',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0369A1),
                            ),
                          ),
                          Text(
                            '$bestScore',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0284C7), // Royal blue best score
                            ),
                          ),
                        ],
                      ),

                      // New Best Score Celebration Banner!
                      if (isNewBest) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF38BDF8), // Bright cyan
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0xFF0284C7),
                                offset: Offset(0, 3),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.stars_rounded,
                                color: Color(0xFF071530),
                                size: 18,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'NEW BEST RECORD!',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.0,
                                  color: Color(0xFF071530), // Dark text on light blue
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      _buildMedal(score),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // Play Again Button (Bright light blue with black text)
                CartoonButton(
                  text: 'PLAY AGAIN',
                  icon: Icons.replay_rounded,
                  primaryColor: const Color(0xFF38BDF8), // Light cyan / sky blue
                  shadowColor: const Color(0xFF0284C7),  // Ocean royal blue depth
                  textColor: const Color(0xFF071530),    // Bold black/dark navy text
                  fontSize: 20,
                  height: 54,
                  minWidth: 230,
                  onPressed: () {
                    widget.game.prepareReady();
                  },
                ),
                const SizedBox(height: 12),

                // Home / Menu Button (Deep navy blue with crisp white text)
                CartoonButton(
                  text: 'MAIN MENU',
                  icon: Icons.home_rounded,
                  primaryColor: const Color(0xFF1E40AF), // Deep royal navy
                  shadowColor: const Color(0xFF0F2753),  // Deep shadow
                  textColor: Colors.white,               // Crisp white text
                  fontSize: 18,
                  height: 48,
                  minWidth: 230,
                  onPressed: () {
                    widget.game.returnToMenu();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
