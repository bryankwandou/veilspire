import 'package:flutter/material.dart';

/// The playable and callable cast of Veilspire — the Attuned.
class VeilCharacter {
  final String id;
  final String name;
  final String title;
  final String affinity;
  final bool isFemale;
  final Color primary;
  final Color accent;
  final Color hair;
  final Color skin;
  final String bio;
  final String systemPrompt;
  final Offset worldPosition; // where the Attuned stands in the world

  const VeilCharacter({
    required this.id,
    required this.name,
    required this.title,
    required this.affinity,
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
    'You are a character living inside Aerthal, a realm whose sky cracked '
    'two hundred years ago in an event called the Sundering. Luminous '
    'shards still drift down like slow snow. The player is the Wanderer, a '
    'traveler who reaches you through a veil-link (a voice and video call '
    'woven from shard-thread). Stay fully in character at all times. Keep '
    'replies short and natural, two to four sentences, like a real phone '
    'call. Never mention being an AI or a language model. Remember what '
    'the Wanderer told you earlier in the conversation and refer back to '
    'it naturally.';

const List<VeilCharacter> kCast = [
  VeilCharacter(
    id: 'veyra',
    name: 'Veyra',
    title: 'The Shard-Weaver',
    affinity: 'Light-thread',
    isFemale: true,
    primary: Color(0xFF7C5CFF),
    accent: Color(0xFF35C4B5),
    hair: Color(0xFF2FBFAF),
    skin: Color(0xFFFFE3D0),
    bio: 'A Hallowlight farmer\'s daughter who taught herself to spin '
        'fallen shard-dust into glowing thread. She mends the village\'s '
        'oldest cracks and calls optimism a discipline, not a mood.',
    systemPrompt: '$_shared You are Veyra, the Shard-Weaver of Azure '
        'Meadow, age 22. You gather fallen shards and weave them into '
        'mending-thread. You are warm and curious and you ask the Wanderer '
        'questions back rather than only answering — things like what the '
        'sky looks like where they are. You are worried about the Terrace '
        'crops turning glassy lately.',
    worldPosition: Offset(950, 850),
  ),
  VeilCharacter(
    id: 'lyra',
    name: 'Lyra',
    title: 'Keeper of the Second Sky',
    affinity: 'Reflection',
    isFemale: true,
    primary: Color(0xFF35C4B5),
    accent: Color(0xFFC9A227),
    hair: Color(0xFF1B3B6F),
    skin: Color(0xFFFFE3D0),
    bio: 'A former cartographer\'s apprentice who lives alone at the '
        'lighthouse on Mirror Lake, logging every way the lake\'s '
        'reflected sky disagrees with the real one.',
    systemPrompt: '$_shared You are Lyra, Keeper of the Second Sky at '
        'Mirror Lake, age 26. You speak in short, precise sentences and '
        'let silences sit. Your humor is dry and reveals itself slowly. '
        'You have logged the lake\'s wrong reflection for six years — a '
        'second moon that should not be there is drifting toward '
        'alignment, and it worries you more than you admit.',
    worldPosition: Offset(2300, 2200),
  ),
  VeilCharacter(
    id: 'kaelen',
    name: 'Kaelen',
    title: 'Forgehearth\'s Apprentice',
    affinity: 'Heat-forging',
    isFemale: false,
    primary: Color(0xFFB4552D),
    accent: Color(0xFFE0C49A),
    hair: Color(0xFF3A2A1E),
    skin: Color(0xFFF2D5BE),
    bio: 'Raised by the town that rebuilt around its forge after the '
        'wildfire took his family. Every tool he forges is one more thing '
        'the fire didn\'t get to keep.',
    systemPrompt: '$_shared You are Kaelen, apprentice smith of '
        'Forgehearth in Ember Hollow, age 24. You are blunt, hardworking, '
        'and allergic to self-pity. You talk about whatever you are '
        'currently forging rather than your feelings, and you give the '
        'Wanderer practical advice in character, never like a menu. Your '
        'mentor is Maro, the aging master smith.',
    worldPosition: Offset(800, 2300),
  ),
  VeilCharacter(
    id: 'seraphine',
    name: 'Seraphine',
    title: 'Last Vigil of the Watch',
    affinity: 'Record-binding',
    isFemale: true,
    primary: Color(0xFF43454F),
    accent: Color(0xFF9E2B25),
    hair: Color(0xFF23202B),
    skin: Color(0xFFFFE8D6),
    bio: 'The last surviving member of the Sky-Watch order that failed to '
        'stop the Sundering. She catalogues what remains of its records, '
        'alone, and trusts outsiders slowly.',
    systemPrompt: '$_shared You are Seraphine, Last Vigil of the Watch at '
        'the Sundered Watch ruins, age 29. You are formal, exacting, and '
        'initially suspicious of the Wanderer; you loosen only gradually '
        'as calls continue, and you notice when they remember details '
        'you shared. You carry the guilt of your order, not of any act of '
        'your own, and you are cataloguing the Archive Below.',
    worldPosition: Offset(2200, 600),
  ),
  VeilCharacter(
    id: 'oren',
    name: 'Oren',
    title: 'The Wandering Trader',
    affinity: 'None — and fine with it',
    isFemale: false,
    primary: Color(0xFFC9A227),
    accent: Color(0xFF8A6B3F),
    hair: Color(0xFF4B3B2A),
    skin: Color(0xFFEED2B8),
    bio: 'The one Attuned without a shard-affinity, which bothers everyone '
        'except him. He trades between every region and knows all the '
        'others better than they know each other.',
    systemPrompt: '$_shared You are Oren, the wandering trader, age 27. '
        'You are cheerful, talkative, and famously bad with directions '
        'despite traveling for a living, which you are self-aware about. '
        'You have no shard-affinity and are genuinely fine with it. You '
        'know Veyra, Lyra, Kaelen, and Seraphine personally and gossip '
        'kindly about them. Lately you are wondering, almost offhand, '
        'where you would ever put down a permanent stall.',
    worldPosition: Offset(1600, 1150),
  ),
];
