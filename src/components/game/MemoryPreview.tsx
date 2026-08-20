"use client";

import { useCallback, useEffect, useState } from "react";
import { KolamView } from "./KolamView";
import type { KolamPattern } from "@/lib/game/types";
import { Button } from "@/components/ui/Button";

export function MemoryPreview({
  pattern,
  seconds,
  onDone,
  accent,
}: {
  pattern: KolamPattern;
  seconds: number;
  onDone: () => void;
  accent?: string;
}) {
  const [remaining, setRemaining] = useState(seconds);

  useEffect(() => {
    const tick = window.setInterval(() => {
      setRemaining((value) => Math.max(0, value - 1));
    }, 1000);
    const timeout = window.setTimeout(onDone, seconds * 1000);
    return () => {
      window.clearInterval(tick);
      window.clearTimeout(timeout);
    };
  }, [onDone, seconds]);

  const skip = useCallback(() => onDone(), [onDone]);

  return (
    <div className="absolute inset-0 z-10 flex flex-col bg-ivory/92 px-5 py-6">
      <p className="text-center text-[12px] uppercase tracking-[0.22em] text-charcoal/45">
        Remember this
      </p>
      <div className="mx-auto mt-3 min-h-0 w-full flex-1">
        <KolamView pattern={pattern} showReference accent={accent} />
      </div>
      <div className="mt-4 flex items-center justify-between">
        <p className="font-display text-3xl text-charcoal">{remaining}s</p>
        <Button variant="ghost" onClick={skip}>
          I’m ready
        </Button>
      </div>
    </div>
  );
}
