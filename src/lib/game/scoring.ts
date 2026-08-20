import type { ScoreInput, ScoreResult, StarRating } from "./types";

export function calculateScore(input: ScoreInput): ScoreResult {
  const { validation, elapsedMs, parTimeMs, retries, hintsUsed, streak } = input;
  const completion = validation.completion;
  const accuracy = validation.accuracy;

  if (!validation.passed) {
    return {
      points: Math.round(completion * 180),
      stars: 0,
      accuracy,
      timeMs: elapsedMs,
    };
  }

  const timeRatio = parTimeMs <= 0 ? 1 : Math.max(0, Math.min(1, (parTimeMs - elapsedMs) / parTimeMs));
  const retryPenalty = Math.min(220, retries * 45);
  const hintPenalty = Math.min(120, hintsUsed * 55);
  const extraPenalty = Math.round(validation.extraRatio * 160);

  const points = Math.max(
    120,
    Math.round(
      completion * 700 +
        accuracy * 220 +
        timeRatio * 160 +
        streak * 28 -
        retryPenalty -
        hintPenalty -
        extraPenalty,
    ),
  );

  const stars = starRating({
    completion,
    accuracy,
    extraRatio: validation.extraRatio,
    retries,
    hintsUsed,
    timeRatio,
  });

  return { points, stars, accuracy, timeMs: elapsedMs };
}

export function starRating(args: {
  completion: number;
  accuracy: number;
  extraRatio: number;
  retries: number;
  hintsUsed: number;
  timeRatio: number;
}): StarRating {
  const { completion, accuracy, extraRatio, retries, hintsUsed } = args;

  const nearPerfect =
    completion >= 0.94 &&
    accuracy >= 0.9 &&
    extraRatio <= 0.14 &&
    retries <= 1 &&
    hintsUsed === 0;

  const strong =
    completion >= 0.86 && accuracy >= 0.8 && extraRatio <= 0.28 && retries <= 3;

  if (nearPerfect) return 3;
  if (strong) return 2;
  return 1;
}
