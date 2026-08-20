"use client";

import { useMemo } from "react";
import { useSearchParams } from "next/navigation";
import { VenueLink } from "@/components/layout/VenueLink";
import { KolamView } from "@/components/game/KolamView";
import { Stars } from "@/components/brand/Stars";
import { IrlBadge } from "@/components/brand/IrlBadge";
import { listPatterns } from "@/lib/patterns/catalog";
import { isUnlocked } from "@/lib/game/progression";
import { useProgress } from "@/components/providers/ProgressProvider";
import { useVenue } from "@/components/providers/VenueProvider";
import type { GameMode, PatternCategory } from "@/lib/game/types";

const labels: Record<PatternCategory, string> = {
  beginner: "Beginner",
  easy: "Easy",
  intermediate: "Intermediate",
  advanced: "Advanced",
};

export function LevelSelect() {
  const params = useSearchParams();
  const mode = (params.get("mode") === "memory" ? "memory" : "copy") as GameMode;
  const { state } = useProgress();
  const venue = useVenue();
  const catalog = useMemo(() => listPatterns(), []);

  const groups = (Object.keys(labels) as PatternCategory[]).map((category) => ({
    category,
    items: catalog.filter((pattern) => pattern.category === category),
  }));

  return (
    <div className="min-h-[100dvh] px-5 py-6">
      <header className="flex items-center justify-between">
        <VenueLink href="/play/kolam-kraze" className="min-h-11 text-[13px] text-charcoal/60">
          Back
        </VenueLink>
        <h1 className="font-display text-3xl text-charcoal">{mode === "memory" ? "Memory" : "Copy"}</h1>
        <span className="w-10" />
      </header>
      <p className="mt-2 text-center text-[14px] text-charcoal/50">
        {mode === "memory" ? "Look once. Then draw." : "The pattern remains. Trace the loops."}
      </p>

      <div className="mt-8 space-y-8">
        {groups.map((group) => (
          <section key={group.category}>
            <h2 className="text-[12px] uppercase tracking-[0.2em] text-charcoal/40">
              {labels[group.category]}
            </h2>
            <div className="mt-3 grid grid-cols-2 gap-3">
              {group.items.map((pattern) => {
                const unlocked = isUnlocked(pattern, catalog, state);
                const href = `/play/kolam-kraze/game?pattern=${pattern.id}&mode=${mode}`;
                const inner = (
                  <>
                    <div className="aspect-square rounded-2xl bg-ivory-deep/70 p-3">
                      <KolamView pattern={pattern} showReference ghostOpacity={unlocked ? 0.85 : 0.2} />
                    </div>
                    <div className="mt-2 flex items-center justify-between">
                      <p className="text-[13px] text-charcoal">
                        {String(catalog.indexOf(pattern) + 1).padStart(2, "0")} · {pattern.name}
                      </p>
                    </div>
                    <div className="mt-1 flex items-center justify-between">
                      <Stars value={state.stars[pattern.id] ?? 0} size="sm" />
                      {state.irl.includes(pattern.id) && <IrlBadge compact />}
                    </div>
                    {!unlocked && (
                      <p className="mt-1 text-[11px] uppercase tracking-[0.14em] text-charcoal/35">Locked</p>
                    )}
                  </>
                );
                return unlocked ? (
                  <VenueLink key={pattern.id} href={href} className="block">
                    {inner}
                  </VenueLink>
                ) : (
                  <div key={pattern.id} className="opacity-50">
                    {inner}
                  </div>
                );
              })}
            </div>
          </section>
        ))}
      </div>
      {venue && <p className="mt-10 text-center text-[12px] text-charcoal/35">{venue.name}</p>}
    </div>
  );
}
