"use client";

import { useEffect, useRef, useState } from "react";
import { motion } from "framer-motion";
import Link from "next/link";
import { Reveal } from "@/components/motion";

/* eslint-disable @typescript-eslint/no-explicit-any */

const LINES = [
  "You found me. Most travelers walk right past the meadow.",
  "The spire cracked, the sky fell, and I woke up made of oak. Strange week.",
  "Ring me any time. Wood carries sound better than you would think.",
  "Ask Lyra about the wind. Ask me about staying still for a hundred years.",
];

export default function DemoPage() {
  const viewerRef = useRef<any>(null);
  const [loaded, setLoaded] = useState(false);
  const [progress, setProgress] = useState(0);
  const [line, setLine] = useState<string | null>(null);
  const [calling, setCalling] = useState(false);

  useEffect(() => {
    import("@google/model-viewer");
  }, []);

  useEffect(() => {
    const v = viewerRef.current;
    if (!v) return;
    const onProgress = (e: any) =>
      setProgress(Math.round(e.detail.totalProgress * 100));
    const onLoad = () => {
      setLoaded(true);
      const anims = v.availableAnimations;
      if (anims && anims.length) {
        v.animationName = anims[0];
        v.play();
      }
    };
    v.addEventListener("progress", onProgress);
    v.addEventListener("load", onLoad);
    return () => {
      v.removeEventListener("progress", onProgress);
      v.removeEventListener("load", onLoad);
    };
  }, []);

  function talk() {
    setCalling(true);
    setLine(LINES[Math.floor(Math.random() * LINES.length)]);
  }

  return (
    <main className="min-h-screen bg-[#070A14] px-6 py-14 text-white">
      <div className="mx-auto flex max-w-6xl flex-col items-center gap-12 lg:flex-row lg:items-start lg:justify-between">
        {/* Copy */}
        <div className="max-w-xl">
          <Reveal>
            <p className="text-xs tracking-[0.35em] text-white/50">
              LIVE BUILD PREVIEW · IN BROWSER
            </p>
            <h1 className="mt-3 text-4xl font-bold sm:text-5xl">
              The Marionette of Azure Meadow
            </h1>
            <p className="mt-5 text-white/60">
              This is the fifth resident of the realm, rendered here exactly as
              she moves on a phone. A carved girl the Veilspire woke when the
              sky broke, still learning what a heartbeat is for. Drag inside
              the screen to orbit the camera, pinch or scroll to zoom, and
              press the call button to hear how she talks.
            </p>
            <p className="mt-4 text-white/60">
              The frame around her mirrors the Android build: joystick on the
              left, call controls on the right, region name up top. What you
              see moving is a fully rigged skeleton with its own idle motion,
              streamed as a 15 MB asset.
            </p>
            <div className="mt-8 flex gap-4 text-sm">
              <Link
                href="/"
                className="rounded-full border border-white/25 px-6 py-3 text-white/80"
              >
                Back home
              </Link>
              <a
                href="https://github.com/nayrbryanGaming/veilspire/releases"
                className="rounded-full bg-[#7C5CFF] px-6 py-3 font-semibold"
              >
                Get the APK
              </a>
            </div>
          </Reveal>
        </div>

        {/* Phone frame */}
        <Reveal delay={0.15}>
          <div className="relative h-[680px] w-[330px] rounded-[42px] border border-white/20 bg-[#0B0F1E] p-3 shadow-[0_0_80px_rgba(124,92,255,0.25)]">
            {/* notch */}
            <div className="absolute left-1/2 top-3 z-20 h-6 w-28 -translate-x-1/2 rounded-full bg-black" />
            <div className="relative h-full w-full overflow-hidden rounded-[32px] bg-gradient-to-b from-[#12203A] via-[#1A1440] to-[#0A2818]">
              {/* 3D viewer */}
              {/* @ts-expect-error custom element */}
              <model-viewer
                ref={viewerRef}
                src="/models/marionette.glb"
                camera-controls
                autoplay
                interaction-prompt="none"
                shadow-intensity="1"
                exposure="1.1"
                camera-orbit="0deg 82deg 2.4m"
                style={{ width: "100%", height: "100%", background: "transparent" }}
              />

              {/* loading */}
              {!loaded && (
                <div className="absolute inset-0 z-10 flex flex-col items-center justify-center gap-3 bg-[#0B0F1E]/80">
                  <div className="h-1.5 w-40 overflow-hidden rounded-full bg-white/10">
                    <div
                      className="h-full bg-[#7C5CFF] transition-all"
                      style={{ width: `${progress}%` }}
                    />
                  </div>
                  <p className="text-xs text-white/50">
                    Waking the Marionette · {progress}%
                  </p>
                </div>
              )}

              {/* HUD: region label */}
              <div className="pointer-events-none absolute left-0 right-0 top-10 z-10 flex justify-center">
                <span className="rounded-full bg-black/40 px-4 py-1.5 text-[10px] tracking-[0.3em] text-white/70 backdrop-blur">
                  AZURE MEADOW
                </span>
              </div>

              {/* HUD: joystick */}
              <div className="pointer-events-none absolute bottom-8 left-6 z-10 flex h-24 w-24 items-center justify-center rounded-full border border-white/20 bg-white/5 backdrop-blur">
                <motion.div
                  animate={{ x: [0, 8, 0, -8, 0], y: [0, -6, 0, 6, 0] }}
                  transition={{ repeat: Infinity, duration: 4 }}
                  className="h-10 w-10 rounded-full bg-white/25"
                />
              </div>

              {/* HUD: call buttons */}
              <div className="absolute bottom-8 right-6 z-10 flex flex-col gap-3">
                <motion.button
                  whileTap={{ scale: 0.92 }}
                  onClick={talk}
                  className="flex h-14 w-14 items-center justify-center rounded-full bg-[#35C4B5] text-xs font-bold shadow-lg"
                >
                  CALL
                </motion.button>
                <motion.button
                  whileTap={{ scale: 0.92 }}
                  onClick={() => {
                    setCalling(false);
                    setLine(null);
                  }}
                  className="flex h-14 w-14 items-center justify-center rounded-full border border-white/25 bg-black/40 text-[10px] text-white/70 backdrop-blur"
                >
                  END
                </motion.button>
              </div>

              {/* dialogue */}
              {calling && line && (
                <motion.div
                  key={line}
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  className="absolute bottom-36 left-6 right-6 z-10 rounded-2xl border border-white/15 bg-black/60 p-4 backdrop-blur"
                >
                  <p className="text-[10px] tracking-[0.25em] text-[#35C4B5]">
                    THE MARIONETTE · ON CALL
                  </p>
                  <p className="mt-2 text-sm text-white/85">{line}</p>
                  <button
                    onClick={talk}
                    className="mt-3 text-xs text-[#9E7BFF] underline underline-offset-4"
                  >
                    Say something else
                  </button>
                </motion.div>
              )}
            </div>
          </div>
        </Reveal>
      </div>

      <Reveal delay={0.3}>
        <p className="mx-auto mt-14 max-w-2xl text-center text-xs text-white/35">
          In the installed game these replies come from a live language model
          speaking aloud through Groq. The browser preview keeps a few of her
          lines on hand instead, so the scene stays light enough to load
          anywhere.
        </p>
      </Reveal>
    </main>
  );
}
