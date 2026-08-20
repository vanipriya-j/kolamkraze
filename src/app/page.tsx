import { copy } from "@/lib/config/copy";
import Link from "next/link";
import { SplashKolam } from "@/components/brand/SplashKolam";

export default async function SplashPage({
  searchParams,
}: {
  searchParams: Promise<{ venue?: string }>;
}) {
  const { venue } = await searchParams;
  const href = venue ? `/play/kolam-kraze?venue=${encodeURIComponent(venue)}` : "/play/kolam-kraze";

  return (
    <main className="flex min-h-[100dvh] flex-col justify-between px-8 py-12">
      <p className="text-[12px] uppercase tracking-[0.28em] text-charcoal/45">{copy.brand}</p>
      <div>
        <div className="mx-auto h-40 w-40">
          <SplashKolam />
        </div>
        <h1 className="mt-10 font-display text-6xl leading-[0.9] text-charcoal">{copy.game}</h1>
        <p className="mt-4 text-lg text-charcoal/65">{copy.tagline}</p>
      </div>
      <div>
        <Link
          href={href}
          className="inline-flex min-h-12 w-full items-center justify-center rounded-full bg-charcoal text-[15px] tracking-wide text-ivory"
        >
          {copy.play}
        </Link>
        <p className="mt-6 text-center text-[13px] text-charcoal/40">{copy.philosophy}</p>
      </div>
    </main>
  );
}
