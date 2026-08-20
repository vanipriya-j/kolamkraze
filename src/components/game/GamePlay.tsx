"use client";

import { useCallback, useEffect, useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { GameBoard } from "./GameBoard";
import { GameToolbar } from "./GameToolbar";
import { MemoryPreview } from "./MemoryPreview";
import { MuteToggle } from "@/components/ui/MuteToggle";
import { VenueLink } from "@/components/layout/VenueLink";
import { useProgress } from "@/components/providers/ProgressProvider";
import { useVenue } from "@/components/providers/VenueProvider";
import { useKolamDrawing } from "./useKolamDrawing";
import { analytics } from "@/lib/analytics/service";
import { sounds } from "@/lib/audio/sounds";
import { validatePattern } from "@/lib/game/validation";
import { calculateScore } from "@/lib/game/scoring";
import { parTimeMsFor, previewDurationFor, expectedEdgeKeys } from "@/lib/game/geometry";
import { recordCompletion } from "@/lib/game/progression";
import { saveGameResult } from "@/lib/game/session";
import { updateStreak } from "@/lib/game/timed";
import { dateKey } from "@/lib/game/daily";
import { venueHref } from "@/lib/navigation";
import { listPatterns } from "@/lib/patterns/catalog";
import type { GameMode, KolamPattern } from "@/lib/game/types";

type Props = {
  pattern: KolamPattern;
  mode: GameMode;
  isDaily?: boolean;
  timed?: {
    remainingMs: number;
    onSolved: (points: number, accuracy: number) => void;
    onFail: () => void;
  };
};

export function GamePlay({ pattern, mode, isDaily, timed }: Props) {
  const router = useRouter();
  const venue = useVenue();
  const { state, update } = useProgress();
  const drawing = useKolamDrawing(pattern, true);
  const [previewing, setPreviewing] = useState(mode === "memory");
  const endPreview = useCallback(() => setPreviewing(false), []);
  const [hintVisible, setHintVisible] = useState(false);
  const [hintsUsed, setHintsUsed] = useState(0);
  const [retries, setRetries] = useState(0);
  const [startedAt] = useState(() => Date.now());
  const [elapsed, setElapsed] = useState(0);
  const [message, setMessage] = useState<string | null>(null);

  const expectedCount = expectedEdgeKeys(pattern).size;
  const catalog = useMemo(() => listPatterns(), []);

  useEffect(() => {
    analytics.track("level_started", {
      patternId: pattern.id,
      mode,
      venueId: venue?.id,
    });
  }, [mode, pattern.id, venue?.id]);

  useEffect(() => {
    if (previewing) return;
    const timer = window.setInterval(() => setElapsed(Date.now() - startedAt), 250);
    return () => window.clearInterval(timer);
  }, [previewing, startedAt]);

  const showReference = mode === "copy" || hintVisible;
  const accent = venue?.theme?.accent;

  const finishSuccess = useCallback(
    (elapsedMs: number) => {
      const validation = validatePattern(pattern, drawing.segments);
      const score = calculateScore({
        validation,
        elapsedMs,
        parTimeMs: parTimeMsFor(pattern),
        retries,
        hintsUsed,
        streak: state.streak,
      });
      sounds.complete(state.muted);
      analytics.track("level_completed", {
        patternId: pattern.id,
        mode,
        stars: score.stars,
        points: score.points,
      });
      if (timed) {
        timed.onSolved(score.points, validation.accuracy);
        return;
      }
      update((current) => {
        const completed = recordCompletion(updateStreak(current), {
          patternId: pattern.id,
          stars: score.stars,
          timeMs: elapsedMs,
          catalog,
        });
        if (!isDaily) return completed;
        return {
          ...completed,
          daily: {
            ...completed.daily,
            [dateKey()]: {
              patternId: pattern.id,
              stars: score.stars,
              completedAt: new Date().toISOString(),
            },
          },
        };
      });
      saveGameResult({
        patternId: pattern.id,
        mode,
        stars: score.stars,
        points: score.points,
        accuracy: validation.accuracy,
        timeMs: elapsedMs,
        retries,
        hintsUsed,
        passed: true,
        completion: validation.completion,
        venueId: venue?.id,
      });
      router.push(venueHref("/play/kolam-kraze/result", venue?.id));
    },
    [catalog, drawing.segments, hintsUsed, isDaily, mode, pattern, retries, router, state.muted, state.streak, timed, update, venue?.id],
  );

  const check = useCallback(() => {
    const validation = validatePattern(pattern, drawing.segments);
    if (validation.passed) {
      finishSuccess(Date.now() - startedAt);
      return;
    }
    sounds.error(state.muted);
    analytics.track("level_failed", {
      patternId: pattern.id,
      mode,
      completion: Number(validation.completion.toFixed(2)),
    });
    setRetries((value) => value + 1);
    setMessage("Not quite. Follow the loops a little further.");
    timed?.onFail();
  }, [drawing.segments, finishSuccess, mode, pattern, startedAt, state.muted, timed]);

  const hint = useCallback(() => {
    if (hintsUsed >= 1 && mode === "memory") return;
    analytics.track("hint_used", { patternId: pattern.id, mode });
    sounds.hint(state.muted);
    setHintsUsed((value) => value + 1);
    setHintVisible(true);
    window.setTimeout(() => setHintVisible(false), 2600);
  }, [hintsUsed, mode, pattern.id, state.muted]);

  useEffect(() => {
    const onKey = (event: KeyboardEvent) => {
      if (event.target instanceof HTMLInputElement || event.target instanceof HTMLTextAreaElement) return;
      if (event.key === "Enter") check();
      if (event.key === "Escape") drawing.reset();
      if (event.key.toLowerCase() === "z" && !event.metaKey && !event.ctrlKey) drawing.undo();
      if (event.key.toLowerCase() === "h") hint();
    };
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  }, [check, drawing, hint]);

  const matched = useMemo(() => {
    const validation = validatePattern(pattern, drawing.segments);
    return validation.matchedEdges;
  }, [drawing.segments, pattern]);

  const timerLabel = timed
    ? formatMs(timed.remainingMs)
    : formatMs(elapsed);

  return (
    <div className="flex min-h-[100dvh] flex-col">
      <header className="flex items-center justify-between px-4 pt-4">
        <VenueLink href="/play/kolam-kraze" className="min-h-11 text-[13px] text-charcoal/60">
          Close
        </VenueLink>
        <div className="text-center">
          <p className="text-[11px] uppercase tracking-[0.2em] text-charcoal/40">
            {mode === "copy" ? "Copy" : mode === "memory" ? "Memory" : "Timed"}
          </p>
          <p className="font-display text-xl text-charcoal">{pattern.name}</p>
        </div>
        <div className="flex items-center gap-1">
          <p className="min-w-[3rem] text-right text-[13px] tabular-nums text-charcoal/60">{timerLabel}</p>
          <MuteToggle />
        </div>
      </header>

      <div className="relative mx-auto mt-2 min-h-0 w-full max-w-[32rem] flex-1 px-3">
        {previewing && (
          <MemoryPreview
            pattern={pattern}
            seconds={previewDurationFor(pattern)}
            accent={accent}
            onDone={endPreview}
          />
        )}
        <GameBoard
          pattern={pattern}
          mode={mode}
          showReference={showReference && !previewing}
          showHint={hintVisible}
          enabled={!previewing}
          muted={state.muted}
          accent={accent}
          drawing={drawing}
        />
      </div>

      {message && (
        <p className="px-6 pb-2 text-center text-[14px] text-earth">{message}</p>
      )}

      <div className="px-4 pb-[max(1rem,env(safe-area-inset-bottom))] pt-2">
        <GameToolbar
          onUndo={drawing.undo}
          onClear={drawing.reset}
          onHint={mode === "memory" ? hint : undefined}
          hintAvailable={mode === "memory"}
          hintDisabled={hintsUsed >= 1}
          onCheck={check}
          canUndo={drawing.segments.length > 0}
          progressLabel={`${matched} / ${expectedCount}`}
        />
      </div>
    </div>
  );
}

function formatMs(ms: number) {
  const total = Math.max(0, Math.round(ms / 1000));
  const m = Math.floor(total / 60);
  const s = total % 60;
  return `${m}:${String(s).padStart(2, "0")}`;
}
