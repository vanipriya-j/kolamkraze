"use client";

import { useSearchParams } from "next/navigation";
import { GamePlay } from "@/components/game/GamePlay";
import { getPatternById, listPatterns } from "@/lib/patterns/catalog";
import { VenueLink } from "@/components/layout/VenueLink";
import type { GameMode } from "@/lib/game/types";

export default function GamePage() {
  const params = useSearchParams();
  const catalog = listPatterns();
  const pattern = getPatternById(params.get("pattern") ?? "") ?? catalog[0]!;
  const mode = (params.get("mode") === "memory" ? "memory" : "copy") as GameMode;
  const isDaily = params.get("daily") === "1";

  if (!pattern) {
    return (
      <div className="px-6 py-10">
        <p>That kolam is not in this library yet.</p>
        <VenueLink href="/play/kolam-kraze">Home</VenueLink>
      </div>
    );
  }

  return <GamePlay pattern={pattern} mode={mode} isDaily={isDaily} />;
}
