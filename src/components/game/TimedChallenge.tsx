"use client";

import { useEffect, useMemo, useRef, useState } from "react";
import { useRouter } from "next/navigation";
import { GamePlay } from "./GamePlay";
import { getTimedPool } from "@/lib/patterns/catalog";
import { saveGameResult } from "@/lib/game/session";
import { TIMED_START_MS, timedBonusMs, updateStreak } from "@/lib/game/timed";
import { venueHref } from "@/lib/navigation";
import { useVenue } from "@/components/providers/VenueProvider";
import { useProgress } from "@/components/providers/ProgressProvider";
import type { TimedSummary } from "@/lib/game/types";

export function TimedChallenge() {
  const router = useRouter();
  const venue = useVenue();
  const { update } = useProgress();
  const pool = useMemo(() => getTimedPool(), []);
  const [index, setIndex] = useState(0);
  const [remainingMs, setRemainingMs] = useState(TIMED_START_MS);
  const [completed, setCompleted] = useState(0);
  const [totalScore, setTotalScore] = useState(0);
  const [streak, setStreak] = useState(0);
  const [accuracies, setAccuracies] = useState<number[]>([]);
  const statsRef = useRef({ completed: 0, totalScore: 0, streak: 0, accuracies: [] as number[] });

  useEffect(() => {
    statsRef.current = { completed, totalScore, streak, accuracies };
  }, [accuracies, completed, streak, totalScore]);

  useEffect(() => {
    const timer = window.setInterval(() => {
      setRemainingMs((value) => Math.max(0, value - 250));
    }, 250);
    return () => window.clearInterval(timer);
  }, []);

  useEffect(() => {
    if (remainingMs > 0) return;
    const stats = statsRef.current;
    const pattern = pool[index % pool.length]!;
    const summary: TimedSummary = {
      completed: stats.completed,
      averageAccuracy: stats.accuracies.length
        ? stats.accuracies.reduce((sum, value) => sum + value, 0) / stats.accuracies.length
        : 0,
      streak: stats.streak,
      totalScore: stats.totalScore,
      remainingMs: 0,
    };
    update((current) => updateStreak(current));
    saveGameResult({
      patternId: pattern.id,
      mode: "timed",
      stars: stats.completed >= 5 ? 3 : stats.completed >= 3 ? 2 : stats.completed >= 1 ? 1 : 0,
      points: stats.totalScore,
      accuracy: summary.averageAccuracy,
      timeMs: TIMED_START_MS,
      retries: 0,
      hintsUsed: 0,
      passed: stats.completed > 0,
      completion: stats.completed > 0 ? 1 : 0,
      venueId: venue?.id,
      timedSummary: summary,
    });
    router.push(venueHref("/play/kolam-kraze/result", venue?.id));
  }, [index, pool, remainingMs, router, update, venue?.id]);

  const pattern = pool[index % pool.length]!;
  if (remainingMs <= 0) return null;

  return (
    <GamePlay
      key={`${pattern.id}-${index}`}
      pattern={pattern}
      mode="timed"
      timed={{
        remainingMs,
        onSolved: (points, accuracy) => {
          const nextStreak = streak + 1;
          setCompleted((value) => value + 1);
          setTotalScore((value) => value + points);
          setStreak(nextStreak);
          setAccuracies((value) => [...value, accuracy]);
          setRemainingMs((value) => value + timedBonusMs(accuracy, nextStreak));
          setIndex((value) => value + 1);
        },
        onFail: () => setStreak(0),
      }}
    />
  );
}
