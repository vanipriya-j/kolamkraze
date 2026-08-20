type OscillatorKind = OscillatorType;

function canPlay(): boolean {
  return typeof window !== "undefined" && typeof AudioContext !== "undefined";
}

let sharedContext: AudioContext | null = null;

function context(): AudioContext | null {
  if (!canPlay()) return null;
  if (!sharedContext) sharedContext = new AudioContext();
  return sharedContext;
}

function tone(
  frequency: number,
  durationMs: number,
  type: OscillatorKind = "sine",
  gainValue = 0.035,
  delayMs = 0,
) {
  const ctx = context();
  if (!ctx) return;
  const start = ctx.currentTime + delayMs / 1000;
  const oscillator = ctx.createOscillator();
  const gain = ctx.createGain();
  oscillator.type = type;
  oscillator.frequency.setValueAtTime(frequency, start);
  gain.gain.setValueAtTime(0.0001, start);
  gain.gain.exponentialRampToValueAtTime(gainValue, start + 0.012);
  gain.gain.exponentialRampToValueAtTime(0.0001, start + durationMs / 1000);
  oscillator.connect(gain);
  gain.connect(ctx.destination);
  oscillator.start(start);
  oscillator.stop(start + durationMs / 1000 + 0.02);
}

export const sounds = {
  resume() {
    const ctx = context();
    if (ctx?.state === "suspended") void ctx.resume();
  },
  snap(muted: boolean) {
    if (muted) return;
    tone(430, 55, "sine", 0.028);
  },
  complete(muted: boolean) {
    if (muted) return;
    tone(492, 140, "sine", 0.03);
    tone(656, 180, "sine", 0.026, 110);
  },
  error(muted: boolean) {
    if (muted) return;
    tone(196, 120, "triangle", 0.02);
  },
  hint(muted: boolean) {
    if (muted) return;
    tone(388, 90, "sine", 0.02);
  },
};
