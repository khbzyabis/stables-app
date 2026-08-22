# Handoff: My Stables

A stable-management product for the UAE equestrian market: one mobile app used by riders, horse owners, grooms, trainers and stable managers; a web dashboard for approved sellers and service providers; a limited phone app for those providers; and an internal admin console for the platform operator.

Four HTML design files, 67 mobile screens, and two desktop applications. Everything in them is a design reference. Nothing is production code.

---

## Start here

This package is written to be read by Claude Code, in the repository where the product will be built. Read this README first, then read the four HTML files in `designs/` as source — they are text, and everything on every screen is in them: layout, exact copy, colours, and what changes on interaction. There are no screenshots, and none are needed.

Suggested order of work: tokens and theme first, then the auth flow (screens 1–5), then home and horses (6–8, 18–22, 27–35), then the schedule and tasks, then the market. The console, seller dashboard and provider app are separate applications and can follow.

## About the design files

The files in `designs/` are **prototypes written in HTML** to show intended layout, copy and behaviour. They are not code to copy into a product.

The task is to **recreate these designs in the target codebase's own environment** — React Native, Flutter, SwiftUI + Kotlin, Next.js, whatever the team already uses — following that codebase's established patterns, component library, navigation and state conventions. If no codebase exists yet, choose an appropriate stack and build the designs there.

Each file uses a small in-house rendering layer (`support.js`, a `<x-dc>` template with `{{ }}` holes and `<sc-for>` / `<sc-if>` control flow). **Do not port that layer.** Read it as you would read a Figma file: it tells you what is on the screen, what changes when, and what the copy says.

`ios-frame.jsx` draws an iPhone bezel around each mobile screen for presentation only. The design inside the bezel is the design; the bezel is not.

### How to read a screen

Every mobile screen sits in a container with a stable id and a label:

```html
<div id="s51" data-screen-label="51 Order"> … </div>
```

Screen numbers in this document match those ids. Console and dashboard sections are identified by their sidebar labels instead.

---

## Fidelity

**High fidelity.** Final colours, type, spacing, copy and interaction behaviour. Recreate the UI faithfully using the codebase's existing libraries. Two deliberate exceptions:

- **No photography.** Every image is a grey placeholder marked *Photo*, *Image* or *Logo*. Real imagery has not been produced. Placeholder shapes and their sizes are correct; the content is not.
- **No motion.** Screens are static. Transitions, spinners and skeletons are not designed. Use the target platform's conventions and keep them quiet.

---

## Platform and language

- **Both iOS and Android**, same layouts. Shown in an iPhone frame at 402 × 874.
- **Six languages**: English, Arabic, Hindi, Urdu, Bengali, Nepali. Each person picks their own; a stable is routinely multilingual.
- **Arabic and Urdu are right-to-left.** The whole interface mirrors — back arrows, progress bars, chat bubbles, tab order. Numbers, times and money stay left-to-right inside mirrored rows.
- **Messages are machine-translated on read**, not on write. Every translated message shows the original underneath, marked as translated, with a control to see it in the language it was written in. See screen 43.
- **Currency is AED throughout.** VAT is 5%, shown as included, with the operator's TRN on receipts.
- **Phone numbers are UAE format**: `+971 5x xxx xxxx`.

---

## The four files

| File | What it is | Canvas |
| --- | --- | --- |
| `designs/My Stables App.dc.html` | The mobile app — 67 screens | 402 × 874 each |
| `designs/Stables Admin Console.dc.html` | Internal admin console for the platform operator | 1440 × 920 |
| `designs/Seller Dashboard.dc.html` | Web dashboard for an approved seller / service provider | 1440 × 920 |
| `designs/Provider App.dc.html` | The provider's phone — 10 screens | 402 × 874 each |

Open any of them in a browser. `designs/support.js`, `designs/ios-frame.jsx` and `designs/_ds/…/styles.css` must sit alongside them, as they do in this bundle.

---

## Design tokens

From `designs/_ds/organic-07b13dc3-fcc8-4e70-b2c2-fd7f5889f38a/styles.css`. Recreate these as the target platform's theme.

### Colour

| Token | Hex | Used for |
| --- | --- | --- |
| `--color-bg` | `#f5ead8` | Page ground, every screen |
| `--color-surface` | `#ebddc5` | Raised surfaces |
| `--color-text` | `#201e1d` | All body text |
| `--color-accent` | `#c67139` | Terracotta — the single action on a screen |
| `--color-accent-2` | `#7a8a5e` | Sage — status, confirmation, "well" |
| `--color-divider` | `#201e1d` at 16% | Every hairline |

