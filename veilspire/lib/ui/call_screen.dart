import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:record/record.dart';

import '../characters/characters.dart';
import '../services/groq_service.dart';

enum CallState { idle, listening, thinking, speaking }

/// Video-call style screen: live animated character face, real-time
/// voice loop (mic -> Whisper -> LLM -> TTS) plus a text lane.
class CallScreen extends StatefulWidget {
  const CallScreen({super.key, required this.character, this.videoMode = true});

  final VeilCharacter character;
  final bool videoMode;

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen>
    with SingleTickerProviderStateMixin {
  final _recorder = AudioRecorder();
  final _player = AudioPlayer();
  final _textCtrl = TextEditingController();
  final List<Map<String, String>> _history = [];
  final List<(bool fromUser, String text)> _transcript = [];

  CallState _state = CallState.idle;
  String? _error;
  late final AnimationController _anim;
  Duration _elapsed = Duration.zero;
  Timer? _clock;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat();
    _clock = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsed += const Duration(seconds: 1));
    });
    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _state = CallState.idle);
    });
    _greet();
  }

  Future<void> _greet() async {
    await _respond(
        'The veil-link just connected. Greet the Wanderer like answering a call.');
  }

  Future<void> _respond(String userMessage, {bool record = true}) async {
    setState(() {
      _state = CallState.thinking;
      _error = null;
      if (record) _transcript.add((true, userMessage));
    });
    try {
      final reply = await GroqService.instance.chat(
        systemPrompt: widget.character.systemPrompt,
        history: _history,
        userMessage: userMessage,
      );
      _history
        ..add({'role': 'user', 'content': userMessage})
        ..add({'role': 'assistant', 'content': reply});
      setState(() => _transcript.add((false, reply)));
      try {
        final wav = await GroqService.instance
            .speak(reply, femaleVoice: widget.character.isFemale);
        setState(() => _state = CallState.speaking);
        await _player.play(BytesSource(Uint8List.fromList(wav)));
      } catch (_) {
        // TTS quota can run out; the call continues as text.
        setState(() => _state = CallState.idle);
      }
    } catch (e) {
      setState(() {
        _state = CallState.idle;
        _error = 'Link unstable: $e';
      });
    }
  }

  Future<void> _toggleMic() async {
    if (_state == CallState.listening) {
      final path = await _recorder.stop();
      setState(() => _state = CallState.thinking);
      if (path == null) return setState(() => _state = CallState.idle);
      try {
        final bytes = await File(path).readAsBytes();
        final text = await GroqService.instance.transcribe(bytes, 'voice.m4a');
        if (text.isEmpty) return setState(() => _state = CallState.idle);
        await _respond(text);
      } catch (e) {
        setState(() {
          _state = CallState.idle;
          _error = 'Could not hear you: $e';
        });
      }
      return;
    }
    if (_state != CallState.idle) return;
    if (await _recorder.hasPermission()) {
      final dir = Directory.systemTemp;
      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: '${dir.path}/veil_voice.m4a',
      );
      setState(() => _state = CallState.listening);
    }
  }

  @override
  void dispose() {
    _anim.dispose();
    _clock?.cancel();
    _recorder.dispose();
    _player.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  String get _stateLabel => switch (_state) {
        CallState.idle => 'Connected',
        CallState.listening => 'Listening…',
        CallState.thinking => 'Weaving words…',
        CallState.speaking => 'Speaking',
      };

  @override
  Widget build(BuildContext context) {
    final c = widget.character;
    final mm = _elapsed.inMinutes.toString().padLeft(2, '0');
    final ss = (_elapsed.inSeconds % 60).toString().padLeft(2, '0');
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(widget.videoMode ? Icons.videocam : Icons.call,
                      color: c.accent, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.name,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700)),
                        Text('$_stateLabel · $mm:$ss',
                            style: TextStyle(color: c.accent, fontSize: 12)),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.call_end, color: Color(0xFFFF5C5C)),
                  ),
                ],
              ),
            ),
            if (widget.videoMode)
              Expanded(
                flex: 5,
                child: AnimatedBuilder(
                  animation: _anim,
                  builder: (_, __) => CustomPaint(
                    painter: _FacePainter(
                      character: c,
                      t: _anim.value,
                      talking: _state == CallState.speaking,
                      listening: _state == CallState.listening,
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            Expanded(
              flex: 4,
              child: ListView.builder(
                reverse: true,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _transcript.length,
                itemBuilder: (_, i) {
                  final (fromUser, text) =
                      _transcript[_transcript.length - 1 - i];
                  return Align(
                    alignment: fromUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(10),
                      constraints: const BoxConstraints(maxWidth: 300),
                      decoration: BoxDecoration(
                        color: fromUser
                            ? const Color(0xFF223047)
                            : c.primary.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(text,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 13.5)),
                    ),
                  );
                },
              ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(_error!,
                    style: const TextStyle(
                        color: Color(0xFFFF8A80), fontSize: 11)),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  FloatingActionButton(
                    heroTag: 'mic',
                    backgroundColor: _state == CallState.listening
                        ? const Color(0xFFFF5C5C)
                        : c.primary,
                    onPressed: _toggleMic,
                    child: Icon(
                      _state == CallState.listening ? Icons.stop : Icons.mic,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _textCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Say something through the veil…',
                        hintStyle:
                            const TextStyle(color: Colors.white38, fontSize: 13),
                        filled: true,
                        fillColor: const Color(0xFF16203A),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                      ),
                      onSubmitted: (v) {
                        if (v.trim().isEmpty) return;
                        _textCtrl.clear();
                        _respond(v.trim());
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Live animated character portrait: breathing, blinking, lip movement
/// while speaking, pulse ring while listening.
class _FacePainter extends CustomPainter {
  _FacePainter({
    required this.character,
    required this.t,
    required this.talking,
    required this.listening,
  });

  final VeilCharacter character;
  final double t;
  final bool talking;
  final bool listening;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final p = Paint();
    final breathe = math.sin(t * 2 * math.pi) * 4;

    // backdrop aura
    p.shader = RadialGradient(colors: [
      character.primary.withValues(alpha: 0.45),
      const Color(0xFF0A0E1A),
    ]).createShader(Rect.fromCircle(center: c, radius: size.height * 0.6));
    canvas.drawRect(Offset.zero & size, p);
    p.shader = null;

    if (listening) {
      p
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = character.accent.withValues(alpha: 1 - t);
      canvas.drawCircle(c, 110 + t * 60, p);
      p.style = PaintingStyle.fill;
    }

    final head = c.translate(0, breathe);
    // hair back
    p.color = character.hair;
    if (character.isFemale) {
      canvas.drawOval(
          Rect.fromCenter(center: head.translate(0, 30), width: 190, height: 240),
          p);
    }
    // face
    p.color = character.skin;
    canvas.drawOval(
        Rect.fromCenter(center: head, width: 150, height: 170), p);
    // fringe
    p.color = character.hair;
    canvas.drawArc(
        Rect.fromCenter(center: head.translate(0, -18), width: 158, height: 150),
        math.pi, math.pi, false, p);

    // eyes with periodic blink
    final blink = (math.sin(t * 2 * math.pi * 0.5) > 0.97) ? 0.12 : 1.0;
    p.color = const Color(0xFF1E2430);
    for (final dx in [-34.0, 34.0]) {
      canvas.drawOval(
          Rect.fromCenter(
              center: head.translate(dx, 8), width: 20, height: 26 * blink),
          p);
    }
    // iris glint
    p.color = character.primary;
    for (final dx in [-34.0, 34.0]) {
      canvas.drawCircle(head.translate(dx, 8), 4 * blink, p);
    }

    // mouth: oscillates while talking
    p.color = const Color(0xFFB35A4A);
    final mouthH = talking ? 6 + (math.sin(t * 2 * math.pi * 6).abs()) * 14 : 5.0;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: head.translate(0, 52), width: 34, height: mouthH),
        const Radius.circular(8),
      ),
      p,
    );

    // element sigil orbiting the head
    final a = t * 2 * math.pi;
    p.color = character.accent;
    canvas.drawCircle(
        head + Offset(math.cos(a) * 110, math.sin(a) * 40 - 60), 6, p);
  }

  @override
  bool shouldRepaint(_FacePainter old) => true;
}
