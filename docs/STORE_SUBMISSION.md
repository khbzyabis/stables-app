# Publishing My Stables to the App Store & Google Play

The app is one Flutter codebase. The same `lib/` that builds the website also
builds the iOS and Android apps — no rewrite. This is the step-by-step for
getting it into the two stores. Everything the code can do is already done
(icons, splash, app name, permissions, release-signing plumbing); the rest
needs your developer accounts and a Mac (for iOS) or a CI service.

---

## 0. What's already set up in the repo

- **App name:** "My Stables" (iOS + Android).
- **App IDs:** Android `ae.mystables.my_stables`, iOS `ae.mystables.myStables`.
  (Keep these stable — changing an ID after first publish means a brand-new
  store listing.)
- **Icon & splash:** generated from `assets/branding/`. To rebrand, replace
  `icon_1024.png` / `icon_foreground.png` / `splash_logo.png` and re-run:
  ```
  dart run flutter_launcher_icons
  dart run flutter_native_splash:create
  ```
- **Permissions:** iOS photo/camera usage strings are in `Info.plist`.
- **Android release signing:** reads `android/key.properties` if present
  (below); minify + resource shrinking are on for smaller downloads.
- **Version:** `pubspec.yaml` → `version: 1.0.0+1`. Bump the part after `+`
  (the build number) on every store upload; bump `1.0.0` for user-visible
  releases.

You need **Flutter installed on the build machine** and, for iOS, a **Mac with
Xcode**. No Mac? See "CI option" at the end.

---

## 1. Configure the backend for a release build

The app reads Supabase config from `--dart-define`s at build time (same values
as the web build). Keep these handy — you pass them to every store build:

```
--dart-define=SUPABASE_URL=https://owyzgqemjmedlwaslhzt.supabase.co
--dart-define=SUPABASE_ANON_KEY=<your anon key>
--dart-define=SENTRY_DSN=<optional>
--dart-define=POSTHOG_KEY=<optional>
```

(The anon key is safe to ship — it's the public key. Never put the service_role
key in the app.)

In **Supabase → Authentication → URL Configuration**, add your app's redirect
if you later enable email links; for email/password it already works.

---

## 2. Android → Google Play

### 2a. One-time: create a signing key
On the build machine:
```
keytool -genkey -v -keystore ~/mystables-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias mystables
```
Keep this file and its passwords **forever and private** — losing it means you
can never update the app. Then create `android/key.properties` (git-ignored):
```
storePassword=<the store password>
keyPassword=<the key password>
keyAlias=mystables
storeFile=/absolute/path/to/mystables-release.jks
```

### 2b. Build the app bundle
```
flutter build appbundle --release \
  --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
```
Output: `build/app/outputs/bundle/release/app-release.aab`

### 2c. Publish
1. Pay the one-time **$25** at play.google.com/console and create the app.
2. Complete the required forms: **Privacy policy URL**, **Data safety**
   (we collect account email + the content users enter; payments via the
   platform), **Content rating**, target audience, and app category
   (Lifestyle / Business).
3. Create an **Internal testing** release, upload the `.aab`, add testers by
   email → fastest way to get it on real phones.
4. When ready, promote to **Production**. First review is usually 1–3 days.

---

## 3. iOS → App Store (needs a Mac + Xcode)

### 3a. One-time
1. Enrol in the **Apple Developer Program** (**$99/yr**) at developer.apple.com.
2. In **App Store Connect** → create the app with bundle id
   `ae.mystables.myStables`.

### 3b. Build & upload
```
flutter build ipa --release \
  --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
```
Then open `build/ios/archive/Runner.xcarchive` in **Xcode → Organizer**, or open
`ios/Runner.xcworkspace`, set your **Team** under Signing & Capabilities (Xcode
manages the certificate/profile automatically), then **Product → Archive →
Distribute App → App Store Connect**.

### 3c. Submit
1. In App Store Connect, fill the listing: screenshots (6.7" and 5.5" iPhone at
   minimum), description, keywords, support URL, **Privacy policy URL**, and the
   **App Privacy** questionnaire.
2. Add the build to a version and **Submit for review**. First review is
   typically 1–3 days.

---

## 4. Store listing assets you'll need (both stores)

- **Icon:** already generated (1024×1024 is in `assets/branding/icon_1024.png`).
- **Screenshots:** take them from the running app (a few phones' worth). Capture
  the home, a horse profile, the schedule, and the market.
- **Short + full description**, **privacy policy URL** (host a simple page — I
  can draft the text), and a **support email**.
- UAE note: content is bilingual (EN/AR). You can add an Arabic listing in both
  stores using the same screenshots.

---

## 5. CI option (no Mac, or hands-off builds)

- **Codemagic** (codemagic.io) is the easiest for Flutter: connect the GitHub
  repo, add the Android keystore + Apple API key as encrypted secrets, and it
  builds and uploads to both stores on a tag. It provides macOS runners, so you
  don't need your own Mac.
- **GitHub Actions** can build the Android `.aab` on an `ubuntu` runner and the
  iOS build on a `macos` runner with your signing secrets. Ask me and I'll add
  the workflow file.

---

## 6. Updating later

1. Make the change, bump `version:` in `pubspec.yaml` (at least the `+build`).
2. Rebuild (`appbundle` / `ipa`) and upload a new release.
3. Web updates independently via the normal Vercel deploy — the three surfaces
   share code but ship on their own cadence.
