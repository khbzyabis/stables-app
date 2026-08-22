# Launch the web app on Vercel

Vercel hosts the **Flutter web app** (and later the admin console / seller
dashboard). The **API and Supabase do not go on Vercel** — they run on Hetzner
(see [`DEPLOY.md`](DEPLOY.md)). The web app is a static build that calls the API
over HTTPS.

## Option A — one command from your Mac (simplest)

```sh
npm i -g vercel      # once
vercel login         # once

# Preview (offline/sample data — great for sharing a link):
./scripts/deploy-web.sh

# Production, pointed at your live API:
API_BASE_URL=https://api.mystables.ae ./scripts/deploy-web.sh --prod
```

The script runs `flutter build web` then `vercel deploy build/web`. The command
prints the live URL.

## Option B — automatic on every push (CI)

`.github/workflows/deploy-web.yml` builds the web app and deploys to Vercel on
each push to `main`. Set these once in **GitHub → Settings → Secrets and
variables → Actions**:

- Secret `VERCEL_TOKEN` — https://vercel.com/account/tokens
- Secret `VERCEL_ORG_ID` and `VERCEL_PROJECT_ID` — run `vercel link` locally once;
  they're written to `.vercel/project.json`.
- (Optional) Variable `API_BASE_URL` — your deployed API URL. Omit for an
  offline preview build.

Then every push to `main` redeploys the app automatically.

## Notes

- **Routing:** the app uses hash-based URLs (`/#/route`), so no rewrite rules are
  needed — it works on Vercel's static hosting as-is.
- **Offline vs live:** with no `API_BASE_URL`, the app shows built-in sample data
  (perfect for a first public preview). Set `API_BASE_URL` once the Hetzner API
  is up to switch it to real data.
- **CORS:** the API's `CORS_ORIGINS` must include your Vercel domain, or browser
  calls from the deployed app will be blocked.
- **Fonts/engine:** the build bundles its fonts and loads the CanvasKit engine
  from Google's CDN by default — both fine on Vercel.
