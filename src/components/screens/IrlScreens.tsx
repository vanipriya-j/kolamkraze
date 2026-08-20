"use client";

import { useEffect, useRef, useState } from "react";
import { KolamView } from "@/components/game/KolamView";
import { Button } from "@/components/ui/Button";
import { VenueLink } from "@/components/layout/VenueLink";
import { IrlBadge } from "@/components/brand/IrlBadge";
import { copy } from "@/lib/config/copy";
import { analytics } from "@/lib/analytics/service";
import { getPatternById, listPatterns } from "@/lib/patterns/catalog";
import { useProgress } from "@/components/providers/ProgressProvider";
import { downloadKolamReference } from "@/lib/game/export-image";

export function IrlIndex() {
  const { state } = useProgress();
  const catalog = listPatterns();
  const completed = catalog.filter((pattern) => state.completed.includes(pattern.id) || state.irl.includes(pattern.id));
  const list = completed.length > 0 ? completed : catalog.slice(0, 6);

  return (
    <div className="min-h-[100dvh] px-6 py-8">
      <VenueLink href="/play/kolam-kraze" className="min-h-11 text-[13px] text-charcoal/60">
        Back
      </VenueLink>
      <h1 className="mt-6 font-display text-4xl text-charcoal">{copy.irlTitle}</h1>
      <p className="mt-3 max-w-sm text-charcoal/65">{copy.irlLead}</p>
      <div className="mt-8 grid grid-cols-2 gap-3">
        {list.map((pattern) => (
          <VenueLink key={pattern.id} href={`/play/kolam-kraze/irl/${pattern.id}`} className="block">
            <div className="aspect-square rounded-2xl bg-ivory-deep/70 p-3">
              <KolamView pattern={pattern} showReference ghostOpacity={0.9} />
            </div>
            <div className="mt-2 flex items-center justify-between">
              <p className="text-[14px] text-charcoal">{pattern.name}</p>
              {state.irl.includes(pattern.id) && <IrlBadge compact />}
            </div>
          </VenueLink>
        ))}
      </div>
    </div>
  );
}

export function IrlDetail({ patternId }: { patternId: string }) {
  const pattern = getPatternById(patternId);
  const { state, update } = useProgress();
  const svgRef = useRef<SVGSVGElement>(null);
  const [saving, setSaving] = useState(false);
  const marked = Boolean(pattern && state.irl.includes(pattern.id));

  useEffect(() => {
    if (pattern) analytics.track("irl_opened", { patternId: pattern.id });
  }, [pattern]);

  if (!pattern) {
    return (
      <div className="px-6 py-10">
        <p>This kolam could not be found.</p>
        <VenueLink href="/play/kolam-kraze/irl">Back</VenueLink>
      </div>
    );
  }

  return (
    <div className="flex min-h-[100dvh] flex-col px-6 py-8">
      <VenueLink href="/play/kolam-kraze/irl" className="min-h-11 text-[13px] text-charcoal/60">
        Back
      </VenueLink>
      <p className="mt-6 text-[12px] uppercase tracking-[0.22em] text-earth">{copy.irlTitle}</p>
      <h1 className="mt-2 font-display text-4xl text-charcoal">{pattern.name}</h1>
      <p className="mt-3 max-w-sm text-[17px] leading-relaxed text-charcoal/70">{copy.irlLead}</p>

      <div className="mx-auto mt-6 w-full max-w-sm">
        <KolamView svgRef={svgRef} pattern={pattern} showReference ghostOpacity={0.95} className="bg-ivory" />
      </div>

      <ol className="mt-8 space-y-2 text-[15px] leading-relaxed text-charcoal/75">
        <li>1. Draw this kolam outside your home.</li>
        <li>2. Take a photo.</li>
        <li>3. Post it on Instagram.</li>
        <li>4. Tag <strong>@aarla.culture</strong></li>
        <li>5. Use <strong>#KolamKraze</strong></li>
        <li>6. Stand a chance to win an <strong>Aarla Kolam Hamper</strong></li>
      </ol>
      <p className="mt-4 text-[12px] leading-relaxed text-charcoal/45">
        Campaign terms may apply. Instagram is not affiliated with this contest or with Aarla Play.
      </p>
      <p className="mt-3 text-[15px] text-charcoal">{copy.irlCta}</p>

      <div className="mt-8 flex flex-col gap-3">
        <Button
          variant="ghost"
          disabled={saving}
          onClick={async () => {
            if (!svgRef.current) return;
            setSaving(true);
            await downloadKolamReference(svgRef.current, pattern.name);
            setSaving(false);
          }}
        >
          {saving ? "Preparing…" : "Save reference"}
        </Button>
        <Button
          onClick={() => {
            update((current) => {
              if (current.irl.includes(pattern.id)) return current;
              return {
                ...current,
                irl: [...current.irl, pattern.id],
                irlCompletions: current.irlCompletions + 1,
              };
            });
            analytics.track("irl_marked_complete", { patternId: pattern.id });
          }}
        >
          {copy.markIrl}
        </Button>
        {marked && (
          <div className="flex justify-center pt-2">
            <IrlBadge />
          </div>
        )}
      </div>
    </div>
  );
}
