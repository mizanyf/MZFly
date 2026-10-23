import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../game_status.dart';
import '../mz_fly_game.dart';
import 'particle_effects.dart';

/// The player character: an adorable cartoon blue bird with expressive eyes,
/// dynamic wing flapping, rotation physics, and hit detection.
class BirdPlayer extends PositionComponent
    with CollisionCallbacks, HasGameReference<MzFlyGame> {
  static const double playerWidth = 48.0;
  static const double playerHeight = 40.0;
  static const double gravity = 980.0;
  static const double flapImpulse = -340.0;
  static const double maxFallSpeed = 620.0;

  Vector2 velocity = Vector2.zero();

  double _baseY = 0.0;
  double _hoverTime = 0.0;
  double _wingTime = 0.0;
  double _blinkTimer = 0.0;
  bool _isBlinking = false;
  bool isDead = false;

  late final CircleHitbox hitbox;

  BirdPlayer()
    : super(
        size: Vector2(playerWidth, playerHeight),
        anchor: Anchor.center,
        priority: 20,
      );

  @override
  Future<void> onLoad() async {
    super.onLoad();
    // Forgiving circular hitbox centered on the bird's chubby torso
    hitbox = CircleHitbox(
      radius: 16.0,
      position: Vector2(size.x / 2 - 16.0, size.y / 2 - 16.0),
    );
    add(hitbox);
  }

  /// Sets bird position to initial spawn point.
  void reset(Vector2 spawnPosition) {
    position = spawnPosition.clone();
    _baseY = position.y;
    velocity = Vector2.zero();
    angle = 0.0;
    isDead = false;
    _hoverTime = 0.0;
    _wingTime = 0.0;
    _blinkTimer = 0.0;
    _isBlinking = false;
  }

  /// Performs a flap impulse.
  void flap() {
    if (isDead) return;
    velocity.y = flapImpulse;
    game.audio.playFlap();

    // Spawn flap puff behind the bird
    final puffPos = position + Vector2(-18.0, 6.0);
    game.add(
      FlapPuffParticle(
        position: puffPos,
        velocity: Vector2(-60.0 - Random().nextDouble() * 30.0, 15.0),
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Blinking logic
    _blinkTimer += dt;
    if (_blinkTimer > 3.0) {
      _isBlinking = true;
      if (_blinkTimer > 3.14) {
        _isBlinking = false;
        _blinkTimer = 0.0;
      }
    }

    if (game.status == GameStatus.menu || game.status == GameStatus.ready) {
      // Gentle idle hover animation
      _hoverTime += dt * 4.5;
      _wingTime += dt * 14.0;
      position.y = _baseY + sin(_hoverTime) * 9.0;
      angle = sin(_hoverTime * 0.7) * 0.06;
      velocity.setZero();
      return;
    }

    if (game.status == GameStatus.playing || isDead) {
      // Apply gravity
      velocity.y += gravity * dt;
      if (velocity.y > maxFallSpeed) {
        velocity.y = maxFallSpeed;
      }

      position.y += velocity.y * dt;

      // Ceiling boundary: player cannot fly beyond screen top
      if (position.y < size.y / 2) {
        position.y = size.y / 2;
        if (velocity.y < 0) velocity.y = 0;
      }

      // Smooth rotation based on vertical velocity
      if (!isDead) {
        // Fast wing flaps when rising, glide when falling
        _wingTime += dt * (velocity.y < 0 ? 30.0 : 12.0);

        final targetAngle = (velocity.y / 480.0).clamp(-0.48, 1.25);
        angle += (targetAngle - angle) * (dt * 12.0);
      } else {
        // Tumble rotation when falling after hit
        angle = min(angle + dt * 6.0, 1.57); // up to 90 degrees dive
      }
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (!isDead && game.status == GameStatus.playing) {
      game.onPlayerHit();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final w = size.x;
    final h = size.y;

    // Wing flap offset based on sine wave
    final wingFlap = sin(_wingTime);

    // Colors
    const bodyColor = Color(0xFF29B6F6); // Bright sky blue
    const bodyDark = Color(0xFF0277BD);
    const outlineColor = Color(0xFF01579B); // Dark cartoon outline
    const bellyColor = Color(0xFFFFFFFF); // Clean white belly
    const blushColor = Color(0x99FF8A80); // Rosy blush
    const beakColor = Color(0xFFFFA000); // Vibrant orange
    const beakOutline = Color(0xFFE65100);

    final outlinePaint = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()..style = PaintingStyle.fill;

    // 1. Tail Feathers (left side)
    final tailPath = Path()
      ..moveTo(6, h * 0.52)
      ..lineTo(0, h * 0.42)
      ..lineTo(4, h * 0.58)
      ..lineTo(-2, h * 0.68)
      ..lineTo(10, h * 0.65)
      ..close();
    fillPaint.color = bodyDark;
    canvas.drawPath(tailPath, fillPaint);
    canvas.drawPath(tailPath, outlinePaint);

    // 2. Head Crest Tuft
    final crestPath = Path()
      ..moveTo(w * 0.45, 6)
      ..lineTo(w * 0.42, -4)
      ..lineTo(w * 0.52, 2)
      ..lineTo(w * 0.56, -6)
      ..lineTo(w * 0.60, 6)
      ..close();
    fillPaint.color = bodyColor;
    canvas.drawPath(crestPath, fillPaint);
    canvas.drawPath(crestPath, outlinePaint);

    // 3. Main Round Body
    final bodyRect = Rect.fromCenter(
      center: Offset(w * 0.5, h * 0.52),
      width: w * 0.76,
      height: h * 0.82,
    );
    fillPaint.color = bodyColor;
    canvas.drawOval(bodyRect, fillPaint);

    // 4. White Belly Patch
    final bellyRect = Rect.fromCenter(
      center: Offset(w * 0.58, h * 0.64),
      width: w * 0.46,
      height: h * 0.50,
    );
    fillPaint.color = bellyColor;
    canvas.drawOval(bellyRect, fillPaint);

    // Body Outline
    canvas.drawOval(bodyRect, outlinePaint);

    // 5. Cheerful Cheek Blush
    fillPaint.color = blushColor;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.66, h * 0.62), width: 10, height: 6),
      fillPaint,
    );

    // 6. Wing (with animated flapping angle)
    canvas.save();
    canvas.translate(w * 0.35, h * 0.55);
    // Flap up and down
    final wingAngle = isDead ? 0.3 : (wingFlap * 0.45);
    canvas.rotate(wingAngle);

    final wingPath = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(-16, 6 + wingFlap * 4, -12, 18)
      ..quadraticBezierTo(2, 16, 12, 2)
      ..close();

    fillPaint.color = const Color(0xFF039BE5);
    canvas.drawPath(wingPath, fillPaint);
    canvas.drawPath(wingPath, outlinePaint);
    canvas.restore();

    // 7. Expressive Eye
    final eyeCenter = Offset(w * 0.68, h * 0.38);
    if (isDead) {
      // Knockout 'X' eyes on death
      final xPaint = Paint()
        ..color = outlineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        eyeCenter + const Offset(-5, -5),
        eyeCenter + const Offset(5, 5),
        xPaint,
      );
      canvas.drawLine(
        eyeCenter + const Offset(-5, 5),
        eyeCenter + const Offset(5, -5),
        xPaint,
      );
    } else if (_isBlinking) {
      // Happy closed curved eye when blinking
      final blinkPaint = Paint()
        ..color = outlineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..strokeCap = StrokeCap.round;
      final blinkPath = Path()
        ..moveTo(eyeCenter.dx - 6, eyeCenter.dy)
        ..quadraticBezierTo(
          eyeCenter.dx,
          eyeCenter.dy + 4,
          eyeCenter.dx + 6,
          eyeCenter.dy,
        );
      canvas.drawPath(blinkPath, blinkPaint);
    } else {
      // Big cartoon sparkling eye
      // Sclera
      fillPaint.color = Colors.white;
      canvas.drawOval(
        Rect.fromCenter(center: eyeCenter, width: 15, height: 17),
        fillPaint,
      );
      canvas.drawOval(
        Rect.fromCenter(center: eyeCenter, width: 15, height: 17),
        outlinePaint,
      );

      // Pupil & Iris
      fillPaint.color = const Color(0xFF0F172A);
      canvas.drawCircle(eyeCenter + const Offset(2, 0), 5.0, fillPaint);

      // Sparkle Highlights
      fillPaint.color = Colors.white;
      canvas.drawCircle(eyeCenter + const Offset(0.5, -2.5), 2.2, fillPaint);
      canvas.drawCircle(eyeCenter + const Offset(3.5, 1.5), 1.2, fillPaint);

      // Cute Eyebrow
      final browPaint = Paint()
        ..color = outlineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round;
      final browPath = Path()
        ..moveTo(eyeCenter.dx - 6, eyeCenter.dy - 10)
        ..quadraticBezierTo(
          eyeCenter.dx,
          eyeCenter.dy - 13,
          eyeCenter.dx + 6,
          eyeCenter.dy - 10,
        );
      canvas.drawPath(browPath, browPaint);
    }

    // 8. Cute Orange Beak
    final beakPath = Path()
      ..moveTo(w * 0.78, h * 0.44)
      ..lineTo(w * 1.05, h * 0.52)
      ..lineTo(w * 0.76, h * 0.62)
      ..close();

    fillPaint.color = beakColor;
    canvas.drawPath(beakPath, fillPaint);
    canvas.drawPath(
      beakPath,
      Paint()
        ..color = beakOutline
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeJoin = StrokeJoin.round,
    );
    // Smile line across beak
    canvas.drawLine(
      Offset(w * 0.78, h * 0.52),
      Offset(w * 0.98, h * 0.53),
      Paint()
        ..color = beakOutline
        ..strokeWidth = 1.6,
    );
  }
}
