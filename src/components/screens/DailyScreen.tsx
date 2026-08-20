"use client";

import { useEffect } from "react";
import { KolamView } from "@/components/game/KolamView";
import { VenueLink } from "@/components/layout/VenueLink";
import { getDailyPattern, dateKey } from "@/lib/game/daily";
import { listPatterns } from "@/lib/patterns/catalog";
import { analytics } from "@/lib/analytics/service";
import { useProgress } from "@/components/providers/ProgressProvider";
import { Stars } from "@/components/brand/Stars";

export function DailyScreen() {
  const catalog = listPatterns();
  const pattern = getDailyPattern(catalog);
  const { state } = useProgress();
  const today = dateKey();
  const record = state.daily[today];

  useEffect(() => {
    analytics.track("daily_kolam_started", { patternId: pattern.id });
  }, [pattern.id]);

  return (
    <div className="flex min-h-[100dvh] flex-col px-6 py-8">
      <VenueLink href="/play/kolam-kraze" className="min-h-11 text-[13px] text-charcoal/60">
        Back
      </VenueLink>
      <p className="mt-6 text-[12px] uppercase tracking-[0.22em] text-earth">Today’s Kolam</p>
      <h1 className="mt-2 font-display text-4xl text-charcoal">{pattern.name}</h1>
      <p className="mt-2 text-charcoal/55">{today}</p>
      {record && (
        <div className="mt-3">
          <Stars value={record.stars} />
        </div>
      )}
      <div className="mx-auto mt-8 h-72 w-72">
        <KolamView pattern={pattern} showReference ghostOpacity={0.9} />
      </div>
      <div className="mt-10 flex flex-col gap-3">
        <VenueLink
          href={`/play/kolam-kraze/game?pattern=${pattern.id}&mode=copy&daily=1`}
          className="inline-flex min-h-12 items-center justify-center rounded-full bg-charcoal text-[15px] tracking-wide text-ivory"
        >
          Play
        </VenueLink>
        <VenueLink
          href={`/play/kolam-kraze/game?pattern=${pattern.id}&mode=memory&daily=1`}
          className="inline-flex min-h-12 items-center justify-center rounded-full border border-charcoal/20 text-[15px] tracking-wide text-charcoal"
        >
          Try from memory
        </VenueLink>
        <VenueLink
          href={`/play/kolam-kraze/irl/${pattern.id}`}
          className="min-h-11 text-center text-[15px] text-earth"
        >
          Take it outside →
        </VenueLink>
      </div>
    </div>
  );
}
