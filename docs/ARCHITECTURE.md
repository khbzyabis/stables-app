# My Stables — Architecture & Operations

How the product is built to be secure, scalable, and launchable professionally.
This document is the reference for infrastructure decisions; the running code
under `backend/` and `infra/` implements it.

## 1. The shape of the system

```
                         ┌──────────────────────────────────────────┐
   Mobile app (Flutter)  │              Hetzner Cloud                │
   Provider app          │                                          │
   Seller dashboard  ──►  │  ┌─────────────┐   private network      │
   Admin console         │  │ Load Balancer│  (10.0.0.0/16, no      │
        (HTTPS)          │  │  (Hetzner LB │   public egress on     │
                         │  │  or Traefik) │   app/db tiers)         │
                         │  └──────┬───────┘                        │
                         │         │  TLS terminates here            │
                         │   ┌─────┴──────┐  health checks           │
                         │   ▼            ▼                          │
                         │ ┌──────┐   ┌──────┐   NestJS API tier     │
                         │ │ api-1│   │ api-2│   (stateless,         │
                         │ └──┬───┘   └──┬───┘    horizontally       │
                         │    │          │        scalable)          │
                         │    └────┬─────┘                           │
                         │   ┌─────▼──────┐   ┌───────────┐          │
                         │   │  Supabase  │   │   Redis    │          │
                         │   │  (Postgres,│   │ (rate-limit│          │
                         │   │  Auth,     │   │  + cache)  │          │
                         │   │  Storage,  │   └───────────┘          │
                         │   │  RLS)      │                          │
                         │   └─────┬──────┘   Postgres: primary +    │
                         │         │          streaming replica      │
                         │   ┌─────▼──────┐                          │
                         │   │  Backups   │  nightly + WAL to        │
                         │   │  (offsite) │  Hetzner Storage Box/S3  │
                         │   └────────────┘                          │
                         └──────────────────────────────────────────┘
```

**Tiers, and why they are separate.** The API tier is *stateless* — no session
state, no local files — so we can run N copies behind the load balancer and add
more under load. All state lives in Postgres (durable), Redis (ephemeral), and
Supabase Storage (files). This separation is the thing that makes the system
scalable; everything below serves it.

## 2. Database (Supabase / PostgreSQL)

Supabase is self-hosted on Hetzner (open-source, Docker) and provides Postgres,
Auth (GoTrue), Storage, and Row-Level Security. NestJS is the primary API; it
talks to Postgres through **Prisma**.

### Schema principles
- **One person, many memberships.** A `users` row is a person. A `memberships`
  row ties a user to a stable **with a role** (`admin|trainer|groom|rider`).
  Permissions are always resolved per membership, never per user — this is the
  rule the whole product depends on.
- **Notes follow their author; the horse's records travel with the horse.**
  Health/training notes carry `author_membership_id` and `stable_id`; passport,
  vaccination, feed chart and setups carry `horse_id`. Moving a horse re-points
  `horse.stable_id` but leaves stable-scoped notes behind.
- **Money is on the platform.** Orders, payouts, commissions and disputes are
  first-class tables. Payouts are computed, immutable ledger rows.
- **Soft-delete + legal retention.** Deletion requests run a 30-day clock;
  notes stay under their author's name, receipts stay 7 years (see admin
  console "Leaving").

The initial schema lives in `backend/prisma/schema.prisma`.

### Indexing & scale
- Every foreign key is indexed; hot lookups (horses by stable, tasks by
  stable+day, orders by seller+status) get composite indexes.
- Read-heavy endpoints read from a **streaming replica**; writes go to primary.
- Partition high-volume, time-series tables (audit log, payments) by month when
  they grow.
- Connection pooling via **Supavisor/PgBouncer** (transaction mode) so hundreds
  of API workers share a bounded set of Postgres connections.

## 3. SQL-injection prevention (defense in depth)

1. **Parameterized queries everywhere.** Prisma sends values as bind parameters,
   never string-concatenated SQL. The ORM query builder is the *only* sanctioned
   path for data access. This alone removes the entire class of injection for
   normal code.
2. **No raw SQL with interpolation.** Where raw SQL is unavoidable, use
   `Prisma.sql` tagged templates / `$queryRaw` with parameters — never
   `$queryRawUnsafe` with concatenated input. A lint rule and code-review gate
   forbid `*Unsafe`.
