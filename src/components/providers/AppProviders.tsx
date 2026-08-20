"use client";

import { ProgressProvider } from "./ProgressProvider";
import { VenueProvider } from "./VenueProvider";
import type { ReactNode } from "react";

export function AppProviders({ children }: { children: ReactNode }) {
  return (
    <ProgressProvider>
      <VenueProvider>{children}</VenueProvider>
    </ProgressProvider>
  );
}
