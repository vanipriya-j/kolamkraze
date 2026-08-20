import type { MetadataRoute } from "next";

export default function manifest(): MetadataRoute.Manifest {
  return {
    name: "Kolam Kraze",
    short_name: "Kolam Kraze",
    description: "See it. Remember it. Draw it.",
    start_url: "/play/kolam-kraze",
    scope: "/",
    display: "standalone",
    background_color: "#F4EFE6",
    theme_color: "#F4EFE6",
    lang: "en",
    icons: [
      {
        src: "/icons/icon-192.png",
        sizes: "192x192",
        type: "image/png",
        purpose: "any",
      },
      {
        src: "/icons/icon-512.png",
        sizes: "512x512",
        type: "image/png",
        purpose: "maskable",
      },
      {
        src: "/icons/icon.svg",
        sizes: "any",
        type: "image/svg+xml",
      },
    ],
  };
}
