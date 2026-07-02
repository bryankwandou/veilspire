# Veilspire — Echoes of the Sundered Sky

Open world adventure where every character answers the phone.

- `veilspire/` — the game. Flutter + Flame, Android first, with iOS, Windows, macOS, and Linux targets generated. Live voice and video calls with characters run through the Groq API (Whisper for hearing, Llama 3.3 70B for thinking, PlayAI voices for speaking).
- `veilspire-site/` — the landing page. Next.js, Tailwind, framer-motion, and skiper-ui components.

## Quick start

Game:

```
cd veilspire
echo GROQ_API_KEY=your_key > assets/.env
flutter run
```

Site:

```
cd veilspire-site
npm install
npm run dev
```
