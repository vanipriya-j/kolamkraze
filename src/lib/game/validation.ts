import { edgeKey, expectedEdgeKeys, nodeId } from "./geometry";
import type { DrawnSegment, KolamPattern, ValidationResult } from "./types";

const PASS_COMPLETION = 0.72;

export function playerEdgeKeys(segments: DrawnSegment[]): Set<string> {
  const keys = new Set<string>();
  for (const segment of segments) {
    if (nodeId(segment.from) === nodeId(segment.to)) continue;
    keys.add(edgeKey(segment.from, segment.to));
  }
  return keys;
}

export function validatePattern(
  pattern: KolamPattern,
  segments: DrawnSegment[],
): ValidationResult {
  const expected = expectedEdgeKeys(pattern);
  const drawn = playerEdgeKeys(segments);

  let matched = 0;
  for (const key of expected) {
    if (drawn.has(key)) matched += 1;
  }

  const extra = [...drawn].filter((key) => !expected.has(key)).length;
  const expectedCount = expected.size || 1;
  const completion = matched / expectedCount;
  const extraRatio = extra / expectedCount;
  const precision = drawn.size === 0 ? 0 : matched / drawn.size;
  const recall = completion;
  const accuracy =
    precision + recall === 0 ? 0 : (2 * precision * recall) / (precision + recall);

  return {
    completion,
    extraRatio,
    accuracy,
    matchedEdges: matched,
    expectedEdges: expected.size,
    extraEdges: extra,
    passed: completion >= PASS_COMPLETION,
  };
}

export function remainingEdgeKeys(
  pattern: KolamPattern,
  segments: DrawnSegment[],
): Set<string> {
  const expected = expectedEdgeKeys(pattern);
  const drawn = playerEdgeKeys(segments);
  const remaining = new Set<string>();
  for (const key of expected) {
    if (!drawn.has(key)) remaining.add(key);
  }
  return remaining;
}

export const VALIDATION_PASS_THRESHOLD = PASS_COMPLETION;
