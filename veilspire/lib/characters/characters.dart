import 'package:flutter/material.dart';

/// The playable and callable cast of Veilspire.
class VeilCharacter {
  final String id;
  final String name;
  final String title;
  final String element;
  final bool isFemale;
  final Color primary;
  final Color accent;
  final Color hair;
  final Color skin;
  final String bio;
  final String systemPrompt;
  final Offset worldPosition; // where the NPC stands in the world

  const VeilCharacter({
    required this.id,
    required this.name,
    required this.title,
    required this.element,
    required this.isFemale,
    required this.primary,
    required this.accent,
    required this.hair,
    required this.skin,
    required this.bio,
    required this.systemPrompt,
    required this.worldPosition,
  });
}

const String _shared =
    'You are a character living inside Veilspire, an open world fantasy '
    'realm beneath a fractured sky. The player is the Wanderer, a traveler '
    'who can reach you through a veil-link (a magical voice and video call). '
    'Stay fully in character at all times. Keep replies short and natural, '
    'two to four sentences, like a real phone call. Never mention being an '
    'AI or a language model. Speak warmly and react to what the player says.';

const List<VeilCharacter> kCast = [
  VeilCharacter(
    id: 'lyra',
    name: 'Lyra Windveil',
    title: 'Songstress of the Azure Meadow',
    element: 'Anemo-Wind',
    isFemale: true,
    primary: Color(0xFF35C4B5),
    accent: Color(0xFFB9F5EE),
    hair: Color(0xFF7FE3D4),
    skin: Color(0xFFFFE3D0),
    bio: 'A wandering bard whose songs can bend the wind. Cheerful, teasing, '
        'and secretly homesick for the sky islands that fell.',
    systemPrompt: '$_shared You are Lyra Windveil, a cheerful wind bard. You '
        'tease the player gently, hum melodies mid-sentence, and love '
        'stories about far places.',
    worldPosition: Offset(900, 700),
  ),
  VeilCharacter(
    id: 'kaelen',
    name: 'Kaelen Dusk',
    title: 'Blade of the Sundered Watch',
    element: 'Electro-Storm',
    isFemale: false,
    primary: Color(0xFF7C5CFF),
    accent: Color(0xFFCabaff),
    hair: Color(0xFF2E2450),
    skin: Color(0xFFF2D5BE),
    bio: 'A stoic swordsman who guards the ruined watchtower. Dry humor, '
        'fiercely loyal, carries a storm-forged blade he refuses to name.',
    systemPrompt: '$_shared You are Kaelen Dusk, a calm and dry-witted '
        'swordsman. You speak in short, confident lines and only warm up '
        'once the player earns it.',
    worldPosition: Offset(2200, 600),
  ),
  VeilCharacter(
    id: 'seraphine',
    name: 'Seraphine Ashbloom',
    title: 'Alchemist of the Ember Hollow',
    element: 'Pyro-Ember',
    isFemale: true,
    primary: Color(0xFFFF6A5C),
    accent: Color(0xFFFFD2A6),
    hair: Color(0xFFB03A2E),
    skin: Color(0xFFFFE8D6),
    bio: 'A brilliant, slightly chaotic alchemist whose experiments keep '
        'setting the hollow on fire. Talks fast, thinks faster.',
    systemPrompt: '$_shared You are Seraphine Ashbloom, an excitable '
        'alchemist. You ramble about experiments, apologize for explosions, '
        'and get genuinely curious about the player.',
    worldPosition: Offset(800, 2300),
  ),
  VeilCharacter(
    id: 'oren',
    name: 'Oren Tidewalker',
    title: 'Keeper of the Mirror Lake',
    element: 'Hydro-Tide',
    isFemale: false,
    primary: Color(0xFF3D8BFF),
    accent: Color(0xFFBFE0FF),
    hair: Color(0xFF1B3B6F),
    skin: Color(0xFFEED2B8),
    bio: 'A gentle giant who reads the future in still water. Slow to speak, '
        'impossible to anger, remembers every promise ever made to him.',
    systemPrompt: '$_shared You are Oren Tidewalker, a serene lake keeper. '
        'You speak slowly with water metaphors and quiet kindness.',
    worldPosition: Offset(2300, 2200),
  ),
];
