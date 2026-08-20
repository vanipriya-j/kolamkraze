import type { KolamPattern } from "./types";

export function dateKey(date: Date = new Date()): string {
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, "0");
  const day = String(date.getDate()).padStart(2, "0");
  return `${year}-${month}-${day}`;
}

export function hashString(value: string): number {
  let hash = 2166136261;
  for (let i = 0; i < value.length; i += 1) {
    hash ^= value.charCodeAt(i);
    hash = Math.imul(hash, 16777619);
  }
  return hash >>> 0;
}

export function getDailyPattern(
  patterns: KolamPattern[],
  date: Date = new Date(),
): KolamPattern {
  if (patterns.length === 0) {
    throw new Error("No kolam patterns available for daily selection.");
  }
  const index = hashString(`kolam-kraze:${dateKey(date)}`) % patterns.length;
  return patterns[index]!;
}
