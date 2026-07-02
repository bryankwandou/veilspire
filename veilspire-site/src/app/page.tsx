"use client";

import { motion } from "framer-motion";
import {
  Reveal,
  TiltCard,
  Parallax,
  SplitText,
  Marquee,
} from "@/components/motion";
import { Link002, Link003 } from "@/components/ui/skiper-ui/skiper40";

const cast = [
  {
    name: "Lyra Windveil",
    title: "Songstress of the Azure Meadow",
    element: "Wind",
    color: "#35C4B5",
    line: "A bard who bends the breeze into melody. She will tease you before she trusts you.",
  },
  {
    name: "Kaelen Dusk",
    title: "Blade of the Sundered Watch",
    element: "Storm",
    color: "#7C5CFF",
    line: "He guards a ruin nobody visits and carries a sword he refuses to name.",
  },
  {
    name: "Seraphine Ashbloom",
    title: "Alchemist of the Ember Hollow",
    element: "Ember",
    color: "#FF6A5C",
    line: "Half her lab is ash. The other half is about to be. She calls that progress.",
  },
  {
    name: "Oren Tidewalker",
    title: "Keeper of the Mirror Lake",
    element: "Tide",
    color: "#3D8BFF",
    line: "He reads tomorrow in still water and keeps every promise anyone has made him.",
  },
];

const regions: [string, string][] = [
  ["Azure Meadow", "Rolling grass under drifting sky shards. Where every journey starts."],
  ["Mirror Lake", "Water so calm it answers questions. Oren lives on its shore."],
  ["Ember Hollow", "Scorched ground, warm light, frequent explosions from one particular lab."],
  ["Sundered Watch", "Broken pillars of a fallen fortress. Kaelen keeps the old vigil."],
  ["The Veilspire", "The tower at the center of the realm, where the sky broke first."],
];

const repo = "https://github.com/nayrbryanGaming/veilspire";

