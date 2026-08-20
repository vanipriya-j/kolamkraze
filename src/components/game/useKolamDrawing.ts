"use client";

import { useCallback, useMemo, useState } from "react";
import { buildLattice, neighborsOf } from "@/lib/game/graph";
import { dist, edgeKey, expectedEdgeKeys, nearestNode, nodeId, projectOnSegment } from "@/lib/game/geometry";
import type { Coord, DrawnSegment, KolamPattern } from "@/lib/game/types";

const SNAP_NODE = 0.34;
const SNAP_PATH = 0.22;

export function useKolamDrawing(pattern: KolamPattern, enabled: boolean) {
  const lattice = useMemo(() => buildLattice(pattern.gridSize), [pattern.gridSize]);
  const expected = useMemo(() => expectedEdgeKeys(pattern), [pattern]);
  const [segments, setSegments] = useState<DrawnSegment[]>([]);
  const [current, setCurrent] = useState<Coord | null>(null);
  const [pointer, setPointer] = useState<Coord | null>(null);

  const nodes = useMemo(() => [...lattice.nodes.values()], [lattice]);

  const reset = useCallback(() => {
    setSegments([]);
    setCurrent(null);
    setPointer(null);
  }, []);

  const undo = useCallback(() => {
    setSegments((currentSegments) => currentSegments.slice(0, -1));
    setCurrent(null);
    setPointer(null);
  }, []);

  const trySnap = useCallback(
    (from: Coord, point: Coord): Coord | null => {
      const neighbors = neighborsOf(lattice, nodeId(from));
      let best: { node: Coord; score: number } | null = null;
      for (const neighbor of neighbors) {
        const expectedBonus = expected.has(edgeKey(from, neighbor)) ? -0.12 : 0;
        const toNode = dist(point, neighbor) + expectedBonus;
        const along = projectOnSegment(point, from, neighbor);
        const pathScore =
          along.t > 0.42 && along.dist < SNAP_PATH ? along.dist + expectedBonus - along.t * 0.08 : 99;
        const score = Math.min(toNode, pathScore);
        if (score < (best?.score ?? SNAP_NODE)) {
          best = { node: neighbor, score };
        }
      }
      return best && best.score < SNAP_NODE ? best.node : null;
    },
    [expected, lattice],
  );

  const onPointerDown = useCallback(
    (point: Coord) => {
      if (!enabled) return;
      const start = nearestNode(point, nodes, SNAP_NODE);
      if (!start) return;
      setCurrent(start);
      setPointer(point);
    },
    [enabled, nodes],
  );

  const onPointerMove = useCallback(
    (point: Coord): DrawnSegment | null => {
      if (!enabled || !current) {
        setPointer(point);
        return null;
      }
      setPointer(point);
      const snapped = trySnap(current, point);
      if (!snapped || nodeId(snapped) === nodeId(current)) return null;
      const segment = { from: current, to: snapped };
      setSegments((currentSegments) => [...currentSegments, segment]);
      setCurrent(snapped);
      return segment;
    },
    [current, enabled, trySnap],
  );

  const onPointerUp = useCallback(() => {
    setCurrent(null);
    setPointer(null);
  }, []);

  return {
    segments,
    current,
    pointer,
    reset,
    undo,
    onPointerDown,
    onPointerMove,
    onPointerUp,
    setSegments,
  };
}
