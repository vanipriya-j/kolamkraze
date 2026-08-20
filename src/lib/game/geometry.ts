import type { Coord, KolamPath, KolamPattern } from "./types";

export const RING_OFFSETS: Coord[] = [
  { x: 0, y: -0.5 },
  { x: 0.5, y: 0 },
  { x: 0, y: 0.5 },
  { x: -0.5, y: 0 },
];

export function quantize(n: number): number {
  return Math.round(n * 2) / 2;
}

export function snapCoord(c: Coord): Coord {
  return { x: quantize(c.x), y: quantize(c.y) };
}

export function nodeId(c: Coord): string {
  const p = snapCoord(c);
  return `${p.x},${p.y}`;
}

export function parseNodeId(id: string): Coord {
  const [x, y] = id.split(",").map(Number);
  return { x, y };
}

export function sameCoord(a: Coord, b: Coord, epsilon = 0.001): boolean {
  return Math.abs(a.x - b.x) < epsilon && Math.abs(a.y - b.y) < epsilon;
}

export function dist(a: Coord, b: Coord): number {
  const dx = a.x - b.x;
  const dy = a.y - b.y;
  return Math.hypot(dx, dy);
}

export function add(a: Coord, b: Coord): Coord {
  return { x: a.x + b.x, y: a.y + b.y };
}

export function ringPoints(pulli: Coord): Coord[] {
  return RING_OFFSETS.map((offset) => add(pulli, offset));
}

export function ringIndex(pulli: Coord, point: Coord): number | null {
  const snapped = snapCoord(point);
  const dx = quantize(snapped.x - pulli.x);
  const dy = quantize(snapped.y - pulli.y);
  const idx = RING_OFFSETS.findIndex((o) => o.x === dx && o.y === dy);
  return idx === -1 ? null : idx;
}

export function candidatePullis(point: Coord): Coord[] {
  const p = snapCoord(point);
  const candidates: Coord[] = [];
  for (const dx of [-0.5, 0, 0.5]) {
    for (const dy of [-0.5, 0, 0.5]) {
      const pulli = { x: quantize(p.x + dx), y: quantize(p.y + dy) };
      if (!Number.isInteger(pulli.x) || !Number.isInteger(pulli.y)) continue;
      if (ringIndex(pulli, p) !== null) candidates.push(pulli);
    }
  }
  return candidates;
}

export function sharedPullis(a: Coord, b: Coord): Coord[] {
  const pa = candidatePullis(a);
  const pbIds = new Set(candidatePullis(b).map(nodeId));
  return pa.filter((p) => pbIds.has(nodeId(p)));
}

export function choosePulli(a: Coord, b: Coord): Coord | null {
  const shared = sharedPullis(a, b);
  if (shared.length === 0) return null;
  shared.sort((p1, p2) => ringDistance(p1, a, b) - ringDistance(p2, a, b));
  return shared[0] ?? null;
}

export function ringDistance(pulli: Coord, a: Coord, b: Coord): number {
  const ia = ringIndex(pulli, a);
  const ib = ringIndex(pulli, b);
  if (ia === null || ib === null) return Number.POSITIVE_INFINITY;
  const cw = (ib - ia + 4) % 4;
  const ccw = (ia - ib + 4) % 4;
  return Math.min(cw, ccw);
}

export function interpolateRing(a: Coord, b: Coord): Coord[] {
  if (sameCoord(a, b)) return [snapCoord(a)];
  const pulli = choosePulli(a, b);
  if (!pulli) {
    return [snapCoord(a), snapCoord(b)];
  }
  const ia = ringIndex(pulli, a);
  const ib = ringIndex(pulli, b);
  if (ia === null || ib === null) return [snapCoord(a), snapCoord(b)];
  const cw = (ib - ia + 4) % 4;
  const ccw = (ia - ib + 4) % 4;
  const dir = cw <= ccw ? 1 : -1;
  const steps = Math.min(cw, ccw);
  const result: Coord[] = [snapCoord(a)];
  let i = ia;
  for (let s = 0; s < steps; s += 1) {
    i = (i + dir + 4) % 4;
    result.push(add(pulli, RING_OFFSETS[i]!));
  }
  return result;
}

export function expandPath(points: Coord[], closed = false): Coord[] {
  if (points.length === 0) return [];
  const sequence = points.map(snapCoord);
  const pairs = closed ? [...sequence, sequence[0]!] : sequence;
  const out: Coord[] = [];
  for (let i = 0; i < pairs.length - 1; i += 1) {
    const segment = interpolateRing(pairs[i]!, pairs[i + 1]!);
    if (out.length === 0) out.push(...segment);
    else out.push(...segment.slice(1));
  }
  if (closed && out.length > 1 && sameCoord(out[0]!, out[out.length - 1]!)) {
    out.pop();
  }
  return out;
}

