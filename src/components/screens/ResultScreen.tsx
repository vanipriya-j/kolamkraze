"use client";

import { useEffect, useMemo } from "react";
import { useRouter } from "next/navigation";
import { KolamView } from "@/components/game/KolamView";
import { Stars } from "@/components/brand/Stars";
import { Button } from "@/components/ui/Button";
import { DiscoveryCard } from "@/components/commerce/DiscoveryCard";
import { VenueLink } from "@/components/layout/VenueLink";
import { copy } from "@/lib/config/copy";
import { loadGameResult } from "@/lib/game/session";
import { getPatternById, listPatterns } from "@/lib/patterns/catalog";
import { nextPlayablePattern } from "@/lib/game/progression";
import { useProgress } from "@/components/providers/ProgressProvider";
import { useVenue } from "@/components/providers/VenueProvider";
import { venueHref } from "@/lib/navigation";

export function ResultScreen() {
  const router = useRouter();
  const venue = useVenue();
  const { state } = useProgress();
  const result = useMemo(() => loadGameResult(), []);
  const pattern = result ? getPatternById(result.patternId) : undefined;
  const catalog = listPatterns();
  const next = nextPlayablePattern(catalog, state);

  useEffect(() => {
    if (!result || !pattern) router.replace(venueHref("/play/kolam-kraze", venue?.id));
  }, [pattern, result, router, venue?.id]);

  if (!result || !pattern) return null;

  const retryHref = venueHref(
    `/play/kolam-kraze/game?pattern=${pattern.id}&mode=${result.mode === "timed" ? "copy" : result.mode}`,
    venue?.id,
  );
  const nextHref = next
    ? venueHref(`/play/kolam-kraze/game?pattern=${next.id}&mode=${result.mode === "timed" ? "copy" : result.mode}`, venue?.id)
    : venueHref("/play/kolam-kraze/levels", venue?.id);

  const accuracyPct = Math.round(result.accuracy * 100);
  const seconds = Math.round(result.timeMs / 1000);

  return (
    <div className="flex min-h-[100dvh] flex-col px-6 py-8">
      <p className="text-center text-[12px] uppercase tracking-[0.22em] text-earth">
        {result.passed ? copy.completion : "Almost there"}
      </p>
      <h1 className="mt-2 text-center font-display text-4xl text-charcoal">{pattern.name}</h1>
      <div className="mx-auto mt-3">
        <Stars value={result.stars} />
      </div>

      <div className="mx-auto mt-6 h-64 w-64">
        <KolamView pattern={pattern} showReference ghostOpacity={0.92} />
      </div>

      <dl className="mt-8 grid grid-cols-3 gap-3 text-center text-[13px] text-charcoal/70">
        <div>
          <dt className="uppercase tracking-[0.14em] text-charcoal/35">Score</dt>
          <dd className="mt-1 font-display text-2xl text-charcoal">{result.points}</dd>
        </div>
        <div>
          <dt className="uppercase tracking-[0.14em] text-charcoal/35">Accuracy</dt>
          <dd className="mt-1 font-display text-2xl text-charcoal">{accuracyPct}%</dd>
        </div>
        <div>
          <dt className="uppercase tracking-[0.14em] text-charcoal/35">Time</dt>
          <dd className="mt-1 font-display text-2xl text-charcoal">{seconds}s</dd>
        </div>
      </dl>

      {result.timedSummary && (
        <p className="mt-4 text-center text-[14px] text-charcoal/60">
          {result.timedSummary.completed} completed · streak {result.timedSummary.streak}
        </p>
      )}

      <div className="mt-8 flex flex-col gap-3">
        <Button onClick={() => router.push(nextHref)}>Next pattern</Button>
        <Button variant="ghost" onClick={() => router.push(retryHref)}>
          Retry
        </Button>
        <VenueLink
          href={`/play/kolam-kraze/irl/${pattern.id}`}
          className="min-h-11 text-center text-[15px] text-earth"
        >
          {copy.takeOutside}
        </VenueLink>
      </div>

      <DiscoveryCard className="mt-8" reward={venue?.reward} />
    </div>
  );
}
