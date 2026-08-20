export type WeeklyChallengeConfig = {
  id: string;
  title: string;
  featuredPatternId: string;
  startDate: string;
  endDate: string;
  sponsor?: string;
  partner?: string;
  prizeText?: string;
  instagramHashtag?: string;
  partnerLogo?: string;
  ctaLabel: string;
  ctaHref: string;
};

export const weeklyChallenge: WeeklyChallengeConfig = {
  id: "week-2026-w34",
  title: "Monsoon Loops",
  featuredPatternId: "malar",
  startDate: "2026-08-17",
  endDate: "2026-08-24",
  sponsor: "Aarla",
  partner: "Aarla Play",
  prizeText: "An Aarla Kolam Hamper",
  instagramHashtag: "#KolamKraze",
  ctaLabel: "Play this week's Kolam",
  ctaHref: "/play/kolam-kraze/game?pattern=malar&mode=memory",
};

export function isWeeklyChallengeActive(
  config: WeeklyChallengeConfig = weeklyChallenge,
  date = new Date(),
): boolean {
  const start = new Date(`${config.startDate}T00:00:00`);
  const end = new Date(`${config.endDate}T23:59:59`);
  return date >= start && date <= end;
}
