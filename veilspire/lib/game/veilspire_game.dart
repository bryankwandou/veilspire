import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../characters/characters.dart';
import '../characters/npcs.dart';

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

    // Background population: archetype villagers with barked lines.
    for (final f in buildPopulation()) {
      world.add(FlavorNpcComponent(f)
        ..position = Vector2(f.position.dx, f.position.dy));
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
    _landmarks(canvas);
  }

  /// Named places from the world atlas, drawn as simple structures.
  void _landmarks(Canvas canvas) {
    final p = Paint();

    // Hallowlight Village: limestone houses with slate roofs.
    for (final (hx, hy) in [(880.0, 760.0), (1000.0, 740.0), (940.0, 900.0)]) {
      p.color = const Color(0xFFD8D2C4);
      canvas.drawRect(Rect.fromLTWH(hx, hy, 70, 52), p);
      p.color = const Color(0xFF4C566A);
      canvas.drawPath(
        Path()
          ..moveTo(hx - 6, hy)
          ..lineTo(hx + 35, hy - 30)
          ..lineTo(hx + 76, hy)
          ..close(),
        p,
      );
    }
    // The cracked sundial monument.
    p.color = const Color(0xFFB8B2A4);
    canvas.drawCircle(const Offset(960, 830), 16, p);
    _label(canvas, 'Hallowlight Village', 940, 700);

    // The Terraces: stepped field lines west of the village.
    p.color = const Color(0x3314532D);
    for (int i = 0; i < 4; i++) {
      canvas.drawRect(Rect.fromLTWH(620, 1060.0 + i * 34, 220, 22), p);
    }
    _label(canvas, 'The Terraces', 660, 1020);

    // Windrow Bridge, crossing toward Mirror Lake.
    p.color = const Color(0xFF8A6B3F);
    canvas.drawRect(const Rect.fromLTWH(1800, 1720, 150, 36), p);
    p.color = const Color(0xFF6B4F2A);
    for (int i = 0; i < 5; i++) {
      canvas.drawRect(Rect.fromLTWH(1808.0 + i * 30, 1720, 6, 36), p);
    }
    _label(canvas, 'Windrow Bridge', 1790, 1690);

    // Stillwater Dock: stilt walkway onto the lake.
    p.color = const Color(0xFF6B4F2A);
    canvas.drawRect(const Rect.fromLTWH(1980, 1990, 130, 22), p);
    canvas.drawRect(const Rect.fromLTWH(2080, 2010, 22, 90), p);
    _label(canvas, 'Stillwater Dock', 1960, 1950);

    // Lyra's Watch: the lighthouse tower on the shore.
    p.color = const Color(0xFFE8E4DA);
    canvas.drawRect(const Rect.fromLTWH(2200, 2080, 34, 96), p);
    p.color = const Color(0xFF35C4B5);
    canvas.drawRect(const Rect.fromLTWH(2200, 2104, 34, 16), p);
    canvas.drawCircle(const Offset(2217, 2072), 12, p);
    _label(canvas, "Lyra's Watch", 2180, 2040);

    // The Drowned Chapel: half-submerged in the lake.
    p.color = const Color(0xFF9AA5B8);
    canvas.drawRect(const Rect.fromLTWH(2440, 2430, 80, 40), p);
    canvas.drawPath(
      Path()
        ..moveTo(2440, 2430)
        ..lineTo(2480, 2398)
        ..lineTo(2520, 2430)
        ..close(),
      p,
    );
    _label(canvas, 'The Drowned Chapel', 2400, 2370);

    // Forgehearth and Kaelen's Forge: the communal fire.
    p.color = const Color(0xFF5A4638);
    canvas.drawRect(const Rect.fromLTWH(780, 2200, 90, 64), p);
    p.color = const Color(0xFFFF8C42);
    canvas.drawCircle(const Offset(825, 2196), 12, p);
    p.color = const Color(0xFFFFC24B);
    canvas.drawCircle(const Offset(825, 2192), 6, p);
    _label(canvas, "Forgehearth · Kaelen's Forge", 740, 2160);

    // The Cinder Flats marker.
    _label(canvas, 'The Cinder Flats', 1020, 2440);

    // The Cracked Observatory: dome shattered outward.
    p.color = const Color(0xFF6E7B8E);
    canvas.drawRect(const Rect.fromLTWH(2200, 620, 90, 110), p);
    p.color = const Color(0xFF8B93A7);
    canvas.drawArc(
      const Rect.fromLTWH(2192, 570, 106, 80),
      math.pi,
      math.pi * 0.7,
      true,
      p,
    );
    _label(canvas, 'The Cracked Observatory', 2150, 540);
    _label(canvas, 'The Archive Below', 2320, 780);

    // The tower label.
    _label(canvas, 'The Veilspire', kWorldSize / 2 - 55, kWorldSize / 2 + 110);
  }

  void _label(Canvas canvas, String text, double x, double y) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
          shadows: [Shadow(blurRadius: 6, color: Colors.black)],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(x, y));
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

/// A background villager: archetype-driven, shows a barked line when the
/// Wanderer walks close.
class FlavorNpcComponent extends PositionComponent
    with HasGameReference<VeilspireGame> {
  FlavorNpcComponent(this.npc)
      : super(size: Vector2(36, 48), anchor: Anchor.center);

  final FlavorNpc npc;
  double _t = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _t += dt;
  }

  @override
  void render(Canvas canvas) {
    final bob = math.sin(_t * 1.8) * 2;
    final p = Paint();
    p.color = const Color(0x33000000);
    canvas.drawOval(
        Rect.fromCenter(center: const Offset(18, 46), width: 26, height: 8),
        p);
    p.color = npc.archetype.outfit;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(7, 20 + bob, 22, 24),
        const Radius.circular(7),
      ),
      p,
    );
    p.color = const Color(0xFFEED8C0);
    canvas.drawCircle(Offset(18, 12 + bob), 8, p);

    final near = game.player.position.distanceTo(position) < 130;
    if (near) {
      // Bark bubble.
      final tp = TextPainter(
        text: TextSpan(
          text: '${npc.name} · ${npc.archetype.role}\n${npc.bark}',
          style: const TextStyle(color: Colors.white, fontSize: 10.5),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: 190);
      final rect = Rect.fromLTWH(
          18 - tp.width / 2 - 8, -tp.height - 26, tp.width + 16, tp.height + 12);
      p.color = const Color(0xDD0F1626);
      canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(8)), p);
      tp.paint(canvas, Offset(rect.left + 8, rect.top + 6));
    } else {
      final tp = TextPainter(
        text: TextSpan(
          text: npc.name.split(' ').first,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.75),
            fontSize: 9.5,
            shadows: const [Shadow(blurRadius: 3, color: Colors.black)],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(18 - tp.width / 2, -14));
    }
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
