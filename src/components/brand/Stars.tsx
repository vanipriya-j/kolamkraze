"use client";

import type { StarRating } from "@/lib/game/types";

export function Stars({ value, size = "md" }: { value: StarRating | number; size?: "sm" | "md" }) {
  const count = Math.max(0, Math.min(3, value));
  const cls = size === "sm" ? "text-[13px] gap-0.5" : "text-lg gap-1.5";
  return (
    <div className={`flex ${cls}`} aria-label={`${count} of 3 stars`}>
      {[1, 2, 3].map((star) => (
        <span key={star} className={star <= count ? "text-earth" : "text-charcoal/18"}>
          ★
        </span>
      ))}
    </div>
  );
}
