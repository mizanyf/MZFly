import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../game_status.dart';
import '../mz_fly_game.dart';

/// The scrolling cartoon ground platform with grass surface and collision detection.
class GroundComponent extends PositionComponent
    with CollisionCallbacks, HasGameReference<MzFlyGame> {
  static const double groundHeight = 100.0;
  static const double scrollSpeed = 150.0;
  static const double stripeWidth = 28.0;

  double _scrollOffset = 0.0;

  GroundComponent() : super(anchor: Anchor.topLeft, priority: 15);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    _updateLayout();
    // Hitbox covering the entire ground surface
    add(
      RectangleHitbox(position: Vector2.zero(), size: Vector2(size.x, size.y)),
    );
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _updateLayout();
  }

  void _updateLayout() {
    size = Vector2(game.size.x, groundHeight);
    position = Vector2(0, game.size.y - groundHeight);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Scroll during menu, ready, and playing states for a lively world
    if (game.status != GameStatus.paused && !game.bird.isDead) {
      _scrollOffset = (_scrollOffset + scrollSpeed * dt) % stripeWidth;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final w = size.x;
    final h = size.y;

    // Palette (Dark navy earth to electric cyan surface)
    const earthColor = Color(0xFF0C1E3C);
    const earthStripeColor = Color(0xFF132B54);
    const grassColor = Color(0xFF38BDF8);
    const grassHighlight = Color(0xFFBAE6FD);
    const grassBorder = Color(0xFF0284C7);

    final fillPaint = Paint()..style = PaintingStyle.fill;

    // 1. Earth background
    fillPaint.color = earthColor;
    canvas.drawRect(Rect.fromLTWH(0, 16, w, h - 16), fillPaint);

    // 2. Scrolling diagonal earth stripes
    fillPaint.color = earthStripeColor;
    final startX = -stripeWidth - _scrollOffset;
    for (double x = startX; x < w + stripeWidth; x += stripeWidth) {
      final path = Path()
        ..moveTo(x, 16)
        ..lineTo(x + 14, 16)
        ..lineTo(x + 30, h)
        ..lineTo(x + 16, h)
        ..close();
      canvas.drawPath(path, fillPaint);
    }

    // 3. Top Grass / Crystal Surface Layer
    fillPaint.color = grassColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, w, 16), fillPaint);

    // Top Highlight
    canvas.drawLine(
      const Offset(0, 1),
      Offset(w, 1),
      Paint()
        ..color = grassHighlight
        ..strokeWidth = 2.5,
    );

    // Bottom Border
    canvas.drawLine(
      const Offset(0, 16),
      Offset(w, 16),
      Paint()
        ..color = grassBorder
        ..strokeWidth = 2.5,
    );

    // 4. Little decorative tufts along the edge
    fillPaint.color = grassColor;
    final tuftBorderPaint = Paint()
      ..color = grassBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (double x = startX; x < w + stripeWidth; x += 18.0) {
      final tuftPath = Path()
        ..moveTo(x, 16)
        ..lineTo(x + 7, 24)
        ..lineTo(x + 14, 16)
        ..close();
      canvas.drawPath(tuftPath, fillPaint);
      canvas.drawPath(tuftPath, tuftBorderPaint);
    }
  }
}
