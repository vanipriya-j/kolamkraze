"use client";

import { Button } from "@/components/ui/Button";
import { copy } from "@/lib/config/copy";
import type { VenueConfig } from "@/lib/venues/catalog";
import { analytics } from "@/lib/analytics/service";
import { useEffect } from "react";

export function VenueWelcome({
  venue,
  onPlay,
}: {
  venue: VenueConfig;
  onPlay: () => void;
}) {
  useEffect(() => {
    analytics.track("venue_opened", { venueId: venue.id });
  }, [venue.id]);

  return (
    <div className="flex min-h-[100dvh] flex-col justify-between px-6 py-10">
      <div>
        <p className="text-[12px] uppercase tracking-[0.24em] text-charcoal/45">{copy.brand}</p>
        <p className="mt-8 text-[13px] uppercase tracking-[0.18em] text-earth">Playing at</p>
        <h1 className="mt-2 font-display text-5xl leading-[0.95] text-charcoal">{venue.name}</h1>
        {venue.subtitle && <p className="mt-3 text-charcoal/60">{venue.subtitle}</p>}
      </div>
      <div>
        <p className="max-w-[16rem] font-display text-3xl leading-tight text-charcoal">
          {copy.venueSpare}
        </p>
        <p className="mt-3 text-[17px] text-charcoal/70">{venue.message ?? copy.venuePlay}</p>
        <Button className="mt-8 w-full" onClick={onPlay}>
          {copy.venueCta}
        </Button>
      </div>
    </div>
  );
}
