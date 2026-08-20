# Kolam Kraze

Aarla Play’s first experience: a short-session, mobile-first kolam game.

**See it. Remember it. Draw it.**

Kolam Kraze is a responsive web app / PWA. It is meant to work as a casual game, a QR wait-time game at physical venues, and a bridge from digital play to drawing kolams in the real world.

Play in the spaces between things.

## Local setup

```bash
npm install
npm run dev
```

Open [http://localhost:3000](http://localhost:3000).

Useful scripts:

```bash
npm run lint
npm run typecheck
npm test
npm run build
```

The app is optimized for mobile browsers. On desktop it stays a narrow, editorial column.

Venue QR demo:

```txt
http://localhost:3000/play/kolam-kraze?venue=aarla-studio
http://localhost:3000/play/kolam-kraze?venue=sabha-demo
http://localhost:3000/play/kolam-kraze?venue=clinic-demo
http://localhost:3000/play/kolam-kraze?venue=cafe-demo
```

`?venue=music-academy` aliases to the sabha demo.

## Architecture

```txt
src/
  app/                         Next.js App Router screens + PWA manifest
  components/
    game/                      Board, drawing, copy/memory/timed play
    screens/                   Home, levels, daily, result, IRL
    venue/                     QR venue welcome
    commerce/                  Optional post-play discovery card
    providers/                 Local progress + venue context
  lib/
    game/                      Geometry, lattice graph, validation, scoring
    patterns/                  Data-driven kolam library
    persistence/               Repository abstraction (localStorage now)
    analytics/                 Vendor-agnostic event sinks
    audio/                     Soft Web Audio cues
    venues/                    Venue configuration
    campaigns/                 Weekly challenge configuration
```

Gameplay is data-driven. Screens never hardcode path coordinates. Patterns, venues, weekly campaigns, and commerce links are configuration.

Persistence and analytics sit behind interfaces so a later Supabase/Firebase/GA4/PostHog integration can replace the local implementations without rewriting the game.

## How to add a new kolam

1. Open `src/lib/patterns/catalog.ts`.
2. Add a `pattern({ ... })` entry using the builders in `src/lib/patterns/builders.ts`.
3. Keep coordinates on the pulli lattice: integer dots, with path points at the cardinal midpoints around those dots (`N/E/S/W` at distance 0.5).
4. Prefer the helpers:
   - `loopAround({ x, y })` — one loop around a pulli
   - `figureEightHorizontal(left)` / `figureEightVertical(top)`
   - `outerBorder(x0, y0, x1, y1)` — scalloped sikku border
   - `petals(center)` — four surrounding loops
5. Set `gridSize`, `category`, and `difficulty`. Difficulty should reflect crossings, path count, memory load and turns, not only grid size.
6. Run `npm test` — the catalog test checks that every expected edge sits on the drawing lattice.

Do not edit `GamePlay.tsx` or validation code to add a level.

## How to add a venue config

Edit `src/lib/venues/catalog.ts`:

```ts
{
  id: "my-venue",
  name: "Venue Name",
  subtitle: "Optional line",
  theme: { accent: "#8C6A4F" },
  featuredPatternIds: ["bindu"],
  message: "A few minutes to spare? Play a Kolam.",
  reward: {
    title: "Complete this challenge and show your result at the counter.",
    body: "Optional reward copy",
    ctaLabel: "Explore Aarla",
    ctaHref: "https://www.instagram.com/aarla.culture/",
  },
}
```

Share ` /play/kolam-kraze?venue=my-venue `. The first visit in a session shows the venue welcome, then starts the featured kolam. No registration.

Weekly campaigns live in `src/lib/campaigns/weekly.ts` (title, dates, prize, hashtag, partner, CTA). There is no admin console in V1.

## How game validation works

Players do not freehand. Dots are pullis. Around each pulli is a 4-point ring (north, east, south, west). Adjacent ring points form the drawing lattice. Dragging magnetically snaps from the current node to a neighboring lattice node, with extra pull toward the expected pattern.

Each kolam is a set of those lattice edges.

On **Check**:

- completion = matched expected edges / expected edges
- extra loops are counted but a complete pattern still passes
- pass threshold is about 72%, so small touch inaccuracy is tolerated
- score uses completion, accuracy, time against par, retries, hints, and streak
- stars: completed / strong / near-perfect

Copy mode keeps a ghost of the reference. Memory mode hides it after a short look (with one hint). Timed challenge is ~2 minutes, with time bonuses for each correct kolam.

## Future backend integration points

| Concern | V1 | Later |
| --- | --- | --- |
| Patterns | `src/lib/patterns/catalog.ts` | CMS / `getPatternById()` fetch |
| Daily kolam | Date hash over local library | Scheduled featured pattern |
| Progress | `LocalProgressRepository` | Supabase/Firebase user save |
| Analytics | Console + local log sinks | GA4 / PostHog sink on `AnalyticsService` |
| Venues | Static `VENUES` | Partner dashboard |
| Commerce | Configurable link card | Shopify / catalog URLs |
| Auth | None | Optional account for cross-device progress |
| IRL contest | Local “Made IRL” flag + Instagram copy | Moderation / hamper fulfillment |

Do not add coins, ads, loot, chat, or freehand recognition in this product direction.

## Brand

Warm ivory ground, charcoal linework, muted earth accents, editorial type. The kolam stays visually dominant. Sessions are short on purpose: a successful round may end by asking the player to leave the screen and make the pattern for real.
