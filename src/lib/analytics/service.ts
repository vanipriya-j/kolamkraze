export type AnalyticsProps = Record<string, string | number | boolean | undefined>;

export type AnalyticsEventName =
  | "game_opened"
  | "venue_opened"
  | "mode_selected"
  | "level_started"
  | "level_completed"
  | "level_failed"
  | "hint_used"
  | "daily_kolam_started"
  | "irl_opened"
  | "irl_marked_complete"
  | "reward_clicked"
  | "commerce_clicked";

export type AnalyticsEvent = {
  name: AnalyticsEventName;
  props?: AnalyticsProps;
  at?: number;
};

export interface AnalyticsSink {
  track(event: AnalyticsEvent): void;
}

export class ConsoleAnalyticsSink implements AnalyticsSink {
  track(event: AnalyticsEvent): void {
    if (typeof console === "undefined") return;
    console.info("[analytics]", event.name, event.props ?? {});
  }
}

export class MemoryAnalyticsSink implements AnalyticsSink {
  readonly events: AnalyticsEvent[] = [];

  track(event: AnalyticsEvent): void {
    this.events.push({ ...event, at: event.at ?? Date.now() });
  }
}

export class LocalLogAnalyticsSink implements AnalyticsSink {
  constructor(private readonly key = "aarla.kolam-kraze.analytics") {}

  track(event: AnalyticsEvent): void {
    if (typeof window === "undefined") return;
    const next = { ...event, at: event.at ?? Date.now() };
    try {
      const existing = window.localStorage.getItem(this.key);
      const parsed: AnalyticsEvent[] = existing ? JSON.parse(existing) : [];
      parsed.push(next);
      window.localStorage.setItem(this.key, JSON.stringify(parsed.slice(-200)));
    } catch {
      // Ignore quota / private mode failures.
    }
  }
}

class AnalyticsService {
  constructor(private sinks: AnalyticsSink[]) {}

  addSink(sink: AnalyticsSink) {
    this.sinks.push(sink);
  }

  track(name: AnalyticsEventName, props?: AnalyticsProps) {
    const event: AnalyticsEvent = { name, props, at: Date.now() };
    for (const sink of this.sinks) sink.track(event);
  }
}

const defaultSinks: AnalyticsSink[] =
  process.env.NODE_ENV === "test"
    ? []
    : [new ConsoleAnalyticsSink(), new LocalLogAnalyticsSink()];

export const analytics = new AnalyticsService(defaultSinks);