Ramps, 100 → 900, on one shared perceptual lightness scale:

- **Neutral**: `#f9f4ed` `#eee7db` `#dcd3c4` `#c0b6a5` `#a19786` `#82796a` `#645c50` `#474238` `#2e2b25`
- **Accent (terracotta)**: `#fff2eb` `#ffe1d0` `#ffc6a5` `#f6a06b` `#d67f48` `#b2622d` `#8c491a` `#643312` `#402310`
- **Accent 2 (sage)**: `#f0fae1` `#e1eecc` `#ccdbb2` `#aebf92` `#8fa073` `#728157` `#56633f` `#3d472b` `#272e1b`

Rules that hold across all four files:

- Input fills are `--color-neutral-100` with a transparent border, not an outlined box.
- Body-size text in the accent uses `--color-accent-700`, never `--color-accent` (contrast).
- Sage means settled, healthy, confirmed. Terracotta means act, or attention.
- Photo placeholders are `--color-neutral-300` with `--color-neutral-700` label text.
- The admin console sidebar is `--color-neutral-900` with `--color-neutral-100` text — the only dark surface in the system.

### Type

Two families, loaded from Google Fonts:

- **Gabarito** 500/600/700 — every heading, number and button label. Headings set `letter-spacing: -0.02em`, `line-height: 1.0–1.1`.
- **Figtree** 300/400/500/600 — body, labels, metadata.

Sizes as used (mobile):

| Role | Size / weight |
| --- | --- |
| Screen title | 34–36px Gabarito 600 |
| Section title | 30–32px Gabarito 600 |
| Card / row title | 19–23px Gabarito 600 |
| Body | 16–17px Figtree 400, line-height 1.5–1.6 |
| Metadata | 13–15px Figtree 400 at 50–60% opacity |
| Eyebrow label | 12–13px, `letter-spacing: .1em`, uppercase, `--color-accent-2-700` |
| Tag / pill | 11–12px, `letter-spacing: .06–.08em`, uppercase |

Desktop is one step tighter: 30px page titles, 28–30px KPI figures, 14–16px body, 11px uppercase column headers at 50% opacity.

Note: the design system's own heading face is Caprasimo. It was replaced with Gabarito early in the work at the client's request — Caprasimo read as too heavy at interface sizes. Gabarito is the correct face for this product.

### Spacing, radius, elevation

- Scale: `4.4 / 8.8 / 13.2 / 17.6 / 26.4 / 35.2px`
- Radius: `8 / 16 / 28px`, and `999px` for buttons, chips, inputs and switches
- Mobile screen padding: `32px` horizontal, `74–76px` top (below the status bar), `38–40px` bottom
- Desktop content padding: `28px 40px 44px`; sidebar `248px` wide
- Shadows: `--shadow-sm/md/lg`. Used sparingly — the system separates with hairlines and space, not cards.

### The layout rule that matters most

**Rows separated by 1px hairlines, not cards.** Almost every list in all four files is:

```
<hairline>
row (padding 14–20px vertical)
<hairline>
row
<hairline>
```

No card borders, no shadows, no rounded containers around list items. This was an explicit and repeated instruction: minimal containers, generous whitespace. Rounded fills appear only on inputs, chips, buttons, switches and the occasional note block.

### Icons

Lucide, `stroke-width: 2.4–2.75`, sizes 18–25px. Two custom marks drawn as SVG paths:

- **Two horseshoes** — the Horses tab. Two U-shapes side by side, nail holes as small circles.
- **A barn** — the Stable tab. Pitched roof, doors.

Both are in `My Stables App.dc.html`; search for `horseshoe` and the tab icon definitions.

---

## Roles and permissions

A single login belongs to a person, not a stable. One person can be in several stables with a different role in each, and can create their own stable while being a groom at another. Role is per membership.

| Role | Can |
| --- | --- |
| **Admin** | Everything in their stable: approve joins, assign roles, set tasks, edit any horse, post notices, book services, close the stable |
| **Trainer** | See horses they train, write training notes, set horse configurations, give tasks |
| **Groom** | See the day's tasks and the horses they care for, tick tasks done, read setups and feed charts. Cannot see money |
| **Rider / owner** | Their own horses in full, the shared schedule, the noticeboard, the market, their own payments |

Two rules the designs depend on:

