export type VenueTheme = {
  accent?: string;
  background?: string;
};

export type RewardConfig = {
  title: string;
  body: string;
  ctaLabel?: string;
  ctaHref?: string;
};

export type VenueConfig = {
  id: string;
  name: string;
  subtitle?: string;
  logo?: string;
  theme?: VenueTheme;
  featuredPatternIds?: string[];
  reward?: RewardConfig;
  message?: string;
};

export const VENUES: VenueConfig[] = [
  {
    id: "aarla-studio",
    name: "Aarla Studio",
    subtitle: "Where the patterns begin",
    theme: { accent: "#8C6A4F" },
    featuredPatternIds: ["bindu", "malar"],
    message: "A few minutes between things. Draw one loop, then step back into the day.",
    reward: {
      title: "Loved this Kolam?",
      body: "Explore the Kolam collection at Aarla.",
      ctaLabel: "Explore Aarla",
      ctaHref: "https://www.instagram.com/aarla.culture/",
    },
  },
  {
    id: "sabha-demo",
    name: "Sabha Demo",
    subtitle: "Between kutcheris",
    theme: { accent: "#6E4E3A" },
    featuredPatternIds: ["irani", "nested"],
    message: "A few minutes to spare? Play a Kolam before the next piece begins.",
    reward: {
      title: "Complete this challenge",
      body: "Show your result at the counter for a festival postcard.",
      ctaLabel: "View details",
    },
  },
  {
    id: "clinic-demo",
    name: "Clinic Demo",
    subtitle: "A quiet wait",
    theme: { accent: "#7A6A58" },
    featuredPatternIds: ["bindu", "kuttu"],
    message: "A few minutes to spare? A small kolam, then back to waiting in peace.",
    reward: {
      title: "A calm pause",
      body: "No appointment needed for this one. Just a few loops.",
    },
  },
  {
    id: "cafe-demo",
    name: "Café Demo",
    subtitle: "While the filter coffee settles",
    theme: { accent: "#9C5A3C" },
    featuredPatternIds: ["malar-mini", "maala"],
    message: "A few minutes to spare? Play a Kolam with your coffee.",
    reward: {
      title: "Complete this challenge and show your result at the counter.",
      body: "Ask for the Aarla pour-over when you show a three-star kolam.",
      ctaLabel: "I’m ready",
    },
  },
];

const ALIASES: Record<string, string> = {
  "music-academy": "sabha-demo",
};

export function getVenueById(id: string | null | undefined): VenueConfig | undefined {
  if (!id) return undefined;
  const resolved = ALIASES[id] ?? id;
  return VENUES.find((venue) => venue.id === resolved);
}
