"use client";

import { createContext, useContext, useMemo, useSyncExternalStore, type ReactNode } from "react";
import { LocalProgressRepository } from "@/lib/persistence/local-repository";
import { createDefaultProgress } from "@/lib/persistence/defaults";
import type { ProgressState } from "@/lib/persistence/types";

const repository = new LocalProgressRepository();
const emptyProgress = createDefaultProgress();

let state: ProgressState = emptyProgress;
let loaded = false;
const listeners = new Set<() => void>();

function emit() {
  listeners.forEach((listener) => listener());
}

function subscribe(listener: () => void) {
  listeners.add(listener);
  return () => listeners.delete(listener);
}

function getSnapshot(): ProgressState {
  if (!loaded) {
    state = repository.load();
    loaded = true;
  }
  return state;
}

function getServerSnapshot(): ProgressState {
  return emptyProgress;
}

type ProgressContextValue = {
  state: ProgressState;
  update: (updater: (current: ProgressState) => ProgressState) => void;
  reload: () => void;
};

const ProgressContext = createContext<ProgressContextValue | null>(null);

export function ProgressProvider({ children }: { children: ReactNode }) {
  const snapshot = useSyncExternalStore(subscribe, getSnapshot, getServerSnapshot);

  const value = useMemo<ProgressContextValue>(
    () => ({
      state: snapshot,
      update: (updater) => {
        state = updater(getSnapshot());
        repository.save(state);
        emit();
      },
      reload: () => {
        state = repository.load();
        loaded = true;
        emit();
      },
    }),
    [snapshot],
  );

  return <ProgressContext.Provider value={value}>{children}</ProgressContext.Provider>;
}

export function useProgress() {
  const ctx = useContext(ProgressContext);
  if (!ctx) throw new Error("useProgress must be used within ProgressProvider");
  return ctx;
}