3. **Validate at the edge.** Every request body/param/query passes a
   `class-validator` DTO with a global `ValidationPipe({ whitelist: true,
   forbidNonWhitelisted: true })`. Unknown or wrong-typed fields are rejected
   before they reach a handler.
4. **Least privilege at the DB.** The API connects as a role that can only
   `SELECT/INSERT/UPDATE/DELETE` on application tables — not `DROP`, not
   superuser. Supabase **Row-Level Security** policies enforce that a user only
   ever sees rows for stables they are a member of, so even a logic bug can't
   leak another stable's data.
5. **Migrations are reviewed** and run in CI, never ad-hoc against prod.

## 4. Rate limiting

Two layers:

- **Edge (load balancer / Nginx):** coarse per-IP connection and request caps to
  absorb floods and abusive clients before they reach the app
  (`limit_req_zone`). Config in `infra/nginx/`.
- **Application (NestJS `@nestjs/throttler` backed by Redis):** precise,
  per-identity limits that are correct across all API replicas because the
  counter lives in Redis, not in each process. Tiers:
  - Global default: e.g. 100 req / 60s per user/IP.
  - **Auth endpoints** (sign-in, verify, resend code): strict, e.g. 5–10 / 15
    min per IP+account, to stop credential stuffing and SMS-cost abuse.
  - **Expensive/abusable actions** (quote requests, order creation): their own
    tighter buckets.
  - Responses send `Retry-After` and `429` so clients back off cleanly.

Redis also holds short-TTL caches (feature flags, fee tables, session lookups)
to keep hot reads off Postgres.

## 5. Load balancing & horizontal scale

- **Load balancer** (Hetzner Cloud LB, or Traefik/Nginx on a small node)
  terminates TLS and spreads traffic across API replicas using least-connections,
  with **health checks** hitting `/healthz` (liveness) and `/readyz`
  (readiness — checks DB + Redis). Unhealthy replicas are pulled automatically.
- **Stateless API replicas.** Because no request depends on which replica served
  the last one, scaling is "run more containers." Start with 2 (HA — surviving a
  node reboot), scale by CPU/latency.
- **Graceful shutdown & zero-downtime deploys.** The app traps SIGTERM, stops
  accepting new requests, drains in-flight ones, then exits; the LB has already
  stopped routing to it. Rolling deploys bring up new replicas before retiring
  old ones.
- **Sticky where needed only.** Realtime/WebSocket connections (Supabase
  Realtime) use their own path; the REST API needs no stickiness.
- **Autoscaling path.** Compose is fine for launch (2–3 nodes). When traffic
  warrants, the same containers move to **k3s** (lightweight Kubernetes on
  Hetzner) with a Horizontal Pod Autoscaler — no app changes, because the app is
  already stateless and containerized.

## 6. Security (beyond SQL injection)

- **TLS everywhere**, HSTS, modern ciphers; auto-renew via ACME.
- **Auth:** Supabase Auth (email+password, Apple, Google, invite codes) issues
  JWTs; the API verifies them and resolves the caller's memberships/roles per
  request. Passwords hashed by GoTrue (bcrypt). Refresh-token rotation.
