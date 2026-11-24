# NocoDB 2026.10.2 (official image, pinned by digest) plus a Railway start script.
ARG NOCODB_IMAGE=nocodb/nocodb:2026.10.2@sha256:c8fd5e028cfd3932fefaae775ea25bf1949ea64b8a042e6582892a14bc216fa9
FROM ${NOCODB_IMAGE}
COPY --chmod=0755 railway-nocodb.sh /usr/src/app/railway-nocodb.sh
COPY --chmod=0644 railway-settings.mjs /usr/src/app/railway-settings.mjs
ENV PORT=8080
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/usr/src/app/railway-nocodb.sh"]
