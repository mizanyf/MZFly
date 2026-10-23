import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../game_status.dart';
import '../mz_fly_game.dart';

/// Parallax cartoon background featuring sky gradient, cartoon sun,
/// drifting clouds, and multi-layered rolling green hills.
class BackgroundComponent extends PositionComponent
    with HasGameReference<MzFlyGame> {
  double _cloudOffset1 = 0.0;
  double _cloudOffset2 = 0.0;
  double _cloudOffset3 = 0.0;
  double _distantHillsOffset = 0.0;
  double _midHillsOffset = 0.0;
  double _sunPulseTime = 0.0;

  BackgroundComponent() : super(anchor: Anchor.topLeft, priority: 0);

  @override
  void update(double dt) {
    super.update(dt);

    if (game.status == GameStatus.paused) return;

    final scrollMultiplier = (game.status == GameStatus.gameOver) ? 0.0 : 1.0;

    _sunPulseTime += dt * 1.5;

    // Parallax scrolling speeds
    _cloudOffset1 =
        (_cloudOffset1 + 12.0 * dt * scrollMultiplier) % (game.size.x + 240);
    _cloudOffset2 =
        (_cloudOffset2 + 18.0 * dt * scrollMultiplier) % (game.size.x + 280);
    _cloudOffset3 =
        (_cloudOffset3 + 24.0 * dt * scrollMultiplier) % (game.size.x + 220);

    _distantHillsOffset =
        (_distantHillsOffset + 20.0 * dt * scrollMultiplier) % 320.0;
    _midHillsOffset = (_midHillsOffset + 48.0 * dt * scrollMultiplier) % 240.0;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final w = game.size.x;
    final h = game.size.y;
    final groundY = h - 100.0;

    // 1. Sky Gradient (from dark blue to light blue matching logo)
    final skyRect = Rect.fromLTWH(0, 0, w, h);
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF0A1E3F), // Deep atmospheric navy (dark blue)
          Color(0xFF0284C7), // Vivid ocean royal blue
          Color(0xFF38BDF8), // Bright sky cyan
          Color(0xFFE0F2FE), // Soft light horizon blue (biru muda)
        ],
        stops: [0.0, 0.42, 0.78, 1.0],
      ).createShader(skyRect);
    canvas.drawRect(skyRect, skyPaint);

    // 2. Shining Light Blue Cartoon Sun (top right)
    final sunCenter = Offset(w - 65, 80);
    final pulse = sin(_sunPulseTime) * 3.5;

    // Glowing outer auras (Soft pulsing light cyan & sky blue)
    canvas.drawCircle(
      sunCenter,
      56.0 + pulse,
      Paint()..color = const Color(0x2238BDF8),
    );
    canvas.drawCircle(
      sunCenter,
      44.0 + pulse * 0.7,
      Paint()..color = const Color(0x447DD3FC),
    );
    canvas.drawCircle(
      sunCenter,
      35.0 + pulse * 0.4,
      Paint()..color = const Color(0x66BAE6FD),
    );

    // Rotating radiant sun rays (Light blue shining beams)
    canvas.save();
    canvas.translate(sunCenter.dx, sunCenter.dy);
    canvas.rotate(_sunPulseTime * 0.35);
    final rayPaint = Paint()
      ..color = const Color(0x66BAE6FD)
      ..strokeWidth = 3.6
      ..strokeCap = StrokeCap.round;
    const rayCount = 8;
    for (int i = 0; i < rayCount; i++) {
      final angle = (i * 2 * pi) / rayCount;
      final rayStart = Offset(cos(angle) * 35.0, sin(angle) * 35.0);
      final rayLength = 48.0 + sin(_sunPulseTime * 2.2 + i) * 4.5;
      final rayEnd = Offset(cos(angle) * rayLength, sin(angle) * rayLength);
      canvas.drawLine(rayStart, rayEnd, rayPaint);
    }
    canvas.restore();

    // Glowing sun core (Luminous ice-blue)
    canvas.drawCircle(
      sunCenter,
      28.0,
      Paint()..color = const Color(0xFFE0F2FE),
    );
    // Sun edge border
    canvas.drawCircle(
      sunCenter,
      28.0,
      Paint()
        ..color = const Color(0xFF38BDF8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4,
    );
    // Sparkle gleam on sun top-left
    canvas.drawCircle(
      sunCenter + const Offset(-7, -7),
      5.0,
      Paint()..color = Colors.white.withAlpha(210),
    );
    canvas.drawCircle(
      sunCenter + const Offset(-12, -4),
      2.5,
      Paint()..color = Colors.white.withAlpha(180),
    );

    // 3. Drifting Clouds (Light blue and slightly wider)
    _drawCloud(canvas, Offset(w - _cloudOffset1, 70), 0.85);
    _drawCloud(canvas, Offset(w * 0.7 - _cloudOffset2, 130), 1.1);
    _drawCloud(canvas, Offset(w * 1.3 - _cloudOffset3, 180), 0.95);

    // 4. Distant Pastel Blue-Green Hills
    _drawDistantHills(canvas, w, groundY);

    // 5. Midground Lush Rolling Green Hills
    _drawMidgroundHills(canvas, w, groundY);
  }

  void _drawCloud(Canvas canvas, Offset pos, double scale) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.scale(scale * 1.25, scale); // Extra horizontal width for a wider cloud!

    // Light blue cartoon cloud palette
    final cloudBasePaint = Paint()..color = const Color(0xEEBAE6FD); // Vibrant light sky blue
    final cloudHighlightPaint = Paint()..color = const Color(0xE6F0F9FF); // Crisp ice-blue top puffs
    final shadowPaint = Paint()..color = const Color(0x380284C7); // Soft royal cyan shadow

    // Bottom soft shadow (wider)
    canvas.drawOval(const Rect.fromLTWH(-75, -6, 150, 42), shadowPaint);

    // Puffy cloud lobes (wider horizontal spread)
    canvas.drawCircle(const Offset(-48, 6), 22, cloudBasePaint);
    canvas.drawCircle(const Offset(-26, -2), 28, cloudBasePaint);
    canvas.drawCircle(const Offset(0, -9), 34, cloudBasePaint);
    canvas.drawCircle(const Offset(26, -2), 28, cloudBasePaint);
    canvas.drawCircle(const Offset(48, 6), 22, cloudBasePaint);
    canvas.drawCircle(const Offset(-12, 4), 26, cloudBasePaint);
    canvas.drawCircle(const Offset(12, 4), 26, cloudBasePaint);

    // Fluffy top highlights for volume & depth
    canvas.drawCircle(const Offset(-22, -6), 18, cloudHighlightPaint);
    canvas.drawCircle(const Offset(0, -14), 22, cloudHighlightPaint);
    canvas.drawCircle(const Offset(22, -6), 18, cloudHighlightPaint);

    canvas.restore();
  }

  void _drawDistantHills(Canvas canvas, double w, double groundY) {
    final hillPaint = Paint()
      ..color = const Color(0xFF1E3A8A).withAlpha(140) // Soft deep navy mountains
      ..style = PaintingStyle.fill;

    final path = Path()..moveTo(0, groundY);

    const period = 320.0;
    final startX = -_distantHillsOffset;

    for (double x = startX - period; x < w + period; x += period) {
      path.lineTo(x, groundY - 80);
      path.quadraticBezierTo(
        x + period * 0.25,
        groundY - 145,
        x + period * 0.5,
        groundY - 85,
      );
      path.quadraticBezierTo(
        x + period * 0.75,
        groundY - 120,
        x + period,
        groundY - 80,
      );
    }
    path.lineTo(w, groundY);
    path.close();

    canvas.drawPath(path, hillPaint);
  }

  void _drawMidgroundHills(Canvas canvas, double w, double groundY) {
    final hillPaint = Paint()
      ..color = const Color(0xFF0284C7) // Vivid ocean blue midground
      ..style = PaintingStyle.fill;

    final hillBorderPaint = Paint()
      ..color = const Color(0xFF072C5B) // Deep midnight navy border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path()..moveTo(0, groundY);

    const period = 240.0;
    final startX = -_midHillsOffset;

    for (double x = startX - period; x < w + period; x += period) {
      path.lineTo(x, groundY - 45);
      path.quadraticBezierTo(
        x + period * 0.3,
        groundY - 95,
        x + period * 0.6,
        groundY - 50,
      );
      path.quadraticBezierTo(
        x + period * 0.85,
        groundY - 80,
        x + period,
        groundY - 45,
      );
    }
    path.lineTo(w, groundY);
    path.close();

    canvas.drawPath(path, hillPaint);
    canvas.drawPath(path, hillBorderPaint);

    // Decorative flowers on hill ridges
    final flowerPaint = Paint()..style = PaintingStyle.fill;
    for (double x = startX - period; x < w + period; x += 60.0) {
      flowerPaint.color = Colors.white;
      canvas.drawCircle(Offset(x + 20, groundY - 35), 3.0, flowerPaint);
      flowerPaint.color = const Color(0xFF38BDF8); // Bright cyan flower core
      canvas.drawCircle(Offset(x + 20, groundY - 35), 1.5, flowerPaint);
    }
  }
}
