"use client";

import { IconButton } from "./IconButton";
import { useProgress } from "@/components/providers/ProgressProvider";

export function MuteToggle({ className = "" }: { className?: string }) {
  const { state, update } = useProgress();
  return (
    <IconButton
      label={state.muted ? "Unmute" : "Mute"}
      className={className}
      onClick={() => update((current) => ({ ...current, muted: !current.muted }))}
    >
      {state.muted ? "Sound off" : "Sound on"}
    </IconButton>
  );
}
