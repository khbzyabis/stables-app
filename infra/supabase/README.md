# Self-hosted Supabase

Postgres + Auth + Storage + Realtime + Studio for My Stables, wired for the
NestJS API to sit on top. See [`../../docs/DEPLOY.md`](../../docs/DEPLOY.md) for
the full Hetzner deploy and update workflow.

## Run

```sh
cp .env.example .env         # then fill in every CHANGE_ME (see the file)
docker compose up -d
```

- **Studio (admin UI):** http://localhost:3001 (basic-auth from `.env`)
- **API gateway (Kong):** http://localhost:8000 — apps use `/auth/v1`, `/rest/v1`,
  `/storage/v1`, `/realtime/v1`
- **Postgres:** localhost:5432 — the NestJS API connects here

## The one rule that ties it together

The NestJS API and Supabase Auth must share the **same `JWT_SECRET`**. GoTrue
signs user tokens with it; the API (`SUPABASE_JWT_SECRET` in `backend/.env`)
verifies them with it. Set both to the same value.

## Keeping it current

This compose tracks the official
[`supabase/docker`](https://github.com/supabase/supabase/tree/master/docker)
template, trimmed to the services this product uses. When upgrading Supabase,
bump the image tags here against that template and re-test auth + storage.
