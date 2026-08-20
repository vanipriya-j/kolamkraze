import { KolamView } from "@/components/game/KolamView";
import { getPatternById } from "@/lib/patterns/catalog";

export function SplashKolam() {
  const pattern = getPatternById("bindu") ?? getPatternById("kuttu");
  if (!pattern) return null;
  return <KolamView pattern={pattern} showReference ghostOpacity={0.9} />;
}
