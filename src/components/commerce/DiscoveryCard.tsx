"use client";

import { analytics } from "@/lib/analytics/service";
import { commerce } from "@/lib/config/copy";
import type { RewardConfig } from "@/lib/venues/catalog";

export function DiscoveryCard({
  reward,
  className = "",
}: {
  reward?: RewardConfig;
  className?: string;
}) {
  const title = reward?.title ?? commerce.cardTitle;
  const body = reward?.body ?? commerce.cardBody;
  const label = reward?.ctaLabel ?? commerce.exploreLabel;
  const href = reward?.ctaHref ?? commerce.exploreUrl;

  return (
    <aside className={`rounded-3xl border border-charcoal/10 bg-ivory-deep/60 px-5 py-5 ${className}`}>
      <p className="font-display text-2xl text-charcoal">{title}</p>
      <p className="mt-2 text-[15px] leading-relaxed text-charcoal/70">{body}</p>
      {href && (
        <a
          href={href}
          target="_blank"
          rel="noreferrer"
          onClick={() =>
            analytics.track(href.includes("instagram") || href.includes("aarla") ? "commerce_clicked" : "reward_clicked", {
              href,
            })
          }
          className="mt-4 inline-flex min-h-11 items-center text-[14px] tracking-wide text-earth"
        >
          {label} →
        </a>
      )}
    </aside>
  );
}
