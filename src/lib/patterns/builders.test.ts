import { describe, expect, it } from "vitest";
import { capsuleH, enclosure, loopAround, moolaiSiluvai } from "./builders";
import { choosePulli, expandPath } from "@/lib/game/geometry";
import { buildLattice, hasLatticeEdge } from "@/lib/game/graph";

describe("kambi enclosure", () => {
  it("treats a 1×1 enclosure as a loop around one pulli", () => {
    expect(enclosure(1, 1, 1, 1)).toEqual(loopAround({ x: 1, y: 1 }));
  });

  it("makes a horizontal capsule with straight runs, not a chain of circles", () => {
    const points = capsuleH(0, 1, 2);
    const expanded = expandPath(points, true);
    const sequence = [...expanded, expanded[0]!];
    let straightRuns = 0;
    for (let i = 0; i < sequence.length - 1; i += 1) {
      if (!choosePulli(sequence[i]!, sequence[i + 1]!)) straightRuns += 1;
    }
    expect(straightRuns).toBeGreaterThanOrEqual(4);
  });

  it("keeps the classic 3×3 moolai siluvai on the lattice", () => {
    const lattice = buildLattice(3);
    const paths = moolaiSiluvai(3);
    expect(paths).toHaveLength(6);
    for (const points of paths) {
      const expanded = expandPath(points, true);
      const sequence = [...expanded, expanded[0]!];
      for (let i = 0; i < sequence.length - 1; i += 1) {
        expect(hasLatticeEdge(lattice, sequence[i]!, sequence[i + 1]!)).toBe(true);
      }
    }
  });
});
