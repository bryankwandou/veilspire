import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Thin client for the Groq API: chat, speech-to-text, text-to-speech.
class GroqService {
  GroqService._();
  static final GroqService instance = GroqService._();

  String get _key =>
      dotenv.maybeGet('GROQ_API_KEY') ??
      const String.fromEnvironment('GROQ_API_KEY');

  static const _base = 'https://api.groq.com/openai/v1';

  /// Rolling chat with a character. [history] holds prior turns.
  Future<String> chat({
    required String systemPrompt,
    required List<Map<String, String>> history,
    required String userMessage,
  }) async {
    final res = await http.post(
      Uri.parse('$_base/chat/completions'),
      headers: {
        'Authorization': 'Bearer $_key',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'llama-3.3-70b-versatile',
        'temperature': 0.9,
        'max_tokens': 220,
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          ...history,
          {'role': 'user', 'content': userMessage},
        ],
      }),
    );
    if (res.statusCode != 200) {
      throw Exception('Groq chat failed (${res.statusCode}): ${res.body}');
    }
    final data = jsonDecode(utf8.decode(res.bodyBytes));
    return (data['choices'][0]['message']['content'] as String).trim();
  }

  /// Transcribe recorded speech (m4a/wav bytes) with Whisper.
  Future<String> transcribe(List<int> audioBytes, String filename) async {
    final req = http.MultipartRequest(
      'POST',
      Uri.parse('$_base/audio/transcriptions'),
    )
      ..headers['Authorization'] = 'Bearer $_key'
      ..fields['model'] = 'whisper-large-v3-turbo'
      ..files.add(
        http.MultipartFile.fromBytes('file', audioBytes, filename: filename),
      );
    final streamed = await req.send();
    final body = await streamed.stream.bytesToString();
    if (streamed.statusCode != 200) {
      throw Exception('Groq STT failed (${streamed.statusCode}): $body');
    }
    return (jsonDecode(body)['text'] as String).trim();
  }

  /// Synthesize character speech. Returns WAV bytes.
  Future<List<int>> speak(String text, {required bool femaleVoice}) async {
    final res = await http.post(
      Uri.parse('$_base/audio/speech'),
      headers: {
        'Authorization': 'Bearer $_key',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'playai-tts',
        'voice': femaleVoice ? 'Celeste-PlayAI' : 'Atlas-PlayAI',
        'input': text,
        'response_format': 'wav',
      }),
    );
    if (res.statusCode != 200) {
      throw Exception('Groq TTS failed (${res.statusCode}): ${res.body}');
    }
    return res.bodyBytes;
  }
}