export function edgeKey(a: Coord | string, b: Coord | string): string {
  const idA = typeof a === "string" ? a : nodeId(a);
  const idB = typeof b === "string" ? b : nodeId(b);
  return idA < idB ? `${idA}|${idB}` : `${idB}|${idA}`;
}

export function expectedEdgeKeys(pattern: KolamPattern): Set<string> {
  const keys = new Set<string>();
  for (const path of pattern.paths) {
    const expanded = expandPath(path.points, path.closed ?? true);
    if (expanded.length < 2) continue;
    const pts = path.closed ?? true ? [...expanded, expanded[0]!] : expanded;
    for (let i = 0; i < pts.length - 1; i += 1) {
      keys.add(edgeKey(pts[i]!, pts[i + 1]!));
    }
  }
  return keys;
}

export function expandedPaths(pattern: KolamPattern): KolamPath[] {
  return pattern.paths.map((path) => ({
    ...path,
    points: expandPath(path.points, path.closed ?? true),
    closed: path.closed ?? true,
  }));
}

export function sweepFlag(center: Coord, a: Coord, b: Coord): 0 | 1 {
  const ax = a.x - center.x;
  const ay = a.y - center.y;
  const bx = b.x - center.x;
  const by = b.y - center.y;
  const cross = ax * by - ay * bx;
  return cross > 0 ? 1 : 0;
}

export function arcCommand(a: Coord, b: Coord): string {
  const pulli = choosePulli(a, b);
  if (!pulli) return `L ${b.x} ${b.y}`;
  const radius = 0.5;
  const large = ringDistance(pulli, a, b) > 1 ? 1 : 0;
  const sweep = sweepFlag(pulli, a, b);
  return `A ${radius} ${radius} 0 ${large} ${sweep} ${b.x} ${b.y}`;
}

export function pathToD(points: Coord[], closed = true): string {
  const expanded = expandPath(points, closed);
  if (expanded.length === 0) return "";
  const parts = [`M ${expanded[0]!.x} ${expanded[0]!.y}`];
  for (let i = 1; i < expanded.length; i += 1) {
    parts.push(arcCommand(expanded[i - 1]!, expanded[i]!));
  }
  if (closed && expanded.length > 1) {
    parts.push(arcCommand(expanded[expanded.length - 1]!, expanded[0]!));
    parts.push("Z");
  }
  return parts.join(" ");
}

export function segmentsToD(segments: { from: Coord; to: Coord }[]): string {
  return segments
    .map((segment) => `M ${segment.from.x} ${segment.from.y} ${arcCommand(segment.from, segment.to)}`)
    .join(" ");
}

export function viewBoxForGrid(gridSize: number, padding = 0.85): string {
  const min = -padding;
  const size = gridSize - 1 + padding * 2;
  return `${min} ${min} ${size} ${size}`;
}

export function previewDurationFor(pattern: KolamPattern): number {
  if (pattern.previewDuration) return pattern.previewDuration;
  if (pattern.difficulty <= 2) return 8;
  if (pattern.difficulty === 3) return 6;
  return 4;
}

export function parTimeMsFor(pattern: KolamPattern): number {
  if (pattern.parTimeSec) return pattern.parTimeSec * 1000;
  const edges = expectedEdgeKeys(pattern).size;
  return Math.round((5 + edges * 1.15) * 1000);
}

export function nearestNode(
  point: Coord,
  nodes: Iterable<Coord>,
  maxDist: number,
): Coord | null {
  let best: Coord | null = null;
  let bestDist = maxDist;
  for (const node of nodes) {
    const d = dist(point, node);
    if (d < bestDist) {
      best = node;
      bestDist = d;
    }
  }
  return best;
}

export function projectOnSegment(point: Coord, a: Coord, b: Coord): { t: number; dist: number } {
  const dx = b.x - a.x;
  const dy = b.y - a.y;
  const len2 = dx * dx + dy * dy;
  if (len2 === 0) return { t: 0, dist: dist(point, a) };
  const t = Math.max(0, Math.min(1, ((point.x - a.x) * dx + (point.y - a.y) * dy) / len2));
  const proj = { x: a.x + t * dx, y: a.y + t * dy };
  return { t, dist: dist(point, proj) };
}
