"use client";

import { Button } from "@/components/ui/Button";
import { IconButton } from "@/components/ui/IconButton";

type Props = {
  onUndo: () => void;
  onClear: () => void;
  onHint?: () => void;
  onCheck: () => void;
  hintDisabled?: boolean;
  hintAvailable?: boolean;
  canUndo: boolean;
  progressLabel: string;
};

export function GameToolbar({
  onUndo,
  onClear,
  onHint,
  onCheck,
  hintDisabled,
  hintAvailable,
  canUndo,
  progressLabel,
}: Props) {
  return (
    <div className="flex items-center justify-between gap-2 px-1">
      <div className="flex items-center gap-1">
        <IconButton label="Undo" onClick={onUndo} disabled={!canUndo}>
          Undo
        </IconButton>
        <IconButton label="Clear" onClick={onClear} disabled={!canUndo}>
          Clear
        </IconButton>
        {hintAvailable && (
          <IconButton label="Hint" onClick={onHint} disabled={hintDisabled}>
            Hint
          </IconButton>
        )}
      </div>
      <p className="text-[12px] uppercase tracking-[0.18em] text-charcoal/45">{progressLabel}</p>
      <Button onClick={onCheck} className="min-h-11 px-5 text-[14px]">
        Check
      </Button>
    </div>
  );
}
