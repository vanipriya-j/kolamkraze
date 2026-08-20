import type { Coord, KolamPath, KolamPattern, PatternCategory } from "@/lib/game/types";
import { expectedEdgeKeys, snapCoord } from "@/lib/game/geometry";

function N(x: number, y: number): Coord {
  return { x, y: y - 0.5 };
}
function E(x: number, y: number): Coord {
  return { x: x + 0.5, y };
}
function S(x: number, y: number): Coord {
  return { x, y: y + 0.5 };
}
function W(x: number, y: number): Coord {
  return { x: x - 0.5, y };
}

function uniqueConsecutive(points: Coord[]): Coord[] {
  const out: Coord[] = [];
  for (const point of points) {
    const snapped = snapCoord(point);
    const prev = out[out.length - 1];
    if (prev && prev.x === snapped.x && prev.y === snapped.y) continue;
    out.push(snapped);
  }
  if (out.length > 1 && out[0]!.x === out[out.length - 1]!.x && out[0]!.y === out[out.length - 1]!.y) {
    out.pop();
  }
  return out;
}

/** Rounded enclosure around a block of pullis. A 1×1 is a loop; a 1×n is a capsule. */
export function enclosure(x0: number, y0: number, x1: number, y1: number): Coord[] {
  const minX = Math.min(x0, x1);
  const maxX = Math.max(x0, x1);
  const minY = Math.min(y0, y1);
  const maxY = Math.max(y0, y1);
  const pts: Coord[] = [W(minX, minY)];
  for (let x = minX; x <= maxX; x += 1) pts.push(N(x, minY));
  pts.push(E(maxX, minY));
  for (let y = minY + 1; y <= maxY; y += 1) pts.push(E(maxX, y));
  pts.push(S(maxX, maxY));
  for (let x = maxX - 1; x >= minX; x -= 1) pts.push(S(x, maxY));
  pts.push(W(minX, maxY));
  for (let y = maxY - 1; y > minY; y -= 1) pts.push(W(minX, y));
  return uniqueConsecutive(pts);
}

export function loopAround(pulli: Coord): Coord[] {
  return enclosure(pulli.x, pulli.y, pulli.x, pulli.y);
}

export function capsuleH(x0: number, y: number, x1: number): Coord[] {
  return enclosure(x0, y, x1, y);
}

export function capsuleV(x: number, y0: number, y1: number): Coord[] {
  return enclosure(x, y0, x, y1);
}

export function figureEightHorizontal(left: Coord): Coord[] {
  const right = { x: left.x + 1, y: left.y };
  return [
    N(left.x, left.y),
    E(left.x, left.y),
    N(right.x, right.y),
    E(right.x, right.y),
    S(right.x, right.y),
    W(right.x, right.y),
    S(left.x, left.y),
    W(left.x, left.y),
  ];
}

export function figureEightVertical(top: Coord): Coord[] {
  const bottom = { x: top.x, y: top.y + 1 };
  return [
    N(top.x, top.y),
    E(top.x, top.y),
    S(top.x, top.y),
    E(bottom.x, bottom.y),
    S(bottom.x, bottom.y),
    W(bottom.x, bottom.y),
    N(bottom.x, bottom.y),
    W(top.x, top.y),
  ];
}

export function cornerLoops(size: number): Coord[][] {
  const last = size - 1;
  return [
    loopAround({ x: 0, y: 0 }),
    loopAround({ x: last, y: 0 }),
    loopAround({ x: last, y: last }),
    loopAround({ x: 0, y: last }),
  ];
}

/** The classic 3×3: four corner loops + a plus of two capsules. */
export function moolaiSiluvai(size = 3): Coord[][] {
  const mid = (size - 1) / 2;
  const last = size - 1;
  return [
    ...cornerLoops(size),
    capsuleH(0, mid, last),
    capsuleV(mid, 0, last),
  ];
}

export function closedPath(id: string, points: Coord[]): KolamPath {
  return { id, points, closed: true };
}

export function pattern(args: {
  id: string;
  name: string;
  gridSize: number;
  category: PatternCategory;
  difficulty: number;
  tags?: string[];
  previewDuration?: number;
  paths: KolamPath[];
}): KolamPattern {
  const edges = expectedEdgeKeys({
    ...args,
    paths: args.paths,
  } as KolamPattern);
  const parTimeSec = Math.round(4.5 + edges.size * 1.05 + args.difficulty * 0.8);
  return {
    ...args,
    parTimeSec,
    tags: args.tags ?? [],
  };
}

export { N, E, S, W, enclosure as outerBorder };
