# My Stables — API (NestJS)

The business-logic tier over self-hosted Supabase/Postgres. Stateless and
horizontally scalable; see [`../docs/ARCHITECTURE.md`](../docs/ARCHITECTURE.md).

## What's here (foundation)

- **NestJS 10** app with URI versioning (`/v1/...`), Helmet security headers,
  locked CORS, global `ValidationPipe` (whitelist), graceful shutdown.
- **Prisma + PostgreSQL** — all data access is parameterized (SQL-injection safe
  by construction); an ESLint rule forbids `$queryRawUnsafe`/`$executeRawUnsafe`.
- **Redis-backed rate limiting** (`@nestjs/throttler`) — correct across all
  replicas; tighter buckets on write/auth routes.
- **Supabase JWT auth guard** + **per-membership RBAC guard** (admin / trainer /
  groom / rider).
- **Health checks** — `/healthz` (liveness) and `/readyz` (DB + Redis) for the
  load balancer.
- **Structured JSON logging** (pino) with auth-header redaction.
- Sample **Horses** resource showing the full pattern (validated DTO →
  parameterized query → RBAC → per-route throttle).

## Run it

### Everything at once (Docker)

```sh
cd ../infra
docker compose up --build
# API behind the Nginx load balancer at http://localhost:8080
```

### Locally (Node + your own Postgres/Redis)

```sh
cp .env.example .env      # then edit secrets
npm install
npx prisma migrate deploy # apply migrations
npm run start:dev
```

## Verify (what the smoke test checks)

```sh
curl localhost:3000/healthz            # 200
curl localhost:3000/readyz             # database + redis up
# With a Supabase JWT in $TOKEN:
curl -H "Authorization: Bearer $TOKEN" localhost:3000/v1/stables/<id>/horses
```

- No token → 401. Wrong role → 403. Missing/unknown fields → 400.
- A horse named `Rob; DROP TABLE horses;--` is stored as a plain string — the
  table is untouched (parameterized queries).

## Layout

```
prisma/schema.prisma     data model (+ migrations/)
src/main.ts              bootstrap: security, validation, versioning
src/app.module.ts        wiring + global rate limiter
src/common/              auth guard, RBAC guard, decorators
src/prisma, src/redis    shared clients
src/health               liveness/readiness
src/horses               sample resource (the pattern to copy)
```
