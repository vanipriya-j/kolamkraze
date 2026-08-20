"use client";

import { useEffect } from "react";

export function RegisterSW() {
  useEffect(() => {
    if (!("serviceWorker" in navigator)) return;
    const register = async () => {
      try {
        await navigator.serviceWorker.register("/sw.js");
      } catch {
        // Offline caching is optional in development.
      }
    };
    void register();
  }, []);
  return null;
}
