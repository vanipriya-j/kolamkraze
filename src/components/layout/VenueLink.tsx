"use client";

import Link from "next/link";
import type { ComponentProps } from "react";
import { useVenue } from "@/components/providers/VenueProvider";
import { venueHref } from "@/lib/navigation";

type Props = ComponentProps<typeof Link>;

export function VenueLink({ href, ...props }: Props) {
  const venue = useVenue();
  const nextHref = typeof href === "string" ? venueHref(href, venue?.id) : href;
  return <Link href={nextHref} {...props} />;
}
