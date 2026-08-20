"use client";

import { createContext, useContext, useMemo, type ReactNode } from "react";
import { useSearchParams } from "next/navigation";
import { getVenueById, type VenueConfig } from "@/lib/venues/catalog";

const VenueContext = createContext<VenueConfig | undefined>(undefined);

export function VenueProvider({ children }: { children: ReactNode }) {
  const params = useSearchParams();
  const venue = useMemo(() => getVenueById(params.get("venue")), [params]);
  return <VenueContext.Provider value={venue}>{children}</VenueContext.Provider>;
}

export function useVenue() {
  return useContext(VenueContext);
}
