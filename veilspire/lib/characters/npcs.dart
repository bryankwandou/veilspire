import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Archetype-driven background population, per the production plan:
/// a small set of reusable archetypes with name patterns and barked
/// lines reaches a populated world without hand-writing every villager.
class NpcArchetype {
  final String role;
  final Color outfit;
  final List<String> barks;

  const NpcArchetype(this.role, this.outfit, this.barks);
}

const List<NpcArchetype> kArchetypes = [
  NpcArchetype('Terrace Farmer', Color(0xFF6B8E4E), [
    'The crops grow fast since the shard-dust settled in. Too fast, some say.',
    'Third row went glassy this week. Veyra ought to see it.',
    'Rain barely matters anymore. The dust does the feeding.',
  ]),
  NpcArchetype('Village Elder', Color(0xFF8A7B6B), [
    'The sundial in the square has been wrong for two hundred years. We keep it anyway.',
    'The Council can argue about the Blight all season. Someone still has to farm.',
    'You walk like someone the sky is watching, traveler.',
  ]),
  NpcArchetype('Dockhand', Color(0xFF4E6B8E), [
    'Nobody fishes after dusk. Ask Pell why, and he will not tell you.',
    'The lake gives back a second moon some nights. Do not stare at it.',
    'Stillwater catch is good this week. The reflection is not.',
  ]),
  NpcArchetype('Forge Apprentice', Color(0xFF8E5B4E), [
    'Kaelen holds the forge together these days, whatever Maro says.',
    'The communal fire has not gone out since the wildfire. It will not, either.',
    'Cinder Flats training again tomorrow. My arms already ache.',
  ]),
  NpcArchetype('Traveling Merchant', Color(0xFFB09A55), [
    'Oren sold me this map. Half the roads on it do not exist.',
    'Shard-glass buttons, two for a copper. They glow, mostly.',
    'Every road in Aerthal bends toward the spire eventually. Notice that?',
  ]),
  NpcArchetype('Child', Color(0xFFC96F6F), [
    'The Toll Twins made me answer a riddle to cross the bridge!',
    'I saw a shard fall in the meadow last night. It hummed.',
    'Old Tessa knows everything about everyone. Everything!',
  ]),
  NpcArchetype('Wandering Pilgrim', Color(0xFF7B6B8E), [
    'They say the spire grows a little taller every year. I measure it in prayers.',
    'The Sundering was not an ending. Endings finish.',
    'I walked from Ember Hollow. The ground there still remembers the fire.',
  ]),
  NpcArchetype('Guard', Color(0xFF5B6472), [
    'Keep to the paths after shard-fall. The dust pools in the hollows.',
    'Hallowlight has not seen trouble in years. I plan to keep the streak.',
    'The Watch failed once. We do not talk about it near Sundered ground.',
  ]),
  NpcArchetype('Scholar', Color(0xFF6E7B8E), [
    'The Observatory dome shattered outward. Outward. Think about that.',
    'Seraphine guards the Archive like it owes her an answer. Perhaps it does.',
    'Someone keeps leaving notes in the old margins. Nobody admits to it.',
  ]),
];

const List<String> _nameA = [
  'Bram', 'Tilda', 'Joss', 'Merrin', 'Halla', 'Piet', 'Sable', 'Wren',
  'Corvin', 'Ansa', 'Doro', 'Fenn', 'Isolde', 'Marek', 'Nell', 'Otho',
];
const List<String> _nameB = [
  'of the Terraces', 'Half-Copper', 'the Younger', 'of Hallowlight',
  'Two-Ropes', 'the Quiet', 'of Stillwater', 'Longwalk',
  'the Patient', 'of Forgehearth', 'Brightneedle', 'the Elder',
];

class FlavorNpc {
  final String name;
  final NpcArchetype archetype;
  final Offset position;
  final String bark;

  const FlavorNpc(this.name, this.archetype, this.position, this.bark);
}

/// Deterministic population: same villagers in the same places every run.
List<FlavorNpc> buildPopulation() {
  final rng = math.Random(7);
  // Region anchors: meadow/village, lake docks, ember hollow, watch ruins.
  const anchors = [
    Offset(950, 850), Offset(1250, 1050), Offset(700, 1200), // Azure Meadow
    Offset(2250, 2050), Offset(2500, 2350), // Mirror Lake shore
    Offset(850, 2150), Offset(1050, 2400), // Ember Hollow
    Offset(2150, 750), Offset(2400, 900), // Sundered Watch
    Offset(1600, 1400), // spire approach
  ];
  final npcs = <FlavorNpc>[];
  for (int i = 0; i < 18; i++) {
    final anchor = anchors[i % anchors.length];
    final arch = kArchetypes[rng.nextInt(kArchetypes.length)];
    final pos = Offset(
      anchor.dx + rng.nextDouble() * 260 - 130,
      anchor.dy + rng.nextDouble() * 260 - 130,
    );
    final name =
        '${_nameA[rng.nextInt(_nameA.length)]} ${_nameB[rng.nextInt(_nameB.length)]}';
    npcs.add(FlavorNpc(
        name, arch, pos, arch.barks[rng.nextInt(arch.barks.length)]));
  }
  return npcs;
}
