# Drop-in images

Replace the painted placeholders by putting files in these folders, **using these exact names**. Then hot restart the Flutter app. No code change is required if the filename matches.

Do not use green leaf graphics for Ezhai Kolam. That material is wet rice paste.

## Branding — `assets/branding/`

| File | What it should be |
| --- | --- |
| `mark.png` | Splash and home kolam (square PNG, cream on kaavi) |
| `wordmark.png` | Optional “KOLAM KRAZE” title lockup |
| `app_icon.png` | 1024×1024 app icon, no rounded-rect baked in |

## Materials — `assets/materials/`

Large, tactile close-ups. Crop tight. These drive Choose Material and onboarding.

| File | Look |
| --- | --- |
| `chalkpiece.png` | Matte dry chalk, powdery edge, high contrast on dark slate |
| `kola_maavu.png` | Soft granular rice flour |
| `ezhai_kolam.png` | Creamy wet paste, slight thickness, pooling at turns |
| `rangoli.png` | Coloured powder, rich Indian palette, not cartoon rainbow |
| `kaavi.png` | Brick-red oxide pigment / border sample |

Suggested size: 1200×800 or 1:1, PNG or JPEG (use `.png` names even if you convert).

## Surfaces — `assets/surfaces/`

Full-bleed floor/wall textures under the kolam.

| File | Use |
| --- | --- |
| `dark_slate.png` | Chalkpiece |
| `red_oxide.png` | Kola Maavu |
| `stone_threshold.png` | Ezhai Kolam |
| `courtyard_cement.png` | Everyday fallback |
| `festival_floor.png` | Rangoli |

## World photos

IRL / AR community photos should stay **user submissions**, not bundled stock. Do not drop residential location pins into the app.

## Icon

After you have `app_icon.png`, we can run `flutter_launcher_icons` to replace the default Flutter icon on iOS and Android.
