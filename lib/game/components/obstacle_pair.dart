import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../game_status.dart';
import '../mz_fly_game.dart';
import 'particle_effects.dart';

/// Single pipe component (either top or bottom) with cartoon styling and collision hitbox.
class PipeComponent extends PositionComponent with CollisionCallbacks {
  final bool isTop;

  PipeComponent({
    required Vector2 position,
    required Vector2 size,
    required this.isTop,
  }) : super(position: position, size: size, priority: 10);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    // Inset hitbox slightly for fair arcade play
    add(
      RectangleHitbox(
        position: Vector2(3, 2),
        size: Vector2(size.x - 6, size.y - 4),
      ),
    );
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final w = size.x;
    final h = size.y;
    const capHeight = 32.0;
    const capOverhang = 6.0;

    const mainBlue = Color(0xFF0284C7);
    const shadowBlue = Color(0xFF072C5B);
    const highlightBlue = Color(0xFF7DD3FC);
    const outlineColor = Color(0xFF071530);

    final outlinePaint = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()..style = PaintingStyle.fill;

    if (isTop) {
      // 1. Top pipe body (extends from y=0 down to h - capHeight)
      final bodyRect = Rect.fromLTWH(0, 0, w, max(0.0, h - capHeight));
      fillPaint.color = mainBlue;
      canvas.drawRect(bodyRect, fillPaint);

      // Highlight band
      canvas.drawRect(
        Rect.fromLTWH(10, 0, 10, max(0.0, h - capHeight)),
        Paint()..color = highlightBlue,
      );
      // Shadow band
      canvas.drawRect(
        Rect.fromLTWH(w - 14, 0, 8, max(0.0, h - capHeight)),
        Paint()..color = shadowBlue,
      );
      canvas.drawRect(bodyRect, outlinePaint);

      // 2. Top pipe rim cap at bottom end
      final capRect = Rect.fromLTWH(
        -capOverhang,
        h - capHeight,
        w + capOverhang * 2,
        capHeight,
      );
      final rCap = RRect.fromRectAndRadius(capRect, const Radius.circular(5));
      fillPaint.color = mainBlue;
      canvas.drawRRect(rCap, fillPaint);

      // Cap highlight & shadow
      canvas.drawRect(
        Rect.fromLTWH(-capOverhang + 12, h - capHeight + 3, 12, capHeight - 6),
        Paint()..color = highlightBlue,
      );
      canvas.drawRect(
        Rect.fromLTWH(
          w + capOverhang - 16,
          h - capHeight + 3,
          8,
          capHeight - 6,
        ),
        Paint()..color = shadowBlue,
      );
      canvas.drawRRect(rCap, outlinePaint);

      // Shadow line beneath cap
      canvas.drawLine(
        Offset(-capOverhang + 2, h - 3),
        Offset(w + capOverhang - 2, h - 3),
        Paint()
          ..color = shadowBlue
          ..strokeWidth = 3.0,
      );
    } else {
      // 1. Bottom pipe cap at top end
      final capRect = Rect.fromLTWH(
        -capOverhang,
        0,
        w + capOverhang * 2,
        capHeight,
      );
      final rCap = RRect.fromRectAndRadius(capRect, const Radius.circular(5));
      fillPaint.color = mainBlue;
      canvas.drawRRect(rCap, fillPaint);

      // Cap highlight & shadow
      canvas.drawRect(
        Rect.fromLTWH(-capOverhang + 12, 3, 12, capHeight - 6),
        Paint()..color = highlightBlue,
      );
      canvas.drawRect(
        Rect.fromLTWH(w + capOverhang - 16, 3, 8, capHeight - 6),
        Paint()..color = shadowBlue,
      );
      canvas.drawRRect(rCap, outlinePaint);

      // 2. Bottom pipe body (extends from y=capHeight down to h)
      final bodyRect = Rect.fromLTWH(0, capHeight, w, max(0.0, h - capHeight));
      fillPaint.color = mainBlue;
      canvas.drawRect(bodyRect, fillPaint);

      // Highlight band
      canvas.drawRect(
        Rect.fromLTWH(10, capHeight, 10, max(0.0, h - capHeight)),
        Paint()..color = highlightBlue,
      );
      // Shadow band
      canvas.drawRect(
        Rect.fromLTWH(w - 14, capHeight, 8, max(0.0, h - capHeight)),
        Paint()..color = shadowBlue,
      );
      canvas.drawRect(bodyRect, outlinePaint);

      // Drop shadow right under the cap onto the body
      canvas.drawRect(
        Rect.fromLTWH(0, capHeight, w, 6),
        Paint()..color = Colors.black.withAlpha(45),
      );
    }
  }
}

/// A scrolling pair of cartoon obstacles (top pipe and bottom pipe) with a playable gap.
class ObstaclePair extends PositionComponent with HasGameReference<MzFlyGame> {
  static const double pipeWidth = 66.0;
  static const double defaultSpeed = 150.0;

  final double topHeight;
  final double gapSize;
  final double groundY;
  bool hasScored = false;

  late final PipeComponent topPipe;
  late final PipeComponent bottomPipe;

  ObstaclePair({
    required double startX,
    required this.topHeight,
    required this.gapSize,
    required this.groundY,
  }) : super(
         position: Vector2(startX, 0),
         size: Vector2(pipeWidth, groundY),
         priority: 10,
       );

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Top pipe: from 0 to topHeight
    topPipe = PipeComponent(
      position: Vector2.zero(),
      size: Vector2(pipeWidth, topHeight),
      isTop: true,
    );
    add(topPipe);

    // Bottom pipe: from topHeight + gapSize down to groundY
    final bottomY = topHeight + gapSize;
    final bottomHeight = max(20.0, groundY - bottomY);
    bottomPipe = PipeComponent(
      position: Vector2(0, bottomY),
      size: Vector2(pipeWidth, bottomHeight),
      isTop: false,
    );
    add(bottomPipe);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (game.status != GameStatus.playing) return;

    // Move left
    position.x -= defaultSpeed * dt;

    // Check scoring: when bird passes center of this obstacle
    if (!hasScored && game.bird.position.x > position.x + (pipeWidth / 2)) {
      hasScored = true;
      game.incrementScore();

      final centerY = topHeight + (gapSize / 2);
      game.add(
        ScoreStarBurst(position: Vector2(position.x + pipeWidth / 2, centerY)),
      );
      game.add(
        ScorePopupText(
          position: Vector2(position.x + pipeWidth / 2, centerY - 25),
        ),
      );
    }

    // Recycle / remove offscreen
    if (position.x + pipeWidth < -30) {
      removeFromParent();
    }
  }
}
