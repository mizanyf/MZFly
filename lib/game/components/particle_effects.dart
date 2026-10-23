import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Small cartoon wind puff / star particle emitted during flapping.
class FlapPuffParticle extends PositionComponent {
  final Vector2 velocity;
  final double maxLifetime;
  double _lifetime = 0.0;
  final double initialRadius;
  final Color color;

  FlapPuffParticle({
    required Vector2 position,
    required this.velocity,
    this.maxLifetime = 0.35,
    this.initialRadius = 6.0,
    this.color = const Color(0xFFFFFFFF),
  }) : super(position: position, anchor: Anchor.center, priority: 8);

  @override
  void update(double dt) {
    super.update(dt);
    _lifetime += dt;
    if (_lifetime >= maxLifetime) {
      removeFromParent();
      return;
    }
    position += velocity * dt;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final progress = (_lifetime / maxLifetime).clamp(0.0, 1.0);
    final alpha = ((1.0 - progress) * 255).toInt().clamp(0, 255);
    final currentRadius = initialRadius * (1.0 - progress * 0.5);

    final paint = Paint()
      ..color = color.withAlpha(alpha)
      ..style = PaintingStyle.fill;

    // Draw little cloud puff circle
    canvas.drawCircle(Offset.zero, currentRadius, paint);
  }
}

/// Burst of golden sparkling stars when scoring a point.
class ScoreStarBurst extends PositionComponent {
  final int count;
  final Random _rnd = Random();
  final List<_StarData> _stars = [];
  final double maxLifetime = 0.6;
  double _time = 0.0;

  ScoreStarBurst({required Vector2 position, this.count = 6})
    : super(position: position, anchor: Anchor.center, priority: 25) {
    for (int i = 0; i < count; i++) {
      final angle = (i * (2 * pi / count)) + (_rnd.nextDouble() * 0.4 - 0.2);
      final speed = 80.0 + _rnd.nextDouble() * 100.0;
      _stars.add(
        _StarData(
          velocity: Vector2(cos(angle) * speed, sin(angle) * speed),
          size: 6.0 + _rnd.nextDouble() * 5.0,
          rotationSpeed: (_rnd.nextDouble() - 0.5) * 8.0,
        ),
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
    if (_time >= maxLifetime) {
      removeFromParent();
      return;
    }
    for (final star in _stars) {
      star.position += star.velocity * dt;
      star.rotation += star.rotationSpeed * dt;
      // Slight gravity
      star.velocity.y += 120.0 * dt;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final progress = (_time / maxLifetime).clamp(0.0, 1.0);
    final alpha = ((1.0 - progress) * 255).toInt().clamp(0, 255);

    final paint = Paint()
      ..color = const Color(0xFFFFD54F).withAlpha(alpha)
      ..style = PaintingStyle.fill;

    for (final star in _stars) {
      canvas.save();
      canvas.translate(star.position.x, star.position.y);
      canvas.rotate(star.rotation);

      final r = star.size * (1.0 - progress * 0.3);
      final path = Path();
      for (int i = 0; i < 5; i++) {
        final a = -pi / 2 + i * (2 * pi / 5);
        final innerA = a + pi / 5;
        final x1 = cos(a) * r;
        final y1 = sin(a) * r;
        final x2 = cos(innerA) * (r * 0.45);
        final y2 = sin(innerA) * (r * 0.45);
        if (i == 0) {
          path.moveTo(x1, y1);
        } else {
          path.lineTo(x1, y1);
        }
        path.lineTo(x2, y2);
      }
      path.close();
      canvas.drawPath(path, paint);
      canvas.restore();
    }
  }
}

class _StarData {
  Vector2 position = Vector2.zero();
  final Vector2 velocity;
  final double size;
  double rotation = 0.0;
  final double rotationSpeed;

  _StarData({
    required this.velocity,
    required this.size,
    required this.rotationSpeed,
  });
}

/// Floating bouncy "+1" score popup.
class ScorePopupText extends PositionComponent {
  final double duration = 0.75;
  double _elapsed = 0.0;

  ScorePopupText({required Vector2 position})
    : super(position: position, anchor: Anchor.center, priority: 30);

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    if (_elapsed >= duration) {
      removeFromParent();
      return;
    }
    // Float upwards with deceleration
    position.y -= 45.0 * dt;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final progress = (_elapsed / duration).clamp(0.0, 1.0);
    final alpha = ((1.0 - progress) * 255).toInt().clamp(0, 255);
    final scale = 1.0 + sin(progress * pi) * 0.3;

    canvas.save();
    canvas.scale(scale, scale);

    final textPainter = TextPainter(
      text: TextSpan(
        text: '+1',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 26,
          fontWeight: FontWeight.w900,
          color: const Color(0xFFFFEB3B).withAlpha(alpha),
          shadows: [
            Shadow(
              blurRadius: 4,
              color: Colors.black.withAlpha((alpha * 0.7).toInt()),
              offset: const Offset(2, 2),
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );

    canvas.restore();
  }
}
