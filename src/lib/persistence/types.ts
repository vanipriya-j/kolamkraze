import type { GameMode, StarRating } from "@/lib/game/types";

export type ContinueState = {
  patternId: string;
  mode: GameMode;
};

export type DailyRecord = {
  patternId: string;
  stars: StarRating;
  completedAt: string;
};

export type ProgressState = {
  version: 1;
  stars: Record<string, StarRating>;
  bestTimeMs: Record<string, number>;
  unlocked: string[];
  completed: string[];
  daily: Record<string, DailyRecord>;
  irl: string[];
  muted: boolean;
  streak: number;
  lastPlayDate?: string;
  digitalCompletions: number;
  irlCompletions: number;
  continue?: ContinueState;
};

export interface ProgressRepository {
  load(): ProgressState;
  save(state: ProgressState): void;
}

export const STORAGE_KEY = "aarla.kolam-kraze.v1";
