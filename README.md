# Deploy and Host NocoDB with Railway

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/nocodb-202610-airtable-alternative-postg?referralCode=20H68q)

NocoDB turns a PostgreSQL database into a collaborative spreadsheet: grids, forms, kanban, gallery and calendar views, plus REST APIs for every table. This template runs NocoDB 2026.10 with a background job worker, PostgreSQL 18, Redis and a Railway Bucket for attachments.

## About Hosting NocoDB

A production NocoDB installation has a web service that serves the app and APIs, and a worker that runs long jobs such as CSV and Airtable imports, exports, base duplication and webhooks. They share a PostgreSQL metadata database, a Redis job queue and a file store. Upstream's compose file shares one Docker volume between the two; Railway volumes belong to a single service, so this template stores attachments in a private Railway Bucket and serves them through signed URLs.

The super admin is created from your variables on the first start, so nobody can claim the instance before you, and sign-up is switched to invite-only.

## Common Use Cases

- Replace Airtable or shared spreadsheets with a database your team edits in the browser
- Build forms, kanban boards and calendars on top of PostgreSQL tables
- Give scripts and other apps a REST API to your data
- Import CSV, Excel or Airtable bases and keep working on them
- Manage project trackers, CRMs and inventories without writing code

## Dependencies for NocoDB Hosting

- NocoDB 2026.10.2 (official image, pinned by digest)
- PostgreSQL 18 (Railway's `postgres-ssl` image)
- Redis 8.2
- A Railway Bucket for attachments

### Deployment Dependencies

- NocoDB source: https://github.com/nocodb/nocodb
- Self-hosting docs: https://nocodb.com/docs/self-hosting/installation/docker-compose
- Environment variables: https://nocodb.com/docs/self-hosting/environment-variables
- Railway Buckets: https://docs.railway.com/guides/storage-buckets

### Implementation Details

| Service | What it does | Public |
|---|---|---|
| NocoDB | Web app and REST APIs; creates the super admin; invite-only sign-up | yes |
| NocoDB Worker | Imports, exports, duplication, webhooks (Redis job queue) | no |
| Postgres | NocoDB metadata and the tables you create | no |
| Redis | Cache and job queue | no |
| Bucket | Attachments (private, signed URLs) | no |

**First login**

1. Enter your e-mail in `NC_ADMIN_EMAIL` when you deploy.
2. Open the **NocoDB** URL and sign in with `NC_ADMIN_EMAIL` and the generated `NC_ADMIN_PASSWORD` from the NocoDB service's Variables tab.
3. Invite teammates from Team & Settings. Sign-up without an invitation is off (`NC_INVITE_ONLY_SIGNUP=true`).

**Password.** NocoDB re-applies `NC_ADMIN_PASSWORD` to the super admin on every start. To change it, change the variable and redeploy; a value under 8 characters locks the login until it is fixed (the start log explains).

**E-mail.** Invitations and password resets need an e-mail plugin. Railway allows outbound SMTP only on Pro (`NC_SMTP_*`); on other plans use one of the HTTP e-mail plugins in NocoDB's App Store, or copy invite links from the UI.

**Custom domain.** Add it to the NocoDB service and set `NC_PUBLIC_URL` to `https://{your-domain}`; the worker references it. Redeploy both.

**Scaling and versions.** Add worker replicas for heavy import or export loads; keep one web replica unless you also share sessions through Redis. The image is pinned by digest in `services/nocodb/Dockerfile`. To upgrade, change the tag and digest to a newer release, back up Postgres and redeploy; migrations run on start.

**Resources.** Measured idle on Railway: NocoDB 0.6 GB, worker 0.3–0.6 GB, Postgres 0.07 GB, Redis 0.03 GB; about 1–1.3 GB in total, roughly $10–15 per month plus Bucket storage. Hobby is recommended (the Trial plan's 1 GB per service leaves little headroom).

**License.** NocoDB is published under the Sustainable Use License (fair-code, since January 2026): you may use and modify it for your own internal business purposes or non-commercial use; you may not sell it or offer it to others as a paid service. This is a community template; it is not affiliated with NocoDB Inc.

### Why Deploy NocoDB on Railway?

Railway runs NocoDB, its worker, PostgreSQL, Redis and file storage in one project with private networking and HTTPS. You get upstream's production layout with the admin account and invite-only sign-up already set, and you can add a domain or worker replicas from the dashboard.
