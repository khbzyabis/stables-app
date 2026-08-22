# Run everything locally (macOS)

Three levels — start at Level 1 (30 seconds, no backend) and go deeper as you like.

## Prerequisites

- **Flutter** — https://docs.flutter.dev/get-started/install/macos
  (check with `flutter doctor`)
- **Docker Desktop** (only for Levels 2–3) — https://www.docker.com/products/docker-desktop/
  Make sure it's **running** (whale icon in the menu bar) before `docker compose`.
- **Node 20+** (only if you run the API outside Docker) — https://nodejs.org

All commands below run from the project root (`/Users/ahmad/stables-app`) unless noted.

---

## Level 1 — just the app (no backend)

The app runs fully offline with built-in sample data — every screen works.

```sh
flutter pub get
flutter run                 # pick a simulator/device, or:
flutter run -d chrome       # in the browser
```

That's the fastest way to click through all the screens.

---

## Level 2 — app + real backend + database

Runs Postgres + Redis + the NestJS API behind a load balancer, in Docker.

```sh
# 1. Start the stack (Postgres, Redis, API×2, Nginx). Applies DB migrations
#    automatically. Docker Desktop must be running.
cd infra
docker compose up --build          # leave this running; API is at http://localhost:8080

# 2. In a SECOND terminal: seed demo data + mint a dev login token
cd backend
npm install
DATABASE_URL=postgresql://app:devpassword@localhost:5432/mystables?schema=public \
  npx prisma db seed
node scripts/dev-token.mjs          # prints a JWT — copy it

# 3. In a THIRD terminal: run the app pointed at the API
flutter run -d chrome \
  --dart-define=API_BASE_URL=http://localhost:8080 \
  --dart-define=API_TOKEN=<paste the JWT> \
  --dart-define=API_STABLE_ID=22222222-2222-2222-2222-222222222222
```

Now the app's horses come from Postgres via the API (add one and it's saved).
Check the API directly:
```sh
curl http://localhost:8080/healthz    # ok
curl http://localhost:8080/readyz     # database + redis up
```

Stop it with `Ctrl+C` in the `docker compose` terminal (add `docker compose down`
to remove containers; add `-v` to also wipe the database volume).

---

## Level 3 — add self-hosted Supabase (Auth + Storage)

Level 2 gives you the database. Add Supabase when you want real login (Auth) and
file storage instead of the dev token.

```sh
cd infra/supabase
cp .env.example .env                 # fill in every CHANGE_ME (see the file)
docker compose up -d                 # Postgres + Auth + Storage + Studio
# Studio (admin UI): http://localhost:3001
```

Then point the API at Supabase's Postgres and share its `JWT_SECRET`
(`backend/.env`: `DATABASE_URL` → Supabase Postgres, `SUPABASE_JWT_SECRET` =
the same `JWT_SECRET`), apply migrations (`npx prisma migrate deploy`), and users
sign in through Supabase Auth instead of the dev token.

Full details and the production (Hetzner) version: [`docs/DEPLOY.md`](docs/DEPLOY.md).

---

## Troubleshooting

- **`docker: command not found` / "Cannot connect to the Docker daemon"** —
  Docker Desktop isn't running. Open it, wait for the whale icon, retry.
- **App shows sample data, not the API** — you didn't pass `--dart-define=API_BASE_URL`,
  or the token expired (mint a fresh one with `node scripts/dev-token.mjs`).
- **Port already in use** — something else is on 8080/5432/6379; stop it or change
  the ports in `infra/docker-compose.yml`.
