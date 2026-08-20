import { createDefaultProgress, mergeProgress } from "./defaults";
import { STORAGE_KEY, type ProgressRepository, type ProgressState } from "./types";

function canUseStorage(): boolean {
  return typeof window !== "undefined" && typeof window.localStorage !== "undefined";
}

export class LocalProgressRepository implements ProgressRepository {
  constructor(private readonly key = STORAGE_KEY) {}

  load(): ProgressState {
    if (!canUseStorage()) return createDefaultProgress();
    try {
      const raw = window.localStorage.getItem(this.key);
      if (!raw) return createDefaultProgress();
      return mergeProgress(JSON.parse(raw));
    } catch {
      return createDefaultProgress();
    }
  }

  save(state: ProgressState): void {
    if (!canUseStorage()) return;
    window.localStorage.setItem(this.key, JSON.stringify(state));
  }
}

export class MemoryProgressRepository implements ProgressRepository {
  constructor(private state: ProgressState = createDefaultProgress()) {}

  load(): ProgressState {
    return this.state;
  }

  save(state: ProgressState): void {
    this.state = state;
  }
}
