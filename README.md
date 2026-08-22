# My Stables

Stable management for the UAE equestrian market — one mobile app for riders,
owners, grooms, trainers and stable managers, plus an operator console, a seller
dashboard and a provider app. Built in **Flutter**.

The product and its screens are specified by the design handoff in
[`design_reference/`](design_reference/README.md) — read that first; the four
HTML files under `design_reference/designs/` are the source of truth for layout,
copy, colour and behaviour.

## Status — foundation

This is the **foundation pass**. What exists:

- **Design tokens & theme** (`lib/theme/`) — the "Organic" system's colour ramps,
  spacing scale, radii, shadows, and typography (Gabarito headings + Figtree
  body), ported from `design_reference/designs/_ds/.../styles.css`. Fonts are
  bundled as variable-font assets (`assets/fonts/`), including Noto Sans
  Arabic / Devanagari / Bengali as script fallbacks so every language renders
  without a runtime fetch.
- **Shared components** (`lib/widgets/`) — hairline lists (the system's core
  layout rule: rows separated by 1px hairlines, not cards), pill buttons
  (primary / secondary / ghost), tags, labelled inputs, the onboarding step
  progress bar, and the standard mobile screen scaffold.
- **i18n + RTL** (`lib/l10n/`, `lib/app_state.dart`) — all six languages
  (English, Arabic, Hindi, Urdu, Bengali, Nepali) wired through `gen-l10n`, with
  Arabic and Urdu mirroring the interface right-to-left automatically. The app
  picks up the device language on first launch and lets the user switch in-app.
  English
  and Arabic are fully translated; Hindi, Urdu, Bengali and Nepali have the
  high-visibility strings translated and fall back to English for the rest
  (a known gap to fill).
- **Auth flow, screens 1–5** (`lib/features/auth/`) — Splash, Sign in (password
  reveal, Apple/Google, invite-code link), Sign up (three-step), Verify
  (six-digit code), and Create-or-join a stable (exclusive choice with a CTA and
  legal line that change with the selection).
- A **foundation home placeholder** (`lib/features/home/`) that also serves as a
  live language switcher to exercise the i18n/RTL scaffolding.

### Not yet built

Everything after screen 5: home and the yard, horses, tasks, the schedule, the
market, and the three companion applications (admin console, seller dashboard,
provider app). See the handoff for the full scope and suggested order.

## Running

```sh
flutter pub get
flutter run             # a device or simulator
flutter run -d chrome   # in the browser
```

Localizations are generated from the ARB files by `gen-l10n` (configured in
`l10n.yaml`); `flutter run`/`build` run it automatically. Fonts are bundled
assets — no network is needed to render text.

## Project layout

```
lib/
  main.dart, app.dart        app shell, routing, locale state
  app_state.dart             LocaleController + supported locales
  theme/                     tokens.dart, app_theme.dart
  widgets/                   shared UI components
  l10n/                      app_*.arb + generated localizations
  features/
    auth/                    screens 1–5
    home/                    foundation placeholder
design_reference/            the design handoff (source of truth)
```
