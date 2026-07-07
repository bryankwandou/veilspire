"use client";

import dynamic from "next/dynamic";
import { motion } from "framer-motion";
import { PublicKey, Transaction } from "@solana/web3.js";
import {
  createAssociatedTokenAccountIdempotentInstruction,
  createTransferInstruction,
  getAssociatedTokenAddressSync,
} from "@solana/spl-token";
import { useConnection, useWallet } from "@solana/wallet-adapter-react";
import { useCallback, useEffect, useState } from "react";

import { SolanaProviders } from "./providers";
import { Reveal, TiltCard } from "@/components/motion";

const WalletMultiButton = dynamic(
  () =>
    import("@solana/wallet-adapter-react-ui").then(
      (m) => m.WalletMultiButton,
    ),
  { ssr: false },
);

// Circle's USDC mint on devnet (6 decimals). Faucet: faucet.circle.com
const USDC_MINT = new PublicKey(
  "4zMMC9srt5Ri5X14GAgXhaHii3GnPAEERYPJgZJDncDU",
);
const USDC_DECIMALS = 1_000_000;

// Demo treasury on devnet. Purchases here move devnet USDC only.
const TREASURY = new PublicKey(
  "9WzDXwBbmkg8ZTbNMqUxvQRAyrZzDsGYdLVL9zYtAWWM",
);

const skins = [
  { id: "veyra-loom", name: "Veyra · Evening Loom", price: 1.5, color: "#7C5CFF" },
  { id: "lyra-tide", name: "Lyra · Low Shard-Tide", price: 1.5, color: "#35C4B5" },
  { id: "kaelen-ember", name: "Kaelen · First Commission", price: 2.5, color: "#B4552D" },
  { id: "sera-vigil", name: "Seraphine · Archive Formal", price: 2.5, color: "#9E2B25" },
  { id: "oren-road", name: "Oren · Faded Gold Road", price: 1.5, color: "#C9A227" },
];

function ShopInner() {
  const { connection } = useConnection();
  const { publicKey, sendTransaction, connected } = useWallet();
  const [usdc, setUsdc] = useState<number | null>(null);
  const [busy, setBusy] = useState<string | null>(null);
  const [owned, setOwned] = useState<string[]>([]);
  const [status, setStatus] = useState<string | null>(null);
  const [lastSig, setLastSig] = useState<string | null>(null);

  const refreshBalance = useCallback(async () => {
    if (!publicKey) return setUsdc(null);
    try {
      const ata = getAssociatedTokenAddressSync(USDC_MINT, publicKey);
      const bal = await connection.getTokenAccountBalance(ata);
      setUsdc(bal.value.uiAmount ?? 0);
    } catch {
      setUsdc(0); // no USDC account yet
    }
  }, [publicKey, connection]);

  useEffect(() => {
    refreshBalance();
  }, [refreshBalance, owned]);

  async function buy(skin: (typeof skins)[number]) {
    if (!publicKey) return;
    setBusy(skin.id);
    setStatus(null);
    setLastSig(null);
    try {
      const buyerAta = getAssociatedTokenAddressSync(USDC_MINT, publicKey);
      const treasuryAta = getAssociatedTokenAddressSync(USDC_MINT, TREASURY);
      const tx = new Transaction().add(
        // ensure the treasury token account exists; no-op when it does
        createAssociatedTokenAccountIdempotentInstruction(
          publicKey,
          treasuryAta,
          TREASURY,
          USDC_MINT,
        ),
        createTransferInstruction(
          buyerAta,
          treasuryAta,
          publicKey,
          Math.round(skin.price * USDC_DECIMALS),
        ),
      );
      const sig = await sendTransaction(tx, connection);
      await connection.confirmTransaction(sig, "confirmed");
      setOwned((o) => [...o, skin.id]);
      setLastSig(sig);
      setStatus("Purchase confirmed on devnet.");
    } catch (e) {
      const msg = e instanceof Error ? e.message : "Transaction failed.";
      setStatus(
        msg.includes("could not find account") || msg.includes("invalid account data")
          ? "Your wallet has no devnet USDC yet. Get some free at faucet.circle.com (pick Solana Devnet), then try again."
          : msg,
      );
    } finally {
      setBusy(null);
    }
  }

  return (
    <main className="min-h-screen bg-[#070A14] px-6 py-16 text-white">
      <div className="mx-auto max-w-5xl">
        <Reveal>
          <p className="text-xs tracking-[0.35em] text-white/50">
            VEILSPIRE OUTFITTER · USDC ON DEVNET
          </p>
          <h1 className="mt-3 text-4xl font-bold sm:text-5xl">
            Skins, paid in USDC from your wallet.
          </h1>
          <p className="mt-4 max-w-2xl text-white/60">
            Connect Solflare or Phantom. Your wallet address is your player
            identity; every purchase settles as a USDC token transfer on
            Solana devnet, so the whole flow is verifiable on-chain without
            spending real money. Free devnet USDC: faucet.circle.com. The
            mainnet path is the same code pointed at a different endpoint.
          </p>
        </Reveal>

        <Reveal delay={0.15}>
          <div className="mt-8 flex flex-wrap items-center gap-4">
            <WalletMultiButton />
            {connected && publicKey && (
              <span className="rounded-full border border-white/15 px-4 py-2 text-sm text-white/70">
                Player {publicKey.toBase58().slice(0, 4)}…
                {publicKey.toBase58().slice(-4)} · {usdc ?? "…"} USDC
              </span>
            )}
          </div>
        </Reveal>

        {status && (
          <p className="mt-4 text-sm text-[#9E7BFF]">
            {status}{" "}
            {lastSig && (
              <a
                className="underline"
                href={`https://explorer.solana.com/tx/${lastSig}?cluster=devnet`}
                target="_blank"
                rel="noreferrer"
              >
                View on Solana Explorer
              </a>
            )}
          </p>
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
                  <span className="text-sm text-white/60">{s.price} USDC</span>
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
            Devnet only, by design: the public demo never touches real funds.
            Purchases are SPL token transfers of Circle devnet USDC, viewable
            on any Solana explorer.
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
