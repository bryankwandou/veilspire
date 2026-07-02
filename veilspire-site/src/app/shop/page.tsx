"use client";

import dynamic from "next/dynamic";
import { motion } from "framer-motion";
import {
  LAMPORTS_PER_SOL,
  PublicKey,
  SystemProgram,
  Transaction,
} from "@solana/web3.js";
import { useConnection, useWallet } from "@solana/wallet-adapter-react";
import { useEffect, useState } from "react";

import { SolanaProviders } from "./providers";
import { Reveal, TiltCard } from "@/components/motion";

const WalletMultiButton = dynamic(
  () =>
    import("@solana/wallet-adapter-react-ui").then(
      (m) => m.WalletMultiButton,
    ),
  { ssr: false },
);

// Demo treasury on devnet. Purchases here move devnet SOL only.
const TREASURY = new PublicKey(
  "9WzDXwBbmkg8ZTbNMqUxvQRAyrZzDsGYdLVL9zYtAWWM",
);

const skins = [
  { id: "lyra-gale", name: "Lyra · Gale Song", price: 0.05, color: "#35C4B5" },
  { id: "kaelen-void", name: "Kaelen · Voidsteel", price: 0.08, color: "#7C5CFF" },
  { id: "sera-flare", name: "Seraphine · Flarebloom", price: 0.05, color: "#FF6A5C" },
  { id: "oren-deep", name: "Oren · Deepcurrent", price: 0.08, color: "#3D8BFF" },
];

function ShopInner() {
  const { connection } = useConnection();
  const { publicKey, sendTransaction, connected } = useWallet();
  const [balance, setBalance] = useState<number | null>(null);
  const [busy, setBusy] = useState<string | null>(null);
  const [owned, setOwned] = useState<string[]>([]);
  const [status, setStatus] = useState<string | null>(null);

  useEffect(() => {
    if (!publicKey) return setBalance(null);
    connection
      .getBalance(publicKey)
      .then((v) => setBalance(v / LAMPORTS_PER_SOL))
      .catch(() => setBalance(null));
  }, [publicKey, connection, owned]);

  async function buy(skin: (typeof skins)[number]) {
    if (!publicKey) return;
    setBusy(skin.id);
    setStatus(null);
    try {
      const tx = new Transaction().add(
        SystemProgram.transfer({
          fromPubkey: publicKey,
          toPubkey: TREASURY,
          lamports: Math.round(skin.price * LAMPORTS_PER_SOL),
        }),
      );
      const sig = await sendTransaction(tx, connection);
      await connection.confirmTransaction(sig, "confirmed");
      setOwned((o) => [...o, skin.id]);
      setStatus(`Purchase confirmed. Signature ${sig.slice(0, 16)}…`);
    } catch (e) {
      setStatus(e instanceof Error ? e.message : "Transaction failed.");
    } finally {
      setBusy(null);
    }
  }

  return (
    <main className="min-h-screen bg-[#070A14] px-6 py-16 text-white">
      <div className="mx-auto max-w-5xl">
        <Reveal>
          <p className="text-xs tracking-[0.35em] text-white/50">
            VEILSPIRE OUTFITTER · DEVNET TRIAL
          </p>
          <h1 className="mt-3 text-4xl font-bold sm:text-5xl">
            Skins, paid straight from your wallet.
          </h1>
          <p className="mt-4 max-w-2xl text-white/60">
            Connect Solflare or Phantom and pick up a look for any of the
            four. This demo runs on Solana devnet, so grab free devnet SOL
            from a faucet and try the whole flow without spending anything
            real. The mainnet path uses the same code with a different
            endpoint.
          </p>
        </Reveal>

        <Reveal delay={0.15}>
          <div className="mt-8 flex flex-wrap items-center gap-4">
            <WalletMultiButton />
            {connected && balance !== null && (
              <span className="rounded-full border border-white/15 px-4 py-2 text-sm text-white/70">
                Balance: {balance.toFixed(3)} SOL
              </span>
            )}
          </div>
        </Reveal>

        {status && (
          <p className="mt-4 text-sm text-[#9E7BFF]">{status}</p>
        )}

        <div className="mt-12 grid gap-6 sm:grid-cols-2">
          {skins.map((s, i) => (
            <Reveal key={s.id} delay={i * 0.08}>
              <TiltCard className="rounded-2xl border border-white/10 bg-white/[0.04] p-7">
                <div
                  className="mb-4 h-24 rounded-xl"
                  style={{
                    background: `linear-gradient(135deg, ${s.color}44, ${s.color}11)`,
                    border: `1px solid ${s.color}66`,
                  }}
                />
                <h3 className="text-lg font-semibold">{s.name}</h3>
                <div className="mt-3 flex items-center justify-between">
                  <span className="text-sm text-white/60">{s.price} SOL</span>
                  {owned.includes(s.id) ? (
                    <span className="text-sm" style={{ color: s.color }}>
                      Owned
                    </span>
                  ) : (
                    <motion.button
                      whileHover={{ scale: 1.05 }}
                      whileTap={{ scale: 0.95 }}
                      disabled={!connected || busy !== null}
                      onClick={() => buy(s)}
                      className="rounded-full px-5 py-2 text-sm font-semibold disabled:opacity-40"
                      style={{ background: s.color }}
                    >
                      {busy === s.id ? "Confirming…" : "Buy"}
                    </motion.button>
                  )}
                </div>
              </TiltCard>
            </Reveal>
          ))}
        </div>

        <Reveal delay={0.3}>
          <p className="mt-12 text-xs text-white/35">
            Payments settle as native SOL transfers today. An Anchor program
            that escrows purchases and mints skin ownership on chain is the
            next step on the roadmap.
          </p>
        </Reveal>
      </div>
    </main>
  );
}

export default function ShopPage() {
  return (
    <SolanaProviders>
      <ShopInner />
    </SolanaProviders>
  );
}
