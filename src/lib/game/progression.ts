import type { KolamPattern, StarRating } from "./types";
import type { ProgressState } from "@/lib/persistence/types";

const INITIAL_UNLOCK_COUNT = 3;

export function isUnlocked(
  pattern: KolamPattern,
  catalog: KolamPattern[],
  state: ProgressState,
): boolean {
  if (state.unlocked.includes(pattern.id)) return true;
  if (state.completed.includes(pattern.id)) return true;
  const index = catalog.findIndex((item) => item.id === pattern.id);
  if (index < 0) return false;
  if (index < INITIAL_UNLOCK_COUNT) return true;
  const previous = catalog[index - 1];
  return Boolean(previous && state.completed.includes(previous.id));
}

export function unlockAfterCompletion(
  patternId: string,
  catalog: KolamPattern[],
  state: ProgressState,
): string[] {
  const unlocked = new Set(state.unlocked);
  unlocked.add(patternId);
  const index = catalog.findIndex((item) => item.id === patternId);
  const next = catalog[index + 1];
  if (next) unlocked.add(next.id);
  catalog.slice(0, INITIAL_UNLOCK_COUNT).forEach((item) => unlocked.add(item.id));
  return [...unlocked];
}

export function nextPlayablePattern(
  catalog: KolamPattern[],
  state: ProgressState,
): KolamPattern | null {
  const continueId = state.continue?.patternId;
  if (continueId) {
    const continued = catalog.find((item) => item.id === continueId);
    if (continued && isUnlocked(continued, catalog, state)) return continued;
  }
  for (const pattern of catalog) {
    if (!isUnlocked(pattern, catalog, state)) continue;
    const stars = state.stars[pattern.id] ?? 0;
    if (stars < 3) return pattern;
  }
  return catalog.find((pattern) => isUnlocked(pattern, catalog, state)) ?? catalog[0] ?? null;
}

export function bestStars(state: ProgressState, patternId: string): StarRating {
  return (state.stars[patternId] ?? 0) as StarRating;
}

export function recordCompletion(
  state: ProgressState,
  args: {
    patternId: string;
    stars: StarRating;
    timeMs: number;
    catalog: KolamPattern[];
  },
): ProgressState {
  const previousStars = state.stars[args.patternId] ?? 0;
  const stars = Math.max(previousStars, args.stars) as StarRating;
  const previousTime = state.bestTimeMs[args.patternId];
  const bestTimeMs = {
    ...state.bestTimeMs,
    [args.patternId]:
      previousTime === undefined ? args.timeMs : Math.min(previousTime, args.timeMs),
  };
  const completed = state.completed.includes(args.patternId)
    ? state.completed
    : [...state.completed, args.patternId];

  const nextState: ProgressState = {
    ...state,
    stars: { ...state.stars, [args.patternId]: stars },
    bestTimeMs,
    completed,
    unlocked: unlockAfterCompletion(args.patternId, args.catalog, { ...state, completed }),
    digitalCompletions: state.digitalCompletions + 1,
  };

  return {
    ...nextState,
    continue: nextContinue(args.catalog, nextState),
  };
}

function nextContinue(catalog: KolamPattern[], state: ProgressState): ProgressState["continue"] {
  const next = nextPlayablePattern(catalog, { ...state, continue: undefined });
  if (!next) return undefined;
  return { patternId: next.id, mode: "copy" };
}
