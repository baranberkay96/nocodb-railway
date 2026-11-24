# NocoDB 2026.10 Airtable Alternative (Postgres, Redis, Worker, S3): composer spec

## Listing

| Field | Value |
|---|---|
| Name | **NocoDB 2026.10 Airtable Alternative (Postgres, Redis, Worker, S3)** |
| Description | Spreadsheet UI on Postgres with a job worker, Redis and Bucket uploads. (71 chars) |
| Category | Other |
| Icon | `https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/nocodb.svg` |
| Repo | `baranberkay96/nocodb-railway`, root `/services/nocodb` (both NocoDB services) |

Version label: NocoDB uses calendar versions (`2026.10.2`); the listing names the release line, no 0.x label.

## Base market templates (checked 2026-11-24)

| Code | Deploys | Notes |
|---|---|---|
| `opu-NU` | 1,942 | NocoDB + worker + Redis + Postgres 18, tag-pinned with auto-updates; volume on the web only (worker cannot see local attachments); first visitor becomes super admin; public Postgres TCP proxy |
| `nocodb-starter-pack` | 34 | `nocodb/nocodb` untagged, Postgres 17 with TCP proxy, no Redis/worker, no healthcheck |
| `nocodb-airtable-alternative` | 13 | `:latest`, Redis, no worker, no healthcheck |

## Services

| Service | Source | Port | Healthcheck | Volume |
|---|---|---|---|---|
| NocoDB | repo `/services/nocodb` (`FROM nocodb/nocodb:2026.10.2@sha256:c8fd5e02…`) | 8080 public | `/api/v1/health` (900 s) | `/usr/app/data` |
| NocoDB Worker | same repo root, `NC_WORKER_CONTAINER=true` | — | — | — |
| Postgres | `postgres-ssl:18.6` | 5432 private | — | `/var/lib/postgresql/data` |
| Redis | `redis:8.2.11` | 6379 private | — | `/data` |
| Bucket | Railway Bucket | — | — | — |

## Design

1. **Super admin from variables** (`NC_ADMIN_EMAIL` required, `NC_ADMIN_PASSWORD` generated): NocoDB creates it before serving, so the first-visitor sign-up cannot claim the instance (8.37).
2. **Invite-only sign-up:** `railway-settings.mjs` signs in as the super admin once `/api/v1/health` answers and sets `invite_only_signup` (an app setting stored in the database, not an env var). Opt out with `NC_INVITE_ONLY_SIGNUP=false`.
3. **Attachments in a private Railway Bucket** (`NC_S3_*`, virtual-hosted URLs) with `NC_SECURE_ATTACHMENTS=true` (signed URLs), so the worker and web share files without a shared volume.
4. **Deploy-form values (8.29):** NocoDB exits on an invalid admin e-mail or a password under 8 characters; the start script falls back to `admin@example.com` or locks the login with a random password and logs how to fix it. Empty optional variables are dropped; a bad `NC_PUBLIC_URL` falls back to the Railway domain.
5. Postgres and Redis stay private (no TCP proxy). `NC_REDIS_URL` is the plain Redis URL: with `?family=0` NocoDB's Bull queue failed with `Connection is closed` (tested).

## Improvements over market templates

- Digest-pinned image, built through a thin wrapper (no silent auto-updates).
- Super admin and invite-only sign-up set automatically; no claimable first sign-up.
- Attachments in a Railway Bucket shared by web and worker (the leader's worker cannot read the web's volume).
- No public database proxy; healthcheck; deploy-form typos do not crash-loop.

## Resources

To be measured on the test deploy (see the report).

## Verification checklist

- [ ] All services SUCCESS; `/api/v1/health` 200.
- [ ] Sign in with the admin variables; create a base, table and record; upload an attachment (Bucket, signed URL).
- [ ] Stranger sign-up refused (invite-only).
- [ ] A CSV import or export runs on the worker.
- [ ] Short `NC_ADMIN_PASSWORD` / bad `NC_ADMIN_EMAIL` do not fail the deploy.

## Open questions

- E-mail plugins (SMTP needs Pro; HTTP plugins untested).
