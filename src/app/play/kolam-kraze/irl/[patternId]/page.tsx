import { IrlDetail } from "@/components/screens/IrlScreens";

export default async function IrlPatternPage({
  params,
}: {
  params: Promise<{ patternId: string }>;
}) {
  const { patternId } = await params;
  return <IrlDetail patternId={patternId} />;
}
