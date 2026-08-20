import { describe, expect, it } from "vitest";
import { getPatternById } from "@/lib/patterns/catalog";
import { expectedEdgeKeys, parseNodeId } from "@/lib/game/geometry";
import { validatePattern, VALIDATION_PASS_THRESHOLD } from "./validation";
import type { DrawnSegment } from "./types";

function segmentsFromPattern(id: string): DrawnSegment[] {
  const pattern = getPatternById(id)!;
  return [...expectedEdgeKeys(pattern)].map((key) => {
    const [a, b] = key.split("|") as [string, string];
    return { from: parseNodeId(a), to: parseNodeId(b) };
  });
}

describe("path validation", () => {
  it("accepts a complete reverse-order tracing of bindu", () => {
    const pattern = getPatternById("bindu")!;
    const result = validatePattern(pattern, segmentsFromPattern("bindu"));
    expect(result.passed).toBe(true);
    expect(result.completion).toBe(1);
    expect(result.extraEdges).toBe(0);
  });

  it("passes a mostly complete drawing within tolerance", () => {
    const pattern = getPatternById("irani")!;
    const segments = segmentsFromPattern("irani").slice(0, -1);
    const result = validatePattern(pattern, segments);
    expect(result.completion).toBeGreaterThan(VALIDATION_PASS_THRESHOLD);
    expect(result.passed).toBe(true);
  });

  it("fails a clearly incomplete drawing", () => {
    const pattern = getPatternById("prakara")!;
    const segments = segmentsFromPattern("prakara").slice(0, 2);
    const result = validatePattern(pattern, segments);
    expect(result.passed).toBe(false);
    expect(result.completion).toBeLessThan(0.5);
  });

  it("counts extra loops without discarding a complete pattern", () => {
    const pattern = getPatternById("bindu")!;
    const extra: DrawnSegment = {
      from: { x: 0.5, y: 0 },
      to: { x: 0, y: -0.5 },
    };
    const result = validatePattern(pattern, [...segmentsFromPattern("bindu"), extra]);
    expect(result.passed).toBe(true);
    expect(result.extraEdges).toBeGreaterThan(0);
    expect(result.accuracy).toBeLessThan(1);
  });
});
