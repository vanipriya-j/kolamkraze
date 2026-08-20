# Kolam Kraze — Demo Guide

Aarla Play’s first experience. Use this when showing the game on a phone: to a venue, a partner, or a small room.

**See it. Remember it. Draw it.**  
**Play in the spaces between things.**

---

## What this demo is for

Kolam Kraze is not an endless arcade. A good demo feels like a short, satisfying pause — then an invitation to make the pattern in the real world.

Show three things, in this order:

1. It is beautiful and culturally specific, not a generic puzzle skin.
2. A QR at a sabha, café, or clinic can go from scan to play in two taps.
3. The session can end off-screen: draw it outside, share it, tag **@aarla.culture**.

Aim for **8–10 minutes**. Stop while it still feels calm.

---

## Before you start

### Device

- Use a **phone**. Desktop works as a narrow column, but the story is mobile.
- Chrome or Safari. Add to Home Screen if you want to show the PWA, but it is optional.
- Portrait, brightness up, Do Not Disturb on.
- Sound on for the first tracing, then mute if the room is quiet. The cues are soft; the game is fully usable silent.

### Run locally

```bash
npm install
npm run dev
```

On the phone, open the machine’s LAN URL, not only `localhost`. Example:

```txt
http://192.168.x.x:3000
```

For a hosted demo, replace the origin below with that domain.

### Clean first impression

Venue welcome appears **once per browser session**. For a QR demo:

- Open the venue URL in a **private / incognito** window, or
- Close the tab and reopen it in a new session.

If you already tapped **Play Now**, you will land on Home with “Playing at [Venue]” instead of the welcome screen. That is fine for a second pass; it is not the first-scan story.

### Warm-up (30 seconds, off-stage)

Play **Bindu** once in Copy Mode so your hand remembers the snap. Loop around the **center pulli**. The line wants to travel through the four points around that dot, not through the dot itself.

---

## 10-minute live script

### 1. Splash — 30 seconds

Open:

```txt
/
```

You should see:

- Aarla Play
- **Kolam Kraze**
- **See it. Remember it. Draw it.**
- **Play**

**Say:** This is Aarla Play. Not a feed. A short game you can finish between things.

Do not linger. Tap **Play**.

---

### 2. Home — 45 seconds

Point out, without reading every row:

- Continue
- Copy Mode
- Memory Mode
- Timed Challenge
- Daily Kolam
- Kolam IRL
- the small progress line (patterns completed · made IRL)

If this week’s campaign is live (**Monsoon Loops**, 17–24 Aug 2026), a quiet card appears: prize copy for an **Aarla Kolam Hamper**. Mention it exists; do not open it yet.

**Say:** The home screen stays quiet on purpose. The kolam is the product, not the chrome.

---

### 3. Copy Mode, Bindu — 2–3 minutes

This is the heart of the demo. Do it on the phone, in your own hand.

Path: **Copy Mode** → **Bindu** (first beginner pattern).

What to show:

- The ghost of the pattern stays visible.
- Dots are pullis. You draw **around** them.
- The line snaps. It should feel tactile, not twitchy.
- **Undo** / **Clear** / **Check** sit below the grid. The grid takes most of the screen.

How to draw Bindu:

1. Put a finger near the faint loop around the center dot.
2. Drag slowly along the circle. Let it click from point to point.
3. Go all the way around once.
4. Tap **Check**.

You want **Beautifully done.** and stars. One star is enough. Three stars is a bonus, not the point.

**Say:** We do not punish small inaccuracy. The game should feel like rice powder on a threshold, not like a rhythm game.

If Check says “Not quite,” undo or clear and trace the ghost again. Do not apologise at length. Just finish the loop.

---

### 4. Memory, same kolam — 1 minute (optional if time is tight)

From the result screen you can **Retry**, or go Home → Memory Mode → Bindu.

The pattern appears for a few seconds (**I’m ready** skips the wait), then hides.

**Say:** Copy is for learning. Memory is for the wait — a kutcheri interval, a coffee, a clinic chair.

One **Hint** is allowed. Use it only if the room needs it.

---

### 5. Venue QR — 2 minutes

This is the wait-time product. Open a **new private tab**.

Recommended first venue:

```txt
/play/kolam-kraze?venue=sabha-demo
```

You should see:

- **Playing at Sabha Demo**
- **A few minutes to spare?**
- venue line about the next piece
- **Play Now**

Tap **Play Now**. It should jump straight into a kolam (Irani for sabha). No account. No email.

