"use client";

import { useMemo } from "react";
import { KolamView } from "./KolamView";
import { useKolamDrawing } from "./useKolamDrawing";
import { remainingEdgeKeys } from "@/lib/game/validation";
import { parseNodeId } from "@/lib/game/geometry";
import type { DrawnSegment, KolamPattern } from "@/lib/game/types";
import { sounds } from "@/lib/audio/sounds";

type Props = {
  pattern: KolamPattern;
  mode: "copy" | "memory" | "timed";
  showReference: boolean;
  showHint: boolean;
  enabled: boolean;
  muted: boolean;
  accent?: string;
  drawing: ReturnType<typeof useKolamDrawing>;
};

export function GameBoard({
  pattern,
  showReference,
  showHint,
  enabled,
  muted,
  accent,
  drawing,
}: Props) {
  const hintSegments = useMemo<DrawnSegment[]>(() => {
    if (!showHint) return [];
    return [...remainingEdgeKeys(pattern, drawing.segments)].slice(0, 6).map((key) => {
      const [a, b] = key.split("|") as [string, string];
      return { from: parseNodeId(a), to: parseNodeId(b) };
    });
  }, [drawing.segments, pattern, showHint]);

  return (
    <KolamView
      pattern={pattern}
      playerSegments={drawing.segments}
      previewSegments={hintSegments}
      showReference={showReference}
      interactive={enabled}
      currentPoint={drawing.current}
      pointerPoint={drawing.pointer}
      accent={accent}
      className="max-h-full"
      onPointerDown={(point) => {
        sounds.resume();
        drawing.onPointerDown(point);
      }}
      onPointerMove={(point) => {
        const snapped = drawing.onPointerMove(point);
        if (snapped) sounds.snap(muted);
      }}
      onPointerUp={drawing.onPointerUp}
    />
  );
}
