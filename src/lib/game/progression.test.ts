import { describe, expect, it } from "vitest";
import { isUnlocked, recordCompletion, nextPlayablePattern } from "./progression";
import { listPatterns } from "@/lib/patterns/catalog";
import { createDefaultProgress } from "@/lib/persistence/defaults";

describe("level unlocking", () => {
  const catalog = listPatterns();

  it("unlocks the first three patterns by default", () => {
    const state = createDefaultProgress();
    expect(isUnlocked(catalog[0]!, catalog, state)).toBe(true);
    expect(isUnlocked(catalog[1]!, catalog, state)).toBe(true);
    expect(isUnlocked(catalog[2]!, catalog, state)).toBe(true);
    expect(isUnlocked(catalog[3]!, catalog, state)).toBe(false);
  });

  it("unlocks the next pattern after a completion", () => {
    const afterFirst = recordCompletion(createDefaultProgress(), {
      patternId: catalog[2]!.id,
      stars: 2,
      timeMs: 8000,
      catalog,
    });
    expect(afterFirst.completed).toContain(catalog[2]!.id);
    expect(isUnlocked(catalog[3]!, catalog, afterFirst)).toBe(true);
    expect(afterFirst.stars[catalog[2]!.id]).toBe(2);
  });

  it("keeps the best star rating", () => {
    const once = recordCompletion(createDefaultProgress(), {
      patternId: catalog[0]!.id,
      stars: 1,
      timeMs: 9000,
      catalog,
    });
    const twice = recordCompletion(once, {
      patternId: catalog[0]!.id,
      stars: 3,
      timeMs: 4000,
      catalog,
    });
    expect(twice.stars[catalog[0]!.id]).toBe(3);
    expect(twice.bestTimeMs[catalog[0]!.id]).toBe(4000);
  });

  it("points continue at the next unfinished pattern", () => {
    let state = createDefaultProgress();
    state = recordCompletion(state, {
      patternId: catalog[0]!.id,
      stars: 3,
      timeMs: 3000,
      catalog,
    });
    const next = nextPlayablePattern(catalog, state);
    expect(next?.id).toBe(catalog[1]!.id);
  });
});
