"use client";

import type { PointerEvent, Ref } from "react";
import { pathToD, viewBoxForGrid } from "@/lib/game/geometry";
import type { Coord, DrawnSegment, KolamPattern } from "@/lib/game/types";
import { expandedPaths, segmentsToD } from "@/lib/game/geometry";

type Props = {
  pattern: KolamPattern;
  playerSegments?: DrawnSegment[];
  previewSegments?: DrawnSegment[];
  showReference?: boolean;
  ghostOpacity?: number;
  interactive?: boolean;
  currentPoint?: Coord | null;
  pointerPoint?: Coord | null;
  className?: string;
  onPointerDown?: (point: Coord, event: PointerEvent<SVGSVGElement>) => void;
  onPointerMove?: (point: Coord, event: PointerEvent<SVGSVGElement>) => void;
  onPointerUp?: (point: Coord, event: PointerEvent<SVGSVGElement>) => void;
  svgRef?: Ref<SVGSVGElement>;
  accent?: string;
};

function clientToGrid(svg: SVGSVGElement, event: { clientX: number; clientY: number }): Coord {
  const ctm = svg.getScreenCTM();
  if (!ctm) return { x: 0, y: 0 };
  const point = svg.createSVGPoint();
  point.x = event.clientX;
  point.y = event.clientY;
  const loc = point.matrixTransform(ctm.inverse());
  return { x: loc.x, y: loc.y };
}

export function KolamView({
  pattern,
  playerSegments = [],
  previewSegments = [],
  showReference = false,
  ghostOpacity = 0.22,
  interactive = false,
  currentPoint,
  pointerPoint,
  className = "",
  onPointerDown,
  onPointerMove,
  onPointerUp,
  svgRef,
  accent = "#1F1B16",
}: Props) {
  const paths = expandedPaths(pattern);
  const dots: Coord[] = [];
  for (let y = 0; y < pattern.gridSize; y += 1) {
    for (let x = 0; x < pattern.gridSize; x += 1) dots.push({ x, y });
  }

  const handle = (
    handler: Props["onPointerDown"],
    event: PointerEvent<SVGSVGElement>,
  ) => {
    if (!handler) return;
    const point = clientToGrid(event.currentTarget, event);
    handler(point, event);
  };

  return (
    <svg
      ref={svgRef}
      viewBox={viewBoxForGrid(pattern.gridSize)}
      className={`h-full w-full touch-none select-none ${className}`}
      role="img"
      aria-label={`${pattern.name} kolam`}
      onPointerDown={(event) => {
        if (!interactive) return;
        event.currentTarget.setPointerCapture(event.pointerId);
        handle(onPointerDown, event);
      }}
      onPointerMove={(event) => interactive && handle(onPointerMove, event)}
      onPointerUp={(event) => interactive && handle(onPointerUp, event)}
      onPointerCancel={(event) => interactive && handle(onPointerUp, event)}
    >
      {showReference &&
        paths.map((path) => (
          <path
            key={`ref-${path.id}`}
            d={pathToD(path.points, path.closed)}
            fill="none"
            stroke={accent}
            strokeWidth={0.1}
            strokeLinecap="round"
            strokeLinejoin="round"
            opacity={ghostOpacity}
          />
        ))}
      {previewSegments.length > 0 && (
        <path
          d={segmentsToD(previewSegments)}
          fill="none"
          stroke="#8C6A4F"
          strokeWidth={0.1}
          strokeLinecap="round"
          opacity={0.55}
        />
      )}
      {playerSegments.length > 0 && (
        <path
          d={segmentsToD(playerSegments)}
          fill="none"
          stroke={accent}
          strokeWidth={0.11}
          strokeLinecap="round"
          strokeLinejoin="round"
        />
      )}
      {currentPoint && pointerPoint && (
        <line
          x1={currentPoint.x}
          y1={currentPoint.y}
          x2={pointerPoint.x}
          y2={pointerPoint.y}
          stroke={accent}
          strokeWidth={0.04}
          opacity={0.28}
          strokeLinecap="round"
        />
      )}
      {dots.map((dot) => (
        <circle
          key={`${dot.x}-${dot.y}`}
          cx={dot.x}
          cy={dot.y}
          r={0.065}
          fill={accent}
          opacity={0.42}
        />
      ))}
      {currentPoint && (
        <circle cx={currentPoint.x} cy={currentPoint.y} r={0.09} fill={accent} opacity={0.8} />
      )}
    </svg>
  );
}