- **RBAC guards** in NestJS mirror the role matrix (admin/trainer/groom/rider,
  and the console's owner/finance/ops/support/marketing).
- **Secrets** never in git — `.env` locally, a secrets manager / Hetzner
  environment on servers. `.env.example` documents the shape.
- **Security headers** via Helmet (CSP, X-Content-Type-Options, frame-deny).
- **CORS** locked to known app origins.
- **Input/output:** whitelist DTOs in, serialization DTOs out (never leak DB
  columns like password hashes).
- **PII & compliance:** UAE market — VAT/TRN on receipts, 7-year receipt
  retention, 30-day deletion clock, notes retained under author name. Audit log
  is append-only.
- **Firewall:** only the LB is public (443). App, Postgres, Redis sit on the
  private network with no public IPs. SSH via key + fail2ban.
- **Dependency & image scanning** in CI; least-privilege, non-root containers.

## 7. Observability

- **Health:** `/healthz`, `/readyz` for the LB.
- **Metrics:** Prometheus (API + node + Postgres exporters) → Grafana dashboards
  (latency, error rate, saturation, DB connections, payout job runs).
- **Logs:** structured JSON (pino), shipped to Loki (or a hosted sink).
- **Errors:** Sentry for API and Flutter.
- **Alerts:** on error-rate, p99 latency, DB replica lag, disk, and failed
  payout/cron jobs.

## 8. Background jobs

Money and messaging need reliable async work (a Redis-backed **BullMQ** queue,
run by dedicated worker containers):
- **Payout cycles** on the 1st and 15th — compute per-seller transfers from the
  ledger, idempotently.
- **14-day return window** closes → release held funds.
- **SMS verification, machine-translation on read, notification fan-out.**
- Jobs are idempotent and retried with backoff; failures alert.

### Push notifications
Order/quote/transport updates, task assignments, notices, declined-card and
chat all need push.
- **Transport:** **FCM** for Android and **APNs** for iOS (FCM as the unified
  sender is simplest; APNs directly is also supported). Web dashboards use Web
  Push where useful.
- **Device tokens:** the Flutter app registers its FCM/APNs token on login; the
  API stores it in `device_tokens` (per user, per platform) and prunes stale
  tokens on delivery failure.
- **Sending:** a `notifications` BullMQ worker fans out from domain events
  (e.g. "quote accepted") to the right recipients' tokens, respecting per-user
  language and quiet hours. In-app notifications are persisted too, so the
  Notifications screen works without relying on push delivery.
- **Preferences & privacy:** per-category opt-outs; never leak stable data in a
  notification body beyond what the recipient may see.

### Where each surface runs
- **NestJS API + workers + Supabase + Redis:** Hetzner (long-running, stateful).
- **Admin console & seller dashboard (web) and the Flutter web preview:**
  static/edge builds, deployable to **Vercel** (or Hetzner behind the same LB).
  These are clients of the API; they hold no server state.

## 9. CI/CD & environments

- **Environments:** local (Docker Compose) → staging (one Hetzner node) →
  production (LB + ≥2 app nodes + DB primary/replica).
- **CI (GitHub Actions):** lint, typecheck, unit/integration tests (API against a
  throwaway Postgres), `flutter analyze` + tests, build Docker images, scan them,
  run `prisma migrate` against a scratch DB to prove migrations apply.
- **CD:** on merge to `main`, build & push images to a registry, then rolling
  deploy to staging automatically and to production on tag/approval. Migrations
  run as a pre-deploy step, backward-compatible (expand/contract pattern).
- **Rollback:** images are immutable and tagged; roll back by redeploying the
  previous tag. DB migrations are always additive-then-cleanup so a rollback
  never loses data.

## 10. Backups & disaster recovery

- **Postgres:** nightly base backup + continuous WAL archiving to offsite
  storage (Hetzner Storage Box / S3-compatible). Test restores monthly.
- **Storage bucket:** versioned, replicated.
- **RPO ≤ 5 min** (WAL), **RTO ≤ 1 hour** (documented restore runbook).
- **Streaming replica** doubles as read-scaling and fast failover.

## 11. Launch checklist (professional go-live)

- [ ] Domains + TLS (apex + api + admin), HSTS preloaded.
- [ ] Secrets provisioned; no secrets in git (scanner in CI).
- [ ] DB migrations applied on staging, load-tested (k6) to target RPS.
- [ ] Rate limits tuned against the load test; 429s verified.
- [ ] Backups running and a **restore rehearsed**.
- [ ] Monitoring dashboards + alerts live; on-call defined.
- [ ] Feature flags: **Shows OFF, Market OFF** at launch (per handoff), Adverts
      as decided.
- [ ] App store builds signed (iOS/Android); privacy nutrition labels.
- [ ] Legal: terms, privacy, VAT/TRN on receipts, data-deletion flow.
- [ ] Runbooks: deploy, rollback, restore, incident.
- [ ] Pen-test / `security-review` pass on the API.

## 12. Cost & scale trajectory

- **Launch:** LB + 2 small app nodes + 1 DB node (+replica) + Redis. Handles
  early load with headroom; ~a handful of CX-class Hetzner servers.
- **Growth:** add app replicas (cheap, stateless), promote DB node, add read
  replicas, move Compose → k3s + HPA.
- The architecture doesn't change as you grow — you add replicas, not rewrites.
