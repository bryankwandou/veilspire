import 'dart:math' as math;

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'characters/characters.dart';
import 'game/veilspire_game.dart';
import 'ui/call_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: 'assets/.env');
  } catch (_) {
    // key can also arrive via --dart-define=GROQ_API_KEY=...
  }
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  runApp(const VeilspireApp());
}

class VeilspireApp extends StatelessWidget {
  const VeilspireApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Veilspire',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: const TitleScreen(),
    );
  }
}

class TitleScreen extends StatefulWidget {
  const TitleScreen({super.key});
  @override
  State<TitleScreen> createState() => _TitleScreenState();
}

class _TitleScreenState extends State<TitleScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 6))
      ..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _c,
        builder: (_, __) => CustomPaint(
          painter: _SkyPainter(_c.value),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('VEILSPIRE',
                    style: TextStyle(
                        fontSize: 52,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 14,
                        color: Colors.white)),
                const SizedBox(height: 6),
                Text('Echoes of the Sundered Sky',
                    style: TextStyle(
                        fontSize: 15,
                        letterSpacing: 4,
                        color: Colors.white.withValues(alpha: 0.75))),
                const SizedBox(height: 40),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF7C5CFF),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 48, vertical: 16),
                  ),
                  onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const GameScreen())),
                  child: const Text('Enter the Veil',
                      style: TextStyle(fontSize: 17, letterSpacing: 2)),
                ),
                const SizedBox(height: 14),
                Text('Walk the world. Call its people.',
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.5))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SkyPainter extends CustomPainter {
  _SkyPainter(this.t);
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF0B1026), Color(0xFF232052), Color(0xFF43276B)],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, p);
    p.shader = null;
    // drifting sky shards
    for (int i = 0; i < 40; i++) {
      final n = _hash(i.toDouble());
      final x = ((n * size.width) + t * 40 * (0.4 + n)) % size.width;
      final y = _hash(i + 99) * size.height;
      p.color = Color.lerp(const Color(0xFF9E7BFF), const Color(0xFF5CE1E6),
              _hash(i + 7))!
          .withValues(alpha: 0.35 + 0.3 * math.sin(t * math.pi * 2 + i));
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(n * math.pi);
      canvas.drawRect(
          Rect.fromCenter(
              center: Offset.zero, width: 4 + n * 10, height: 8 + n * 18),
          p);
      canvas.restore();
    }
  }

  double _hash(double v) {
    final x = math.sin(v * 127.1) * 43758.5453;
    return x - x.floorToDouble();
  }

  @override
  bool shouldRepaint(_SkyPainter old) => true;
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final VeilspireGame _game;
  VeilCharacter? _near;

  @override
  void initState() {
    super.initState();
    _game = VeilspireGame(onNearCharacter: (c) {
      if (mounted) setState(() => _near = c);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget(game: _game),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white70),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Veilspire · Sundered Realm',
                        style:
                            TextStyle(color: Colors.white70, fontSize: 12)),
                  ),
                ],
              ),
            ),
          ),
          if (_near != null)
            Positioned(
              right: 20,
              bottom: 30,
              child: _CallCard(
                character: _near!,
                onCall: (video) => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        CallScreen(character: _near!, videoMode: video),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CallCard extends StatelessWidget {
  const _CallCard({required this.character, required this.onCall});
  final VeilCharacter character;
  final void Function(bool video) onCall;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.all(14),
      width: 250,
      decoration: BoxDecoration(
        color: const Color(0xE6101827),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: character.primary.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(character.name,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15)),
          Text(character.title,
              style: TextStyle(color: character.accent, fontSize: 11)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                      backgroundColor: character.primary,
                      padding: const EdgeInsets.symmetric(vertical: 8)),
                  onPressed: () => onCall(true),
                  icon: const Icon(Icons.videocam, size: 16),
                  label: const Text('Video', style: TextStyle(fontSize: 12)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                      foregroundColor: character.accent,
                      padding: const EdgeInsets.symmetric(vertical: 8)),
                  onPressed: () => onCall(false),
                  icon: const Icon(Icons.call, size: 16),
                  label: const Text('Voice', style: TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
