import type { GameResult } from "@/lib/game/types";

const RESULT_KEY = "aarla.kolam-kraze.last-result";

export function saveGameResult(result: GameResult) {
  if (typeof window === "undefined") return;
  sessionStorage.setItem(RESULT_KEY, JSON.stringify(result));
}

export function loadGameResult(): GameResult | null {
  if (typeof window === "undefined") return null;
  const raw = sessionStorage.getItem(RESULT_KEY);
  if (!raw) return null;
  try {
    return JSON.parse(raw) as GameResult;
  } catch {
    return null;
  }
}
