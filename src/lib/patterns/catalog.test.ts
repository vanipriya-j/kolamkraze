import { describe, expect, it } from "vitest";
import { KOLAM_PATTERNS, getPatternById, listPatterns } from "./catalog";
import { choosePulli, expectedEdgeKeys, expandPath } from "@/lib/game/geometry";
import { buildLattice, hasLatticeEdge } from "@/lib/game/graph";

describe("pattern catalog", () => {
  it("includes at least 20 unique playable kolams", () => {
    const ids = listPatterns().map((pattern) => pattern.id);
    expect(ids.length).toBeGreaterThanOrEqual(20);
    expect(new Set(ids).size).toBe(ids.length);
  });

  it("loads a pattern by id", () => {
    const bindu = getPatternById("bindu");
    expect(bindu?.gridSize).toBe(3);
    expect(bindu?.paths.length).toBeGreaterThan(0);
  });

  it("keeps every expected edge on the pulli lattice", () => {
    for (const pattern of KOLAM_PATTERNS) {
      const lattice = buildLattice(pattern.gridSize);
      const expanded = pattern.paths.flatMap((path) => {
        const points = expandPath(path.points, path.closed ?? true);
        const sequence = path.closed ?? true ? [...points, points[0]!] : points;
        const pairs: Array<[typeof points[0], typeof points[0]]> = [];
        for (let i = 0; i < sequence.length - 1; i += 1) {
          pairs.push([sequence[i]!, sequence[i + 1]!]);
        }
        return pairs;
      });
      for (const [from, to] of expanded) {
        const ring = choosePulli(from, to);
        const onLattice = hasLatticeEdge(lattice, from, to);
        expect(
          onLattice,
          `${pattern.id} missing lattice edge ${from.x},${from.y} -> ${to.x},${to.y}`,
        ).toBe(true);
        if (ring) {
          expect(onLattice).toBe(true);
        }
      }
      expect(expectedEdgeKeys(pattern).size).toBeGreaterThan(0);
    }
  });

  it("covers beginner through advanced grids", () => {
    const sizes = new Set(listPatterns().map((pattern) => pattern.gridSize));
    expect(sizes.has(3)).toBe(true);
    expect(sizes.has(5)).toBe(true);
    expect(sizes.has(7)).toBe(true);
    expect(sizes.has(9)).toBe(true);
  });
});
