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
  return out;
}

export function loopAround(pulli: Coord): Coord[] {
  return [N(pulli.x, pulli.y), E(pulli.x, pulli.y), S(pulli.x, pulli.y), W(pulli.x, pulli.y)];
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

export function outerBorder(x0: number, y0: number, x1: number, y1: number): Coord[] {
  const pts: Coord[] = [];

  for (let x = x0; x <= x1; x += 1) {
    if (x === x0) pts.push(W(x, y0));
    pts.push(N(x, y0));
    pts.push(E(x, y0));
  }

  for (let y = y0; y <= y1; y += 1) {
    pts.push(S(x1, y));
    if (y < y1) pts.push(E(x1, y + 1));
  }

  for (let x = x1; x >= x0; x -= 1) {
    pts.push(W(x, y1));
    if (x > x0) pts.push(S(x - 1, y1));
  }

  for (let y = y1; y >= y0; y -= 1) {
    pts.push(N(x0, y));
    if (y > y0) pts.push(W(x0, y - 1));
  }

  return uniqueConsecutive(pts);
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

export function petals(center: Coord, distance = 1): Coord[][] {
  return [
    loopAround({ x: center.x, y: center.y - distance }),
    loopAround({ x: center.x + distance, y: center.y }),
    loopAround({ x: center.x, y: center.y + distance }),
    loopAround({ x: center.x - distance, y: center.y }),
  ];
}

export { N, E, S, W };
