# Notice

This repository is a Railway template package for NocoDB. It contains configuration and small start scripts written for this template (MIT-licensed); it does not contain NocoDB source code.

| Component | License | Used as |
|---|---|---|
| NocoDB 2026.10.2 | Sustainable Use License 1.0 (master/develop branches, updated 2026-01-29); third-party components under their own licenses | Official image `nocodb/nocodb:2026.10.2@sha256:c8fd5e02…`, extended with our start script |
| PostgreSQL 18 | PostgreSQL License | `ghcr.io/railwayapp-templates/postgres-ssl:18.6` (Railway) |
| Redis 8.2 | RSALv2 / SSPLv1 / AGPLv3 | `redis:8.2.11` (official image, unmodified) |

## NocoDB license caveat (summary, not legal advice)

NocoDB is fair-code, not open source. The Sustainable Use License lets you use and modify the software only for your own internal business purposes or for non-commercial or personal use, and lets you distribute it only free of charge for non-commercial purposes. Deploying this template to run NocoDB for your own organisation is within those terms; hosting NocoDB as a paid service for others is not. Older releases (before the change) were AGPL-3.0. Full text: https://github.com/nocodb/nocodb/blob/develop/LICENSE.md

## Upstream files checked

- `docker-compose/1_Auto_Upstall/tests/golden/external-pg-and-redis/docker-compose.yml` and `docker-compose/examples/external-postgres-and-redis/docker-compose.yml` at tag `2026.10.2` (web + worker layout)
- `packages/nocodb/src/helpers/initAdminFromEnv.ts`, `packages/nocodb-sdk/src/lib/passwordHelpers.ts`, `packages/nocodb/src/helpers/NcPluginMgrv2.ts`, `packages/nocodb/src/utils/envs.ts`, `packages/nocodb/src/services/users/users.service.ts`, `packages/nocodb/src/controllers/org-users.controller.ts`
- Image config of `nocodb/nocodb:2026.10.2` (entrypoint `dumb-init`, command `/usr/src/appEntry/start.sh`)

NocoDB is a trademark of NocoDB Inc. This community template is not affiliated with or endorsed by NocoDB Inc.
