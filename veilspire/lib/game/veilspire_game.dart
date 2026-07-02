import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../characters/characters.dart';

const double kWorldSize = 3200;

/// Deterministic pseudo-noise so the world looks the same every run.
double _noise(double x, double y) {
  final v = math.sin(x * 12.9898 + y * 78.233) * 43758.5453;
  return v - v.floorToDouble();
}

class VeilspireGame extends FlameGame {
  VeilspireGame({required this.onNearCharacter});

  final void Function(VeilCharacter? c) onNearCharacter;

  late final PlayerComponent player;
  late final JoystickComponent joystick;
  final List<NpcComponent> npcs = [];
  VeilCharacter? nearCharacter;

  @override
  Color backgroundColor() => const Color(0xFF0B1B2A);

  @override
  Future<void> onLoad() async {
    world.add(TerrainComponent());

    for (final c in kCast) {
      final npc = NpcComponent(c)
        ..position = Vector2(c.worldPosition.dx, c.worldPosition.dy);
      npcs.add(npc);
      world.add(npc);
    }

    player = PlayerComponent()..position = Vector2(1600, 1600);
    world.add(player);
    camera.follow(player);
    camera.viewfinder.zoom = 1.0;

    joystick = JoystickComponent(
      knob: CircleComponent(
        radius: 22,
        paint: Paint()..color = const Color(0xCCFFFFFF),
      ),
      background: CircleComponent(
        radius: 52,
        paint: Paint()..color = const Color(0x33FFFFFF),
      ),
      margin: const EdgeInsets.only(left: 36, bottom: 36),
    );
    camera.viewport.add(joystick);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!joystick.delta.isZero()) {
      player.move(joystick.relativeDelta, dt);
    }
    VeilCharacter? near;
    for (final npc in npcs) {
      if (npc.position.distanceTo(player.position) < 140) {
        near = npc.character;
        break;
      }
    }
    if (near != nearCharacter) {
      nearCharacter = near;
      onNearCharacter(near);
    }
  }
}

/// Procedurally painted terrain: meadows, lake, forest, ember hollow, spire.
class TerrainComponent extends PositionComponent {
  TerrainComponent() : super(size: Vector2.all(kWorldSize), priority: -10);

  @override
  void render(Canvas canvas) {
    const tile = 64.0;
    final paint = Paint();
    for (double x = 0; x < kWorldSize; x += tile) {
      for (double y = 0; y < kWorldSize; y += tile) {
        paint.color = _tileColor(x, y);
        canvas.drawRect(Rect.fromLTWH(x, y, tile, tile), paint);
        final n = _noise(x, y);
        if (n > 0.86) {
          // scatter trees / rocks / flowers depending on biome
          final cx = x + tile * _noise(y, x);
          final cy = y + tile * _noise(x + 1, y + 1);
          _decor(canvas, cx, cy, x, y);
        }
      }
    }
    // The Veilspire itself, center of the world.
    final spire = Paint()..color = const Color(0xFFEDE7FF);
    final cx = kWorldSize / 2, cy = kWorldSize / 2;
    canvas.drawPath(
      Path()
        ..moveTo(cx - 60, cy + 80)
        ..lineTo(cx, cy - 220)
        ..lineTo(cx + 60, cy + 80)
        ..close(),
      spire,
    );
    canvas.drawCircle(
      Offset(cx, cy - 220),
      26,
      Paint()..color = const Color(0xFF9E7BFF),
    );
  }

  Color _tileColor(double x, double y) {
    final cx = x - kWorldSize / 2, cy = y - kWorldSize / 2;
    final d = math.sqrt(cx * cx + cy * cy);
    final n = _noise(x * 0.01, y * 0.01);
    // Mirror Lake: south east
    if (x > 1900 && y > 1800 && x < 2800 && y < 2700) {
      return Color.lerp(
        const Color(0xFF184C78),
        const Color(0xFF2A6FA8),
        n,
      )!;
    }
    // Ember Hollow: south west
    if (x < 1300 && y > 1900) {
      return Color.lerp(
        const Color(0xFF4A2A1E),
        const Color(0xFF6B3A24),
        n,
      )!;
    }
    // Sundered Watch ruins: north east
    if (x > 1900 && y < 1100) {
      return Color.lerp(
        const Color(0xFF3B4252),
        const Color(0xFF4C566A),
        n,
      )!;
    }
    // Spire plateau
    if (d < 320) {
      return Color.lerp(
        const Color(0xFF3A3357),
        const Color(0xFF4A4170),
        n,
      )!;
    }
    // Azure Meadow default
    return Color.lerp(
      const Color(0xFF1F5E3A),
      const Color(0xFF2E7D4C),
      n,
    )!;
  }

