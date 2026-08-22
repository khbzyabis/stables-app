# Deploy & Update — My Stables on Hetzner

How to stand the platform up, and how to **update everything** afterwards.
Architecture rationale lives in [`ARCHITECTURE.md`](ARCHITECTURE.md); this is the
operational runbook.

## Topology recap

```
Hetzner LB (TLS) ──► NestJS API replicas ──► Supabase (Postgres, Auth, Storage)
                          │                        ▲
                          └──► Redis (rate limit)  │
Web dashboards + app web preview ──► Vercel ───────┘  (clients of the API)
```

- **Supabase** (`infra/supabase/`): Postgres + Auth + Storage + Realtime + Studio.
- **API + Redis + LB** (`infra/docker-compose.yml`): the NestJS tier.
- **Apps/dashboards**: talk to the API + Supabase Auth.

Two hard rules:
1. The API and Supabase Auth share the **same `JWT_SECRET`**
   (`SUPABASE_JWT_SECRET` in `backend/.env` == `JWT_SECRET` in
   `infra/supabase/.env`).
2. Secrets never live in git — only `.env.example` templates do.

---

## First-time setup

### 0. Provision (once)
- 1 Hetzner Cloud server for Supabase (CX/CPX with a volume for `db-data`), and
  1–2 for the API, on a **private network**; a **Hetzner Load Balancer** in front.
- Install Docker + compose plugin on each. Only the LB is public (443); DB/Redis
  have no public IP. Enable the firewall + SSH keys.

### 1. Supabase
```sh
cd infra/supabase
cp .env.example .env
#  Fill every CHANGE_ME. Generate secrets with `openssl rand -base64 48`.
#  Mint ANON_KEY / SERVICE_ROLE_KEY as JWTs signed with JWT_SECRET
#  (https://supabase.com/docs/guides/self-hosting/docker#generate-api-keys).
docker compose up -d
docker compose ps        # all healthy?
```
Studio: `http://<host>:3001` (basic-auth). Configure Apple/Google providers here.

### 2. Database schema (Prisma migrations)
The NestJS API owns the schema via Prisma migrations. Point it at Supabase's
Postgres and apply:
```sh
cd ../../backend
cp .env.example .env
#  DATABASE_URL=postgresql://postgres:<POSTGRES_PASSWORD>@<supabase-host>:5432/postgres?schema=public
#  SUPABASE_JWT_SECRET=<same JWT_SECRET as infra/supabase/.env>
#  REDIS_URL=redis://<redis-host>:6379
npm ci
npx prisma migrate deploy      # creates all tables
npx prisma db seed             # OPTIONAL — dev/staging demo data only, never prod
```

### 3. API + Redis + Load balancer
```sh
cd ../infra
#  Edit docker-compose.yml env (or use an env file) so `api` points at the
#  Supabase Postgres + Redis and carries the shared SUPABASE_JWT_SECRET.
docker compose up -d --build
curl http://localhost:8080/healthz    # 200
curl http://localhost:8080/readyz     # database + redis up
```

### 4. TLS & the apps
- Point DNS (`api.mystables.ae`) at the Hetzner LB; terminate TLS there (or via
  Traefik/Caddy). Set `CORS_ORIGINS` to the dashboard/app origins.
- Build the apps against the API:
  ```sh
  flutter build web \
    --dart-define=API_BASE_URL=https://api.mystables.ae \
    --dart-define=API_STABLE_ID=<from the signed-in membership>
  ```
  (In production the token comes from Supabase Auth at runtime, not dart-define.)
- Deploy the admin console & seller dashboard to Vercel.

---

## Updating everything (the routine)

CI builds and tests on every push; production updates are a short, safe sequence.

### App / API code change
```sh
git pull                                   # get the merged change
cd backend && npm ci                       # if deps changed
npx prisma migrate deploy                  # apply any new migrations (expand/contract, backward-compatible)
cd ../infra && docker compose up -d --build api   # rolling rebuild of the API replicas
```
- Migrations run **before** the new image serves traffic, and are written
  additive-first so a rollback never loses data.
- The API drains in-flight requests on SIGTERM (graceful), so the rolling
  restart is zero-downtime behind the LB.
- **Rollback:** redeploy the previous image tag; the additive migration stays.

### Flutter app / dashboards
```sh
git pull
flutter build web --dart-define=API_BASE_URL=https://api.mystables.ae
#  → redeploy web to Vercel; ship mobile via the app stores.
```

### Supabase upgrade
```sh
cd infra/supabase
#  Bump image tags against the official supabase/docker template (see README),
#  then:
docker compose pull
docker compose up -d
docker compose ps        # verify auth + storage still healthy
```
Take a DB backup first (below). Test sign-in and a file upload after.

### Secrets rotation
Rotate `JWT_SECRET` in **both** `infra/supabase/.env` and `backend/.env`
together (existing sessions re-auth). Rotate DB/dashboard passwords in Studio +
`.env`, then `docker compose up -d`.

---

## Backups & restore

- **Automate** nightly `pg_dump` + continuous WAL archiving to offsite storage
  (Hetzner Storage Box / S3-compatible). Example nightly:
  ```sh
  docker exec mystables-supabase-db-1 pg_dump -U postgres postgres | gzip > backup-$(date +%F).sql.gz
  ```
- **Storage bucket:** back up the `storage-data` volume.
- **Restore drill (monthly):** spin a scratch DB, restore the latest dump, run
  `prisma migrate status` to confirm schema, point a staging API at it.
- Targets: RPO ≤ 5 min (WAL), RTO ≤ 1 hour.

---

## Verify a deploy

- [ ] `GET /healthz` → 200, `GET /readyz` → database + redis up
- [ ] Sign in through the app (Supabase Auth issues a JWT the API accepts)
- [ ] A stable-scoped request returns only that stable's data (RLS + RBAC)
- [ ] Rate-limit headers present; 429 after the limit
- [ ] A file upload to Storage works
- [ ] Dashboards load from Vercel against the API
