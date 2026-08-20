export function IrlBadge({ compact = false }: { compact?: boolean }) {
  return (
    <span className="inline-flex items-center rounded-full border border-earth/40 px-3 py-1 text-[11px] uppercase tracking-[0.18em] text-earth">
      {compact ? "IRL" : "Made IRL"}
    </span>
  );
}
