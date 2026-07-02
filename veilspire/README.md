# Veilspire — Echoes of the Sundered Sky

An open world fantasy adventure built with Flutter and Flame. You play the Wanderer, a traveler crossing a realm left broken after the sky shattered. Four residents live across the map, each in their own region, and every one of them can be reached through a veil-link: a live voice or video call powered by the Groq API.

## What works today

- Explorable overworld with five regions: Azure Meadow, Mirror Lake, Ember Hollow, the Sundered Watch ruins, and the Veilspire plateau at the center
- Virtual joystick movement with a camera that follows the player
- Four characters (two women, two men), each with a distinct personality, region, and look
- Walk up to any character and open a voice or video call
- Video call: a live animated portrait that breathes, blinks, and moves its mouth while speaking
- Voice loop: your microphone audio is transcribed by Whisper, answered by Llama 3.3 70B in character, and spoken back through text-to-speech
- Text lane inside the call for quiet play

## Cast

| Name | Title | Region |
| --- | --- | --- |
| Lyra Windveil | Songstress of the Azure Meadow | Azure Meadow |
| Kaelen Dusk | Blade of the Sundered Watch | Northeast ruins |
| Seraphine Ashbloom | Alchemist of the Ember Hollow | Southwest hollow |
| Oren Tidewalker | Keeper of the Mirror Lake | Southeast lake |

## Setup

1. Install Flutter 3.44 or newer.
2. Create `assets/.env` in the project root:

   ```
   GROQ_API_KEY=your_key_here
   ```

3. Run it:

   ```
   flutter pub get
   flutter run
   ```

Android is the primary target. iOS, Windows, macOS, and Linux folders are already generated; audio recording works on all of them through the `record` plugin.

## Build the APK

```
flutter build apk --release
```

Output lands in `build/app/outputs/flutter-apk/app-release.apk`.

## Roadmap

- Quests tied to each character's story
- Combat with elemental reactions between the four elements already assigned to the cast
- More regions past the northern ridge
- iOS TestFlight, then desktop builds