- **A rider joining a stable brings their horse, and the admin must approve both** — the person and the horse. Screens 9–11.
- **Notes follow their author.** A health or training note written at stable A stays with stable A when the horse moves. The horse's passport, insurance, vaccination card, feed chart and setups travel with the horse. Screen 63.

---

## The mobile app — 67 screens

### Onboarding, 1–5

| # | Screen | Notes |
| --- | --- | --- |
| 1 | Splash | Wordmark, sage and terracotta circles, three pulsing dots |
| 2 | Sign in | Email + password with a Show/Hide reveal, Apple and Google, an invite-code link |
| 3 | Sign up | Name, email, UAE phone, password. Three-step progress bar. Terms and privacy are tappable links |
| 4 | Verify | Six-digit SMS code, one box per digit, resend countdown |
| 5 | Create or join a stable | Two exclusive options. Create → name and location, and you become admin. Join → six-character invite code. Legal line changes with the choice |

Auth methods: email + password, Apple, Google, invite code. All four must exist.

### Home and the yard, 6–8, 12–17

The home screen leads with **My horses** — a hairline-separated list of horse, one-line status, and a Well/Watch tag. Below the fold: today's schedule, tasks if you have any, and the noticeboard.

Bottom tab bar, four tabs: **Horses** (two horseshoes), **Board** (speech bubble), **Stable** (barn), **You** (person). A fifth item, **Shows**, appears only when the operator has enabled it — see "Feature flags" below.

Screens 12–17 are the shared schedule: week strip, a day, and an event. Everything the stable does appears here — lessons, farrier and vet visits, transport, shows.

### Horses, 18–22, 27–35, 63, 67

- **Adding a horse is deliberately minimal.** Name only is enough. Age, photo, breed, height, box and everything else are optional, added later or never. This was an explicit instruction.
- **Horse profile** — status, next events, health, training, documents, feed chart, setups.
- **Configurations** (screens 33–35). A horse has named setups — *Flatwork*, *Jumping*, *Hacking* — each listing tack from the rider's tack box. Selecting a discipline loads that horse's setup for it. **If the setup is changed, the app shows what it was last time and offers to save the new one as the default.** This is the "configuration mode" the client asked for.
- **Tack box** (screens 20–21). Each rider owns a tack box: bridles, nosebands, bits, reins, boots, pads. Setups reference items from it, so telling a groom the day's plan is unambiguous.
- **Editing and moving** (63). Editing is a plain form. Moving a horse to another stable requires **both** admins to agree, and states plainly what travels and what stays.
- **Progress** (67). One month / three months / a year. Sessions, hours, flatwork-to-jumping ratio, longest gap, highest fence, and the trainer's note. Explicitly **not a score**.

### Tasks, 23–25

Admins and trainers set tasks; grooms tick them. Tasks carry who set them, a due day, and optionally a horse. A progress line reads "3 of 7 done · 4 left". Ticks work offline — see screen 65.

### Noticeboard, 26

Per-stable board. Pinned posts, plain-text posts, author and time. Not the same thing as the platform board (screen 62).

### People and stables, 9–11, 36–39, 44–46

- Invite by link or code; the invitee goes through sign-up and lands **with their role in that stable already set**.
- Admin approves joins, assigns and changes roles, removes people.
- **Contacts** (38) — everyone at the stable plus your farrier and vet with their next visit.
- **Switching stables** (36) — a person in several stables switches between them; role and permissions change with the stable.
- **Location** (46) — the stable on a map, with a note that a public pin is what lets providers quote you.

### Languages, 40–43

Language picker, RTL mirroring, and the translated-message pattern. Screen 43 shows a message written in English being read in Hindi with the original beneath it.

### Shows and entries, 47, 54–55, 61–62

- **Shows tab** — a list of upcoming shows, an optional labelled advert banner at the top.
- **Entering a show** (54) — pick horse and classes, see the fee, accept the organiser's rules.
- **Start list** (55) — running order, your ride time highlighted.
- **The platform board** (62) — notices written by the operator, seen by everyone whose stable has Shows enabled. Filters for Shows / App / Advert. Adverts are labelled and tinted differently. Riders cannot reply.

### The market, 48–53, 56–60, 66

The buying side. **Every seller and service provider is approved by the operator before anything appears here.**