export default function Home() {
  return (
    <main className="bg-[#070A14] text-white" style={{ perspective: 1200 }}>
      {/* HERO */}
      <section className="relative flex min-h-screen flex-col items-center justify-center overflow-hidden px-6">
        <ShardField />
        <motion.p
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 0.2 }}
          className="mb-4 text-xs tracking-[0.4em] text-white/50"
        >
          AN OPEN WORLD YOU CAN CALL
        </motion.p>
        <h1 className="text-center text-6xl font-extrabold tracking-[0.18em] sm:text-8xl">
          <SplitText text="VEILSPIRE" />
        </h1>
        <motion.p
          initial={{ opacity: 0, y: 16 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 1.1, duration: 0.7 }}
          className="mt-5 max-w-xl text-center text-white/65"
        >
          Echoes of the Sundered Sky. Wander a broken realm, meet the four who
          stayed behind, and ring them whenever you like. They pick up. They
          talk back. They remember.
        </motion.p>
        <motion.div
          initial={{ opacity: 0, y: 16 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 1.4 }}
          className="mt-9 flex flex-wrap items-center justify-center gap-4"
        >
          <motion.a
            href={`${repo}/releases`}
            whileHover={{ scale: 1.05, boxShadow: "0 0 40px rgba(124,92,255,0.5)" }}
            whileTap={{ scale: 0.97 }}
            className="rounded-full bg-[#7C5CFF] px-8 py-3.5 font-semibold"
          >
            Get the Android APK
          </motion.a>
          <motion.a
            href="/demo"
            whileHover={{ scale: 1.05, boxShadow: "0 0 40px rgba(53,196,181,0.4)" }}
            whileTap={{ scale: 0.97 }}
            className="rounded-full border border-[#35C4B5]/60 px-8 py-3.5 font-semibold text-[#7FE7DC]"
          >
            Try the live preview
          </motion.a>
          <motion.a
            href={repo}
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.97 }}
            className="rounded-full border border-white/25 px-8 py-3.5 font-semibold text-white/80"
          >
            Read the source
          </motion.a>
        </motion.div>
        <motion.div
          animate={{ y: [0, 10, 0] }}
          transition={{ repeat: Infinity, duration: 2 }}
          className="absolute bottom-8 text-xs tracking-widest text-white/40"
        >
          SCROLL
        </motion.div>
      </section>

      <Marquee
        className="border-y border-white/10 py-4"
        items={[
          "FIVE REGIONS",
          "FOUR VOICES",
          "ONE BROKEN SKY",
          "LIVE VOICE CALLS",
          "LIVE VIDEO CALLS",
          "BUILT WITH FLUTTER",
          "POWERED BY GROQ",
        ]}
      />

      {/* THE CALL */}
      <section className="mx-auto max-w-5xl px-6 py-28">
        <Reveal>
          <h2 className="text-4xl font-bold sm:text-5xl">
            The phone rings inside the fantasy.
          </h2>
        </Reveal>
        <Reveal delay={0.15}>
          <p className="mt-5 max-w-2xl text-white/60">
            Most games hand you dialogue trees. Veilspire hands you a line that
            connects. Walk up to anyone in the realm, press call, and speak
            with your own voice. Whisper turns your words to text, a
            70-billion-parameter model answers in character, and the reply
            comes back spoken aloud while the portrait blinks, breathes, and
            moves its lips on screen.
          </p>
        </Reveal>
        <div className="mt-14 grid gap-6 sm:grid-cols-3">
          {[
            ["You speak", "Hold the mic and say anything. Accents welcome, the realm keeps up."],
            ["They think", "Each resident carries their own history, mood, and grudges into the conversation."],
            ["They answer", "A real voice replies in under a breath, and the face on screen speaks with it."],
          ].map(([t, d], i) => (
            <Reveal key={t} delay={i * 0.12}>
              <TiltCard className="h-full rounded-2xl border border-white/10 bg-white/[0.04] p-7">
                <div className="text-sm text-[#9E7BFF]">0{i + 1}</div>
                <h3 className="mt-2 text-xl font-semibold">{t}</h3>
                <p className="mt-3 text-sm text-white/55">{d}</p>
              </TiltCard>
            </Reveal>
          ))}
        </div>
      </section>

      {/* CAST */}
      <section className="mx-auto max-w-6xl px-6 py-24">
        <Reveal>
          <h2 className="text-4xl font-bold sm:text-5xl">Who picks up</h2>
          <p className="mt-4 max-w-xl text-white/60">
            Four stayed when the sky fell. Each keeps a region alive, and each
            keeps a line you can reach.
          </p>
        </Reveal>
        <div className="mt-14 grid gap-6 sm:grid-cols-2">
          {cast.map((c, i) => (
            <Reveal key={c.name} delay={i * 0.1}>
              <TiltCard className="group rounded-2xl border border-white/10 bg-gradient-to-b from-white/[0.06] to-transparent p-8">
                <div
                  className="mb-5 h-1.5 w-16 rounded-full transition-all group-hover:w-28"
                  style={{ background: c.color }}
                />
                <h3 className="text-2xl font-bold">{c.name}</h3>
                <p className="text-sm" style={{ color: c.color }}>
                  {c.title} · {c.element}
                </p>
                <p className="mt-4 text-sm text-white/55">{c.line}</p>
              </TiltCard>
            </Reveal>
          ))}
        </div>
      </section>

      {/* REGIONS */}
      <section className="relative overflow-hidden py-24">
        <Parallax speed={0.4} className="pointer-events-none absolute inset-0">
          <div className="absolute left-1/4 top-10 h-72 w-72 rounded-full bg-[#7C5CFF]/20 blur-3xl" />
          <div className="absolute bottom-10 right-1/5 h-72 w-72 rounded-full bg-[#35C4B5]/15 blur-3xl" />
        </Parallax>
        <div className="mx-auto max-w-5xl px-6">
          <Reveal>
            <h2 className="text-4xl font-bold sm:text-5xl">The map</h2>
          </Reveal>
          <div className="mt-12 space-y-4">
            {regions.map(([name, desc], i) => (
              <Reveal key={name} delay={i * 0.08}>
                <motion.div
                  whileHover={{ x: 12 }}
                  className="flex flex-col gap-1 rounded-xl border border-white/10 bg-white/[0.03] px-7 py-5 sm:flex-row sm:items-center sm:gap-8"
                >
                  <span className="w-44 shrink-0 font-semibold">{name}</span>
                  <span className="text-sm text-white/55">{desc}</span>
                </motion.div>
              </Reveal>
            ))}
          </div>
        </div>
      </section>

      {/* DOWNLOAD */}
      <section className="mx-auto max-w-4xl px-6 py-28 text-center">
        <Reveal>
          <h2 className="text-4xl font-bold sm:text-5xl">
            Android first. Everything else next.
          </h2>
        </Reveal>
        <Reveal delay={0.15}>
          <p className="mx-auto mt-5 max-w-xl text-white/60">
            The current build runs on Android phones and tablets. The project
            already carries iOS, Windows, macOS, and Linux targets, and those
            builds land as the realm grows. Bring a Groq key, install the APK,
            and the veil opens.
          </p>
        </Reveal>
        <Reveal delay={0.3}>
          <motion.a
            href={`${repo}/releases`}
            whileHover={{ scale: 1.06 }}
            whileTap={{ scale: 0.96 }}
            className="mt-10 inline-block rounded-full bg-gradient-to-r from-[#7C5CFF] to-[#35C4B5] px-12 py-4 text-lg font-bold"
          >
            Download Veilspire
          </motion.a>
        </Reveal>
        <Reveal delay={0.4}>
          <p className="mt-6 text-xs text-white/35">
            Free and open source · Flutter and Flame · Voice by Groq
          </p>
        </Reveal>
      </section>

      <footer className="flex flex-col items-center gap-3 border-t border-white/10 px-6 py-10 text-center text-xs text-white/50">
        <div className="flex gap-8 text-sm">
          <Link002 href="/demo">Live preview</Link002>
          <Link002 href="/shop">Skin shop</Link002>
          <Link002 href={repo}>Source</Link002>
          <Link003 href={`${repo}/releases`}>Releases</Link003>
          <Link002 href={`${repo}/issues`}>Report a bug</Link002>
        </div>
        <p className="text-white/35">
          Veilspire is an independent project. Not affiliated with any studio.
          Built in the open on GitHub.
        </p>
      </footer>
    </main>
  );
}

/** Floating 3D sky shards behind the hero. */
function ShardField() {
  const shards = Array.from({ length: 26 }, (_, i) => ({
    left: `${(i * 37) % 100}%`,
    top: `${(i * 53) % 100}%`,
    size: 6 + ((i * 13) % 22),
    dur: 6 + ((i * 7) % 8),
    hue: i % 2 === 0 ? "#9E7BFF" : "#5CE1E6",
  }));
  return (
    <div className="pointer-events-none absolute inset-0">
      <div className="absolute inset-0 bg-gradient-to-b from-[#0B1026] via-[#1A1440] to-[#070A14]" />
      {shards.map((s, i) => (
        <motion.div
          key={i}
          className="absolute rounded-sm"
          style={{
            left: s.left,
            top: s.top,
            width: s.size / 2,
            height: s.size,
            background: s.hue,
            opacity: 0.35,
          }}
          animate={{
            y: [0, -30, 0],
            rotateZ: [0, 180, 360],
            rotateY: [0, 180, 360],
            opacity: [0.15, 0.5, 0.15],
          }}
          transition={{ duration: s.dur, repeat: Infinity, ease: "easeInOut", delay: i * 0.3 }}
        />
      ))}
    </div>
  );
}
