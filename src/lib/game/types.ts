export type Coord = {
  x: number;
  y: number;
};

export type PathPoint = Coord;

export type KolamPath = {
  id: string;
  points: PathPoint[];
  closed?: boolean;
};

export type PatternCategory = "beginner" | "easy" | "intermediate" | "advanced";

export type KolamPattern = {
  id: string;
  name: string;
  difficulty: number;
  gridSize: number;
  previewDuration?: number;
  category: PatternCategory;
  paths: KolamPath[];
  tags?: string[];
  parTimeSec?: number;
};

export type GameMode = "copy" | "memory" | "timed";

export type UndirectedEdge = {
  a: string;
  b: string;
  key: string;
};

export type PatternGraph = {
  nodes: Map<string, Coord>;
  adjacency: Map<string, Set<string>>;
};

export type DrawnSegment = {
  from: Coord;
  to: Coord;
};

export type ValidationResult = {
  completion: number;
  extraRatio: number;
  accuracy: number;
  matchedEdges: number;
  expectedEdges: number;
  extraEdges: number;
  passed: boolean;
};

export type ScoreInput = {
  validation: ValidationResult;
  elapsedMs: number;
  parTimeMs: number;
  retries: number;
  hintsUsed: number;
  streak: number;
};

export type StarRating = 0 | 1 | 2 | 3;

export type ScoreResult = {
  points: number;
  stars: StarRating;
  accuracy: number;
  timeMs: number;
};

export type TimedSummary = {
  completed: number;
  averageAccuracy: number;
  streak: number;
  totalScore: number;
  remainingMs: number;
};

export type GameResult = {
  patternId: string;
  mode: GameMode;
  stars: StarRating;
  points: number;
  accuracy: number;
  timeMs: number;
  retries: number;
  hintsUsed: number;
  passed: boolean;
  completion: number;
  venueId?: string;
  timedSummary?: TimedSummary;
};
