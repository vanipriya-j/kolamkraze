"use client";

import { useEffect, useSyncExternalStore } from "react";
import { VenueLink } from "@/components/layout/VenueLink";
import { MuteToggle } from "@/components/ui/MuteToggle";
import { copy } from "@/lib/config/copy";
import { analytics } from "@/lib/analytics/service";
import { useVenue } from "@/components/providers/VenueProvider";
import { useProgress } from "@/components/providers/ProgressProvider";
import { listPatterns, getPatternById } from "@/lib/patterns/catalog";
import { nextPlayablePattern } from "@/lib/game/progression";
import { isWeeklyChallengeActive, weeklyChallenge } from "@/lib/campaigns/weekly";
import { getDailyPattern } from "@/lib/game/daily";
import { venueHref } from "@/lib/navigation";
import { useRouter } from "next/navigation";
import { VenueWelcome } from "@/components/venue/VenueWelcome";

const seenKey = (id: string) => `aarla.kolam-kraze.venue-welcome:${id}`;
const welcomeListeners = new Set<() => void>();

function subscribeWelcome(listener: () => void) {
  welcomeListeners.add(listener);
  return () => welcomeListeners.delete(listener);
}

function venueWelcomePending(venueId?: string) {
  if (!venueId) return false;
  return sessionStorage.getItem(seenKey(venueId)) !== "1";
}

function dismissVenueWelcome(venueId: string) {
  sessionStorage.setItem(seenKey(venueId), "1");
  welcomeListeners.forEach((listener) => listener());
}

export function HomeScreen() {
  const venue = useVenue();
  const router = useRouter();
  const { state } = useProgress();
  const catalog = listPatterns();
  const next = nextPlayablePattern(catalog, state);
  const daily = getDailyPattern(catalog);
  const weeklyOn = isWeeklyChallengeActive();
  const showVenue = useSyncExternalStore(
    subscribeWelcome,
    () => venueWelcomePending(venue?.id),
    () => Boolean(venue),
  );

  useEffect(() => {
    analytics.track("game_opened", { venueId: venue?.id });
  }, [venue]);

  if (venue && showVenue) {
    return (
      <VenueWelcome
        venue={venue}
        onPlay={() => {
          dismissVenueWelcome(venue.id);
          const featured = getPatternById(venue.featuredPatternIds?.[0] ?? daily.id) ?? daily;
          analytics.track("mode_selected", { mode: "copy", venueId: venue.id });
          router.push(venueHref(`/play/kolam-kraze/game?pattern=${featured.id}&mode=copy`, venue.id));
        }}
      />
    );
  }

  const completedCount = state.completed.length;

  return (
    <div className="flex min-h-[100dvh] flex-col px-6 py-8">
      <header className="flex items-start justify-between">
        <div>
          <p className="text-[12px] uppercase tracking-[0.24em] text-charcoal/45">{copy.brand}</p>
          <h1 className="mt-3 font-display text-[2.6rem] leading-none text-charcoal">{copy.game}</h1>
          <p className="mt-3 text-charcoal/65">{copy.tagline}</p>
        </div>
        <MuteToggle />
      </header>

      {venue && (
        <p className="mt-6 text-[13px] tracking-wide text-earth">Playing at {venue.name}</p>
      )}

      <p className="mt-8 text-[13px] uppercase tracking-[0.16em] text-charcoal/40">
        {completedCount} of {catalog.length} patterns · {state.irlCompletions} made IRL
      </p>

      <nav className="mt-8 flex flex-col gap-3">
        {next && (
          <VenueLink
            href={`/play/kolam-kraze/game?pattern=${next.id}&mode=copy`}
            onClick={() => analytics.track("mode_selected", { mode: "copy", source: "continue" })}
            className="rounded-3xl bg-charcoal px-5 py-5 text-ivory"
          >
            <span className="block text-[12px] uppercase tracking-[0.18em] text-ivory/55">Continue</span>
            <span className="mt-1 block font-display text-3xl">{next.name}</span>
          </VenueLink>
        )}
        <ModeLink href="/play/kolam-kraze/levels?mode=copy" label="Copy Mode" note="The pattern stays with you" mode="copy" />
        <ModeLink href="/play/kolam-kraze/levels?mode=memory" label="Memory Mode" note="See it, then draw from memory" mode="memory" />
        <ModeLink href="/play/kolam-kraze/timed" label="Timed Challenge" note="About two minutes" mode="timed" />
        <ModeLink
          href={`/play/kolam-kraze/daily`}
          label="Daily Kolam"
          note={daily.name}
          mode="daily"
        />
        <ModeLink href="/play/kolam-kraze/irl" label="Kolam IRL" note="Take it outside" mode="irl" />
      </nav>

      {weeklyOn && (
        <VenueLink
          href={weeklyChallenge.ctaHref}
          className="mt-8 rounded-3xl border border-charcoal/10 px-5 py-4"
        >
          <p className="text-[11px] uppercase tracking-[0.18em] text-earth">This week</p>
          <p className="mt-1 font-display text-2xl text-charcoal">{weeklyChallenge.title}</p>
          <p className="mt-1 text-[14px] text-charcoal/60">{weeklyChallenge.prizeText}</p>
        </VenueLink>
      )}

      <p className="mt-auto pt-10 text-center text-[13px] text-charcoal/40">{copy.philosophy}</p>
    </div>
  );
}

function ModeLink({
  href,
  label,
  note,
  mode,
}: {
  href: string;
  label: string;
  note: string;
  mode: string;
}) {
  return (
    <VenueLink
      href={href}
      onClick={() => analytics.track("mode_selected", { mode })}
      className="flex items-baseline justify-between rounded-2xl border border-charcoal/10 px-5 py-4"
    >
      <span className="font-display text-2xl text-charcoal">{label}</span>
      <span className="text-[13px] text-charcoal/45">{note}</span>
    </VenueLink>
  );
}
