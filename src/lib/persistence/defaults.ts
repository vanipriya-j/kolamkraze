import type { ProgressState } from "./types";

export function createDefaultProgress(): ProgressState {
  return {
    version: 1,
    stars: {},
    bestTimeMs: {},
    unlocked: [],
    completed: [],
    daily: {},
    irl: [],
    muted: false,
    streak: 0,
    digitalCompletions: 0,
    irlCompletions: 0,
  };
}

export function mergeProgress(raw: unknown): ProgressState {
  const fallback = createDefaultProgress();
  if (!raw || typeof raw !== "object") return fallback;
  const value = raw as Partial<ProgressState>;
  return {
    ...fallback,
    ...value,
    version: 1,
    stars: value.stars ?? {},
    bestTimeMs: value.bestTimeMs ?? {},
    unlocked: value.unlocked ?? [],
    completed: value.completed ?? [],
    daily: value.daily ?? {},
    irl: value.irl ?? [],
    muted: Boolean(value.muted),
    streak: value.streak ?? 0,
    digitalCompletions: value.digitalCompletions ?? 0,
    irlCompletions: value.irlCompletions ?? 0,
  };
}
