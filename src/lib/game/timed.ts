import type { GameMode } from "@/lib/game/types";
import { dateKey } from "@/lib/game/daily";
import type { ProgressState } from "@/lib/persistence/types";

export function updateStreak(state: ProgressState, now = new Date()): ProgressState {
  const today = dateKey(now);
  if (state.lastPlayDate === today) return state;
  if (!state.lastPlayDate) {
    return { ...state, streak: 1, lastPlayDate: today };
  }
  const prev = new Date(`${state.lastPlayDate}T12:00:00`);
  const diffDays = Math.round((now.getTime() - prev.getTime()) / 86_400_000);
  const streak = diffDays === 1 ? state.streak + 1 : 1;
  return { ...state, streak, lastPlayDate: today };
}

export function timedBonusMs(accuracy: number, streak: number): number {
  const base = 6000;
  const accuracyBonus = Math.round(accuracy * 4000);
  const streakBonus = Math.min(4000, streak * 800);
  return base + accuracyBonus + streakBonus;
}

export const TIMED_START_MS = 120_000;

export const TIMED_MODE: GameMode = "timed";
