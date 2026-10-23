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
        (_cloudOffset1 + 12.0 * dt * scrollMultiplier) % (game.size.x + 180);
    _cloudOffset2 =
        (_cloudOffset2 + 18.0 * dt * scrollMultiplier) % (game.size.x + 220);
    _cloudOffset3 =
        (_cloudOffset3 + 24.0 * dt * scrollMultiplier) % (game.size.x + 160);

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

    // 1. Sky Gradient
    final skyRect = Rect.fromLTWH(0, 0, w, h);
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF29B6F6), // Cerulean sky
          Color(0xFF81D4FA),
          Color(0xFFE1F5FE), // Soft warm horizon
        ],
        stops: [0.0, 0.55, 1.0],
      ).createShader(skyRect);
    canvas.drawRect(skyRect, skyPaint);

    // 2. Cartoon Sun (top right)
    final sunCenter = Offset(w - 60, 80);
    final pulse = sin(_sunPulseTime) * 3.0;

    // Soft outer sun glow
    canvas.drawCircle(
      sunCenter,
      44.0 + pulse,
      Paint()..color = const Color(0x33FFF59D),
    );
    canvas.drawCircle(
      sunCenter,
      36.0 + pulse * 0.5,
      Paint()..color = const Color(0x66FFF176),
    );
    // Sun core
    canvas.drawCircle(
      sunCenter,
      28.0,
      Paint()..color = const Color(0xFFFFEE58),
    );
    canvas.drawCircle(
      sunCenter,
      28.0,
      Paint()
        ..color = const Color(0xFFFBC02D)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );

    // 3. Drifting Clouds (High Altitude)
    _drawCloud(canvas, Offset(w - _cloudOffset1, 70), 0.75);
    _drawCloud(canvas, Offset(w * 0.7 - _cloudOffset2, 130), 1.0);
    _drawCloud(canvas, Offset(w * 1.3 - _cloudOffset3, 180), 0.85);

    // 4. Distant Pastel Blue-Green Hills
    _drawDistantHills(canvas, w, groundY);

    // 5. Midground Lush Rolling Green Hills
    _drawMidgroundHills(canvas, w, groundY);
  }

  void _drawCloud(Canvas canvas, Offset pos, double scale) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.scale(scale, scale);
    final cloudPaint = Paint()..color = const Color(0xF2FFFFFF);
    final shadowPaint = Paint()..color = const Color(0x40B3E5FC);

    // Bottom soft shadow
    canvas.drawOval(const Rect.fromLTWH(-55, -8, 110, 42), shadowPaint);

    // Puffy cloud lobes
    canvas.drawCircle(const Offset(-32, 5), 24, cloudPaint);
    canvas.drawCircle(const Offset(0, -8), 32, cloudPaint);
    canvas.drawCircle(const Offset(32, 4), 22, cloudPaint);
    canvas.drawCircle(const Offset(-12, -2), 26, cloudPaint);
    canvas.drawCircle(const Offset(16, 2), 24, cloudPaint);

    canvas.restore();
  }

  void _drawDistantHills(Canvas canvas, double w, double groundY) {
    final hillPaint = Paint()
      ..color =
          const Color(0xFF80CBC4) // Soft muted teal/green
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
      ..color =
          const Color(0xFF81C784) // Vibrant midground green
      ..style = PaintingStyle.fill;

    final hillBorderPaint = Paint()
      ..color = const Color(0xFF43A047)
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
      flowerPaint.color = const Color(0xFFFFD54F);
      canvas.drawCircle(Offset(x + 20, groundY - 35), 1.5, flowerPaint);
    }
  }
}