  void _decor(Canvas canvas, double cx, double cy, double bx, double by) {
    final p = Paint();
    if (bx > 1900 && by > 1800) return; // no trees on the lake
    if (bx < 1300 && by > 1900) {
      p.color = const Color(0xFFFF8C42); // ember shards
      canvas.drawCircle(Offset(cx, cy), 5, p);
      return;
    }
    if (bx > 1900 && by < 1100) {
      p.color = const Color(0xFF8B93A7); // broken pillars
      canvas.drawRect(Rect.fromCenter(center: Offset(cx, cy), width: 14, height: 28), p);
      return;
    }
    p.color = const Color(0xFF14532D); // canopy
    canvas.drawCircle(Offset(cx, cy), 16, p);
    p.color = const Color(0xFF166534);
    canvas.drawCircle(Offset(cx - 6, cy - 6), 10, p);
  }
}

/// The Wanderer.
class PlayerComponent extends PositionComponent {
  PlayerComponent() : super(size: Vector2(46, 60), anchor: Anchor.center);

  static const _speed = 260.0;
  double _bob = 0;
  bool _moving = false;

  void move(Vector2 dir, double dt) {
    position += dir * _speed * dt;
    position.clamp(Vector2.all(40), Vector2.all(kWorldSize - 40));
    _moving = true;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _bob += dt * (_moving ? 10 : 3);
    _moving = false;
  }

  @override
  void render(Canvas canvas) {
    final bob = math.sin(_bob) * 2;
    final p = Paint();
    // shadow
    p.color = const Color(0x44000000);
    canvas.drawOval(Rect.fromCenter(center: const Offset(23, 58), width: 34, height: 10), p);
    // cloak
    p.color = const Color(0xFFEFB958);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(8, 22 + bob, 30, 30),
        const Radius.circular(9),
      ),
      p,
    );
    // head
    p.color = const Color(0xFFFFE3D0);
    canvas.drawCircle(Offset(23, 14 + bob), 11, p);
    // hair
    p.color = const Color(0xFF4B3B2A);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(23, 12 + bob), radius: 11.5),
      math.pi, math.pi, false, p,
    );
  }
}

/// A callable resident of Veilspire, standing in their home region.
class NpcComponent extends PositionComponent {
  NpcComponent(this.character)
      : super(size: Vector2(46, 62), anchor: Anchor.center);

  final VeilCharacter character;
  double _t = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _t += dt;
  }

  @override
  void render(Canvas canvas) {
    final bob = math.sin(_t * 2.2) * 2.5;
    final p = Paint();
    p.color = const Color(0x44000000);
    canvas.drawOval(Rect.fromCenter(center: const Offset(23, 60), width: 34, height: 10), p);
    // outfit
    p.color = character.primary;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(8, 24 + bob, 30, 30),
        const Radius.circular(9),
      ),
      p,
    );
    // head
    p.color = character.skin;
    canvas.drawCircle(Offset(23, 15 + bob), 11, p);
    // hair
    p.color = character.hair;
    if (character.isFemale) {
      canvas.drawArc(
        Rect.fromCircle(center: Offset(23, 13 + bob), radius: 12),
        math.pi, math.pi, false, p,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(9, 13 + bob, 6, 26), const Radius.circular(3)),
        p,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(31, 13 + bob, 6, 26), const Radius.circular(3)),
        p,
      );
    } else {
      canvas.drawArc(
        Rect.fromCircle(center: Offset(23, 12 + bob), radius: 11.5),
        math.pi, math.pi, false, p,
      );
    }
    // element glow marker above the head
    p.color = character.accent.withValues(alpha: 0.6 + math.sin(_t * 3) * 0.3);
    canvas.drawCircle(Offset(23, -6 + bob), 5, p);

    // name plate
    final tp = TextPainter(
      text: TextSpan(
        text: character.name.split(' ').first,
        style: const TextStyle(
          color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600,
          shadows: [Shadow(blurRadius: 4, color: Colors.black)],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(23 - tp.width / 2, -26));
  }
}
