# Aarla Play: Kolam Kraze (Flutter)

Cross-platform mobile game for iOS and Android. This is the **source of truth** for Kolam Kraze.

The Next.js PWA at the repository root is the earlier web prototype and remains available, but new work belongs here.

## Stack

- Flutter 3.47
- Flame (stroke-by-stroke draw animation)
- CustomPaint drawing canvas (live play — lower latency than a game loop)
- `go_router` + `shared_preferences`

ARKit / ARCore are not required to run the app. Unsupported devices use **camera overlay mode**: a surface preview, place / scale / rotate / lock, Instant or Draw animation, then photo / video capture. The app must never crash because AR hardware is missing.

## Mental model

```text
HOW DO YOU WANT TO PLAY?     Memory / Copy / Flash
HOW DO YOU WANT TO DRAW?     Chalkpiece / Kola Maavu / Ezhai Kolam / Rangoli
OPTIONAL                     Kaavi ON / OFF
```

Ezhai Kolam is wet rice paste (maa kolam), not a leaf.

Kaavi is an optional brick-red accent layer, not a material.

## Run

```bash
cd mobile
flutter pub get
flutter run
```

Tests:

```bash
flutter analyze
flutter test
```

## Architecture

```text
lib/
  app/                 Aarla Play shell, router, bottom nav
  core/                design, storage, analytics
  games/kolam_kraze/
    engine/            enclosure builders, geometry, Flame animation
    models/            patterns, modes, materials
    renderers/         material + Kaavi painters
    levels/            generated catalog 3×3–15×15
    scoring/
    screens/
    widgets/
    ar/                overlay fallback lives in screens/bridge_screens.dart
    irl/
    community/
    editor/
```

Patterns are structural (`KolamPattern` + strokes on the pulli lattice), not images. The internal **Level editor** (Profile → Level editor) exports JSON.

World submissions stay local and enter a moderation queue (Profile → Aarla desk). Nothing auto-publishes.