After a round, the result card can show a **venue reward** — for sabha, a postcard at the counter. That is placeholder copy, but the architecture is real.

**Say:** The QR is the product surface. Scan, play, sit back down. We are not trying to keep anyone in the phone.

Show one more only if you have time:

| Venue | URL | Why it is in the deck |
| --- | --- | --- |
| Aarla Studio | `/play/kolam-kraze?venue=aarla-studio` | Brand home |
| Sabha | `/play/kolam-kraze?venue=sabha-demo` | Interval / foyer |
| Clinic | `/play/kolam-kraze?venue=clinic-demo` | Quiet wait |
| Café | `/play/kolam-kraze?venue=cafe-demo` | Counter reward |
| Music Academy alias | `/play/kolam-kraze?venue=music-academy` | Same as sabha |

Print these as QRs for a tabletop demo. Same path, different welcome.

---

### 6. Take it outside — 2 minutes

From a result screen, tap **Take this Kolam outside →**  
or Home → **Kolam IRL**.

You should see:

- **Take It Outside**
- **You cracked it on screen. Now make it for real.**
- a clean reference
- the six steps (draw outside, photo, Instagram, **@aarla.culture**, **#KolamKraze**, hamper)
- contest disclaimer (Instagram is not affiliated)
- **Save reference**
- **I made this IRL**

Tap **I made this IRL**. The **Made IRL** badge should appear. Home then distinguishes digital completions from IRL completions.

**Say:** A successful session can end by putting the phone down. That is the point of Aarla Play.

Skip actually posting unless the room asks. The flow is the demo, not the feed.

---

### 7. Close — 30 seconds

Return to Home. Read the footer once:

**Play in the spaces between things.**

Stop. Invite questions. Do not open Timed Challenge unless someone asks for “is there a score-attack mode?”

---

## If they ask to see more

Keep these in the pocket, not the main path.

| Ask | Where | Note |
| --- | --- | --- |
| Daily | Home → Daily Kolam | One pattern per day, from the local library for now |
| Timed | Home → Timed Challenge | ~2 minutes; easy to overrun the room |
| Progression | Copy Mode level grid | Stars, locks, previews |
| Mute | Sound on / Sound off | Preference is remembered |
| Install | Browser → Add to Home Screen | Standalone PWA; playable after first load |

---

## Talking points

Use these; do not stack them all.

- **Aarla Play**, not a generic studio. Kolam Kraze is the first experience, not the whole company.
- Sessions are **short on purpose**. We are not optimising for screen time.
- The kolam stays visually dominant: ivory, charcoal, earth. No neon, no coins, no ads.
- Venues can change welcome, featured pattern, accent, and reward. The Aarla identity stays.
- Daily / weekly / IRL / commerce links are ready for a CMS or backend later. V1 is local and honest about that.
- Contest copy is live; contest infrastructure is not. Terms may apply.

---

## If something goes wrong

**The line will not start.**  
Rest a finger on a point on the faint loop, then drag. You cannot draw through empty space.

**Check fails.**  
The counter under the grid (`n / n`) should reach most of the expected edges. Clear and follow the ghost more slowly. Copy Mode is the recovery.

**Venue welcome did not appear.**  
You are in an existing session. Private window, or a different venue id.

**Phone cannot reach localhost.**  
Use the computer’s local IP, or deploy and demo from HTTPS. iOS will not treat `localhost` on another machine as itself.

**Sound is missing.**  
That is acceptable. Tap once on the grid first if you want the soft snap; some browsers wait for a gesture.

**Stars look low.**  
Do not replay for a perfect score in front of people. Completion is the story.

---

## Suggested 3-QR print set

For a table or foyer standee:

1. **Play** — `/play/kolam-kraze?venue=aarla-studio`
2. **Waiting?** — `/play/kolam-kraze?venue=sabha-demo`
3. **Today’s Kolam** — `/play/kolam-kraze/daily`

Headline on the card: **A few minutes to spare? Play a Kolam.**

---

## What not to demo as if it were finished

- Accounts, cloud save, leaderboards
- Live Instagram API or hamper fulfilment
- Partner admin / CMS
- Shopify checkout
- Native App Store / Play builds
- AI-generated kolams or freehand recognition

Those are explicitly out of V1. If asked, say they are later seams, not missing buttons.

---

## After the room

If someone wants to try alone:

```bash
npm install
npm run dev
```

Developer notes (adding a kolam, adding a venue, how validation works) live in the [README](../README.md).
