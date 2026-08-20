import { describe, expect, it } from "vitest";
import { calculateScore, starRating } from "./scoring";
import type { ValidationResult } from "./types";

const passed: ValidationResult = {
  completion: 1,
  extraRatio: 0,
  accuracy: 1,
  matchedEdges: 8,
  expectedEdges: 8,
  extraEdges: 0,
  passed: true,
};

describe("score calculation", () => {
  it("awards three stars for a clean timely tracing", () => {
    const score = calculateScore({
      validation: passed,
      elapsedMs: 4000,
      parTimeMs: 12000,
      retries: 0,
      hintsUsed: 0,
      streak: 2,
    });
    expect(score.stars).toBe(3);
    expect(score.points).toBeGreaterThan(800);
  });

  it("gives one star for a completed but messy attempt", () => {
    const stars = starRating({
      completion: 0.75,
      accuracy: 0.72,
      extraRatio: 0.4,
      retries: 4,
      hintsUsed: 1,
      timeRatio: 0,
    });
    expect(stars).toBe(1);
  });

  it("returns zero stars when the pattern is not complete enough", () => {
    const score = calculateScore({
      validation: { ...passed, passed: false, completion: 0.4, accuracy: 0.4 },
      elapsedMs: 1000,
      parTimeMs: 8000,
      retries: 0,
      hintsUsed: 0,
      streak: 0,
    });
    expect(score.stars).toBe(0);
    expect(score.points).toBeLessThan(200);
  });
});
