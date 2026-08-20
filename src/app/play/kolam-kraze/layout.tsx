import { Suspense, type ReactNode } from "react";
import { AppProviders } from "@/components/providers/AppProviders";

export default function KolamLayout({ children }: { children: ReactNode }) {
  return (
    <Suspense fallback={<div className="min-h-[100dvh] bg-ivory" />}>
      <AppProviders>{children}</AppProviders>
    </Suspense>
  );
}