| # | Screen | Notes |
| --- | --- | --- |
| 48 | Market | Feed, Tack, Hoofcare, Rugs, Services. Basket count in the header |
| 49 | An item | Measurements stated explicitly, size as a chip, and a promise that a mismatch is refunded |
| 50 | Basket and checkout | **Grouped by seller. Each seller's delivery is separate and separately priced — deliveries are never merged.** Two sellers = two delivery charges. Payment options include "charge to the stable" (admin approves) |
| 51 | An order | Four-step timeline ending at "seller paid, once the return window closes". Raising a problem opens reason chips whose placeholder text changes per reason |
| 52 | Ask for a price | Request a quote from several providers at once. They see how many others were asked, not who |
| 53 | Compare quotes | Ranges, not figures. Different expiry dates. Accepting books the calendar slot and lapses the others |
| 56 | Request transport | Two addresses as a journey, horses, and what a transporter needs to know — travelling together, groom seat, **insured value per horse**, nervous loader |
| 57 | Transport quotes | Vehicle, insured value and loading time under each price. The cheapest is insured to a fraction of the dearest, and the screen says to read that line before the price |
| 58 | The booked journey | Lands on the stable's calendar with loading time, gate code, driver, vehicle, insured value and cost. Passports and vaccination cards go to the carrier automatically; health notes do not |
| 59 | Payments | Everything the rider has paid for, grouped by month, filtered by kind. States distinguish paid, not-yet-charged, and refunded |
| 60 | A receipt | One payment, itemised per seller, VAT at 5% shown as included, operator TRN at the foot |
| 66 | Declined card | Nothing taken, basket intact, items held two hours, **and nobody at the yard was told** |

### Money model

This governs the seller dashboard and provider app as well.

- The buyer pays **the platform**, never the seller directly.
- Goods sit in a **14-day return window**. Services settle the day they are completed.
- Payouts run **twice a month, on the 1st and the 15th**, one transfer per seller.
- The platform's commission is set per category in the admin console and is **visible to the seller** — they see the listed price, the cut, and what they will receive.
- Delivery money is **pass-through**: the platform takes nothing from it.
- **The platform arbitrates every dispute.** Sellers respond; they do not decide.
- Services cannot be returned.

### Empty and broken states, 64, 65

- **64 Day one** — no horses. A dashed outline, not a fake card, and three useful things to do while the yard is empty.
- **65 No signal** — a dark bar showing how many ticks are held on the phone. Ticking still works. An honest list of what is *not* available offline: the market, messages, and anything a vet or farrier wrote today.

### Feature flags

Three things are toggled by the operator, platform-wide, from the admin console. The app must render correctly with any combination off:

| Flag | Off means |
| --- | --- |
| **Shows** | No Shows tab, no entries, no start lists, no platform board |
| **Market** | No market, no quotes, no transport requests, no basket. Providers stay visible in Contacts |
| **Adverts** | Advert slots are hidden everywhere, boards keep their own notices |

Both Shows and Market are expected to ship **off** and be enabled once the product matures.

---

## Stables Admin Console — 1440 × 920

Internal, for the platform operator. Dark 248px sidebar, grouped sections, a role switcher at the top.

**Four roles, and the sidebar changes per role.** Building this as one page with everything visible is wrong.

| Role | Sees |
| --- | --- |
| Owner | Everything |
| Finance | Overview, stables, payouts, fees, disputes, sellers |
| Operations | Stables, users, applications, sellers, disputes, ops, announcements, placements, leaving, flags, audit |
| Support | Stables, inspect, users, disputes, ops, leaving |
| Marketing | Overview, stables, sellers, marketing, announcements, placements |

Sections:

- **Overview** — platform KPIs.
- **Stables / Inspect / Users** — every stable and person; support can look into a stable without joining it, and that look is logged.
- **Applications** — seller and provider approvals with their documents. Trades include shop goods, farriery, veterinary, physiotherapy, **horse transport** and courier delivery; each trade demands its own paperwork.
- **Sellers** — approved sellers, suspension, and what suspension means (listings down, booked jobs stand, held money still pays out).
- **Disputes** — the operator's arbitration queue.
- **Due / Payouts** — the 1st and 15th cycles.
- **Fees** — commission per category, delivery rules, free-over threshold, with a worked example showing list price → cut → seller receives. Explicit line: **two sellers in one basket produce two delivery charges, never merged.**
- **Marketing / Announcements / Board and placements** — the platform board, its posts and audiences, and five advert slots each with a toggle. The slot after payment stays off deliberately, with the reason on screen: a receipt is not a place to sell something.
- **Ops** — health of the platform.
- **Leaving** — deletion requests, 30-day clock, what is blocking each one (an admin who is the only admin of their stable cannot leave until someone takes over), and what legally cannot be deleted (notes stay under their author's name, receipts stay seven years).
- **Audit log** — append-only, every console action.
- **Feature flags** — the three platform switches above.

---

## Seller Dashboard — 1440 × 920

For an approved seller who is also a service provider (the example, Al Suwaidi, is both a shop and a farrier). Sidebar splits **Shop** (orders, returns, listings) from **Services** (requests, jobs), with **Money** and **Account** below.

- **Held vs payable** sits in the header on every page. That is the first number a seller checks.
- **Orders** carry a payable date, not just a total.
- **Overview** has a four-step "how money reaches you" timeline ending on the 1st or 15th.
- **Returns** states that the seller responds but the platform decides; one row shows a return on a completed farrier visit being dismissed because services are not returnable.
- **Listings** show the platform's cut and the seller's net per item.
- **Requests** show competing quotes ("3 others asked"), ranges, expiry, and that accepting books the slot.
- **Account** lists what they are approved for — farriery yes, medicines no, insurance expiring — and which of their staff can touch payouts.

---

## Provider App — 10 screens

Deliberately smaller than the dashboard. A farrier between two yards should not be reading an arbitration thread on a phone.

- **P0a–P0c** — applying: trades, paperwork, and the seller agreement, which must be ticked before the application can be sent.
- **P1 Today** — the day's stops in driving order, with distances.
- **P2 A request** — accept with a price range, or decline. Shows how many others were asked.
- **P3 Finishing a job** — tickable steps, a note to the stable, a photo slot. Finishing settles the fee that day.
- **P4 Stable thread** — messages with the yard.
- **P5 Orders to pack** — the shop half.
- **P6 Earnings** — this month, or the next payout.
- **P7 When I work** — open and closed days, a daily cap on horses, time away. **Closing a day that already has bookings warns that those yards are still expecting you and closing does not cancel them.**

Not on the phone, on purpose: listings editor, payout ledger, disputes, staff permissions.

---

## State

The prototypes hold state in one class per file. In production most of this is server state; the list below is what the UI needs to track.

**Mobile app**: current stable (a person may belong to several), role in that stable, selected horse, selected discipline and its configuration, task completion (offline-capable, queued), basket contents grouped by seller, selected payment method, quote acceptance, language and text direction, and the three feature flags.

**Console**: current admin role (drives the sidebar), selected section, selected row in each queue, fee rates per category, advert slot toggles, feature flags, deletion-request status.

**Seller dashboard**: section, order filter, job filter, listing on/off per item, earnings period.

**Provider app**: application trades and documents, agreement accepted, request answer state, job step completion, packed status per order, earnings period, open/closed days, daily cap.

**Offline behaviour**: task ticks are written locally and synced when signal returns. Nothing else works offline, and the UI says so.

---

## Assets

- **No photography exists.** Every image is a grey placeholder with its intended shape and size. Horse photos are circular at 60–76px in lists, rectangular at 230px tall on a profile; market items are 62–64px rounded squares in lists, 230px on an item page; adverts are 96–104px banners.
- **Icons**: Lucide, plus two custom SVG marks (two horseshoes, a barn) defined inline in the app file.
- **Fonts**: Gabarito and Figtree, both Google Fonts.
- **Stylesheet**: `designs/_ds/…/styles.css` carries the tokens and the `.btn` / `.tag` / `.input` / `.field` classes the prototypes use.

---

## Files in this bundle

```
designs/
  My Stables App.dc.html          67 mobile screens
  Stables Admin Console.dc.html   operator console
  Seller Dashboard.dc.html        seller / provider web dashboard
  Provider App.dc.html            10 provider phone screens
  ios-frame.jsx                   presentation bezel — not part of the design
  support.js                      prototype rendering layer — do not port
  _ds/organic-.../styles.css      design tokens and base classes
```

---

## Not designed yet

Known gaps, so they are not mistaken for oversights:

- **The trainer has no screens.** The role exists everywhere; lesson lists, a trainer's riders, and writing after a lesson do not.
- **Arena and school booking.** Lessons and visits are scheduled but nothing prevents two people booking the same arena.
- **Second-hand selling between riders**, and horses for sale.
- **Motion.** No transitions, loading or skeleton states are specified.
- **Subscriptions.** Discussed as a later addition; not designed.
