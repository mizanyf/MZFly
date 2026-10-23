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
      medalColor = const Color(0xFFE0E7FF);
    } else if (score >= 20) {
      tier = 'GOLD';
      medalColor = const Color(0xFFFFD700);
    } else if (score >= 10) {
      tier = 'SILVER';
      medalColor = const Color(0xFFC0C0C0);
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: medalColor.withAlpha(50),
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
              color: medalColor == const Color(0xFFE0E7FF)
                  ? Colors.black87
                  : medalColor,
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
      color: Colors.black.withAlpha(140),
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
              color: const Color(0xFFFFFBEB), // Warm parchment
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
                // Game Over Cartoon Banner
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF0F172A),
                      width: 3.0,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFF991B1B),
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
                          color: Colors.black45,
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Scoreboard Box
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
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
                              color: Color(0xFF64748B),
                            ),
                          ),
                          Text(
                            '$score',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20, thickness: 1.5),
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
                              color: Color(0xFF64748B),
                            ),
                          ),
                          Text(
                            '$bestScore',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFD97706),
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
                            color: const Color(0xFF10B981),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0xFF059669),
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
                                color: Colors.white,
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
                                  color: Colors.white,
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

                // Play Again Button
                CartoonButton(
                  text: 'PLAY AGAIN',
                  icon: Icons.replay_rounded,
                  primaryColor: const Color(0xFF10B981),
                  shadowColor: const Color(0xFF059669),
                  fontSize: 20,
                  height: 54,
                  minWidth: 230,
                  onPressed: () {
                    widget.game.prepareReady();
                  },
                ),
                const SizedBox(height: 12),

                // Home / Menu Button
                CartoonButton(
                  text: 'MAIN MENU',
                  icon: Icons.home_rounded,
                  primaryColor: const Color(0xFFF59E0B),
                  shadowColor: const Color(0xFFD97706),
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
