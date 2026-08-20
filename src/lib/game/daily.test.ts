import { describe, expect, it } from "vitest";
import { dateKey, getDailyPattern, hashString } from "./daily";
import { listPatterns } from "@/lib/patterns/catalog";

describe("daily pattern calculation", () => {
  const catalog = listPatterns();

  it("is deterministic for a given date", () => {
    const date = new Date("2026-08-20T09:00:00");
    const a = getDailyPattern(catalog, date);
    const b = getDailyPattern(catalog, new Date("2026-08-20T21:15:00"));
    expect(a.id).toBe(b.id);
    expect(dateKey(date)).toBe("2026-08-20");
  });

  it("can select different patterns on different days", () => {
    const ids = new Set(
      [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10].map((offset) =>
        getDailyPattern(catalog, new Date(Date.UTC(2026, 7, 20 + offset))).id,
      ),
    );
    expect(ids.size).toBeGreaterThan(1);
  });

  it("hashes stably", () => {
    expect(hashString("kolam-kraze:2026-08-20")).toBe(hashString("kolam-kraze:2026-08-20"));
  });
});
