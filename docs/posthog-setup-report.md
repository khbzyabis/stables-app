# PostHog analytics — setup report

Product analytics for My Stables, wired end-to-end (native + web).

## What was done

- **Package**: `posthog_flutter: ^4.11.0` (native iOS/Android) + JS snippet for web.
- **Config** (`lib/data/env.dart`): `POSTHOG_KEY`, `POSTHOG_HOST` (US Cloud:
  `https://us.i.posthog.com`). Analytics is on only when a key is present
  (`Env.analyticsEnabled`).
- **Wrapper** (`lib/data/analytics.dart`): thin, fully guarded — every call is
  wrapped in try/catch and no-ops when disabled, so analytics can never break
  the app. Exposes `setup / capture / identify / reset`.
- **Init**:
  - Native: `Analytics.setup()` in `main.dart` (lifecycle events on,
    person profiles = identified-only).
  - Web: async snippet in `web/index.html` (the Flutter SDK proxies to it).
- **Identity** (`lib/app.dart`): `identify()` on sign-in (with email + name),
  `reset()` on sign-out — tied to Supabase `authChanges`.
- **Screen views** (`lib/app.dart`): `PosthogObserver()` as a navigator
  observer, so route changes are auto-captured.

## Funnel events captured (`lib/data/supabase_service.dart`)

| Event | When |
|-------|------|
| `signed_up` | account created |
| `signed_in` | login |
| `stable_created` | new stable |
| `stable_joined` | invite redeemed |
| `horse_added` | horse added (prop: `stable_id`) |
| `task_completed` | a task marked done |

Person profiles are **identified-only**: anonymous visitors don't create
profiles, so the free-tier event budget goes to real signed-in usage.

## Privacy

- No PII beyond email/name on the identify call; Sentry is set to
  `sendDefaultPii = false`.
- The **project** key (`phc_…`) is the only key shipped. It is safe to expose
  publicly (it can only send events, not read data).

## Deploy

No database/SQL changes. The web build already contains the snippet — just
redeploy `build/web`. Native builds pick it up on next compile.
