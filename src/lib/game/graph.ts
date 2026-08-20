import { add, edgeKey, nodeId, RING_OFFSETS, snapCoord } from "./geometry";
import type { Coord, PatternGraph } from "./types";

function ensureAdj(graph: PatternGraph, id: string) {
  if (!graph.adjacency.has(id)) graph.adjacency.set(id, new Set());
}

export function buildLattice(gridSize: number): PatternGraph {
  const graph: PatternGraph = {
    nodes: new Map(),
    adjacency: new Map(),
  };

  const addNode = (coord: Coord) => {
    const snapped = snapCoord(coord);
    const id = nodeId(snapped);
    graph.nodes.set(id, snapped);
    ensureAdj(graph, id);
    return id;
  };

  const addEdge = (a: Coord, b: Coord) => {
    const idA = addNode(a);
    const idB = addNode(b);
    graph.adjacency.get(idA)!.add(idB);
    graph.adjacency.get(idB)!.add(idA);
  };

  for (let y = 0; y < gridSize; y += 1) {
    for (let x = 0; x < gridSize; x += 1) {
      const pulli = { x, y };
      const ring = RING_OFFSETS.map((offset) => add(pulli, offset));
      for (let i = 0; i < ring.length; i += 1) {
        addEdge(ring[i]!, ring[(i + 1) % ring.length]!);
      }
    }
  }

  return graph;
}

export function neighborsOf(graph: PatternGraph, id: string): Coord[] {
  const ids = graph.adjacency.get(id);
  if (!ids) return [];
  return [...ids].map((nid) => graph.nodes.get(nid)!).filter(Boolean);
}

export function hasLatticeEdge(graph: PatternGraph, a: Coord, b: Coord): boolean {
  const idA = nodeId(a);
  return graph.adjacency.get(idA)?.has(nodeId(b)) ?? false;
}

export { edgeKey, nodeId };
