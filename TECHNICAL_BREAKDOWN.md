# Technical Breakdown: AI Usage in Veilspire

Submission document for the AI-Powered Realism Game Jam 2026.
Team: Vincentius Bryan Kwandou (solo). Repo: https://github.com/nayrbryanGaming/veilspire

## 1. Game summary

Veilspire — Echoes of the Sundered Sky is an open world adventure where every
character answers the phone. The player wanders a realm broken by a fallen sky,
meets the five residents who stayed behind, and can ring any of them through a
"veil-link": a live voice or video call. The realism angle is conversational
rather than photographic: characters listen to the player's actual voice,
answer in their own personality, and speak back in real time.

Core loop (5–15 minutes): explore the five regions, find each resident, hold a
call with them, and buy outfits for them with USDC. Character memory persists
across calls within a session, so later calls reference earlier ones.

## 2. AI tools used and share of AI-generated content

| Layer | Tool | Role |
| --- | --- | --- |
| All game and web code | Claude (Claude Code) | Wrote the Flutter game, the Flame world, the Next.js site, and the Solana integration |
| Speech-to-text (runtime) | Groq · whisper-large-v3-turbo | Transcribes the player's microphone audio during calls |
| Character dialogue (runtime) | Groq · llama-3.3-70b-versatile | Generates every character reply in persona, with rolling memory |
| Text-to-speech (runtime) | Groq · PlayAI voices | Speaks each reply aloud; the portrait lip-syncs to the speaking state |
| World rendering | AI-written procedural code | Terrain, biomes, characters, and effects are drawn entirely by code Claude wrote — no image assets, no manual modeling or texturing |

Estimated share of AI-generated visual content: the playable world ships with
zero hand-made image or model assets; every visible element is produced by
AI-written procedural rendering code. Runtime dialogue and voice are 100%
AI-generated per session.

## 3. Asset production pipeline

1. Describe the visual target to Claude (region palette, character silhouette,
   motion).
2. Claude writes deterministic procedural rendering code (Flutter CustomPainter
   and Flame components): pseudo-noise terrain tiling, biome coloring, decor
   scattering, skeletal bobbing, blink and lip-sync cycles.
3. Iterate by prompt until the scene reads correctly; the "asset" is the code
   itself, versioned in git, so the full generation history is auditable in
   the commit log.

## 4. Runtime AI (the core feature)

The call loop, per exchange:

1. Player holds the mic; audio is recorded as AAC.
2. Groq Whisper transcribes it (typically under a second).
3. The transcript joins the character's rolling history and system persona;
   Llama 3.3 70B answers in character (2–4 sentences, phone-call register).
4. Groq TTS renders the reply as WAV; playback drives the animated portrait's
   mouth. If TTS quota runs out, the call degrades gracefully to text.

Character memory: each resident keeps a per-session history keyed by character
id, so a second call opens with a callback to the first conversation.

## 5. Solana integration (bonus scope)

- Wallet login: @solana/wallet-adapter with Solflare and Phantom. The wallet
  address is the player identity — shown in the demo HUD and shop; there is
  no email/password path.
- Purchases: skins are bought with USDC on devnet as SPL token transfers
  (Circle devnet mint 4zMMC9srt5Ri5X14GAgXhaHii3GnPAEERYPJgZJDncDU). The
  transaction creates the treasury's associated token account idempotently,
  transfers the price, and links the confirmed signature to Solana Explorer.
- Devnet by design: the public demo never touches real funds; the mainnet path
  is the same code with a different endpoint.
- Live demo: https://veilspire.vercel.app/shop

## 6. Technical challenges and solutions

- Kotlin incremental compilation failed when the pub cache and project sit on
  different Windows drives; fixed by disabling incremental compilation in
  gradle.properties.
- Real-time feel on a call: kept replies short via prompt constraints and
  max_tokens, and started TTS playback as soon as synthesis returns.
- No art team: chose procedural rendering over generated images so every pixel
  stays reproducible from code, which also makes the AI-usage claim verifiable.

## 7. Appendix: AI asset log

| Asset | Tool | Prompt/spec summary | Date |
| --- | --- | --- | --- |
| World terrain + 5 biomes | Claude Code | Deterministic noise tiling, region palettes | 2026-07-02 |
| Player + 5 NPC figures | Claude Code | Procedural figures, idle bob, name plates | 2026-07-02 |
| Call portrait animation | Claude Code | Breathing, blink cycle, talk-driven mouth | 2026-07-02 |
| Title screen sky shards | Claude Code | Drifting rotating shards, gradient sky | 2026-07-02 |
| Landing page 3D/scroll animation set | Claude Code + skiper-ui | Tilt cards, parallax, marquee, shard field | 2026-07-02 |
| USDC shop flow | Claude Code | SPL transfer + idempotent ATA + explorer link | 2026-07-06 |
