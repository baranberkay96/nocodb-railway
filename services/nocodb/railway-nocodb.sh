#!/bin/sh
# Railway start script for NocoDB (web service and worker).
# - NocoDB exits on an invalid NC_ADMIN_EMAIL or a password under 8 characters; repair or lock instead
#   so a deploy-form typo never fails the deploy (STANDARD 8.29)
# - the web service turns on invite-only sign-up once the API is up (NC_INVITE_ONLY_SIGNUP)
set -u
cd /usr/src/app
log() { echo "[railway-nocodb] $*"; }

for var in $(env | sed -n 's/^\([A-Za-z_][A-Za-z0-9_]*\)=$/\1/p'); do unset "$var"; done
case "${PORT:-}" in ''|*[!0-9]*) export PORT=8080 ;; esac

NC_ADMIN_EMAIL="$(printf '%s' "${NC_ADMIN_EMAIL:-}" | tr -d ' \t' | tr 'A-Z' 'a-z')"
if ! printf '%s' "$NC_ADMIN_EMAIL" | grep -Eq '^[^@ ]+@[^@ ]+\.[^@ ]+$'; then
  log "WARNING: NC_ADMIN_EMAIL '${NC_ADMIN_EMAIL}' is not an e-mail address; using admin@example.com"
  NC_ADMIN_EMAIL=admin@example.com
fi
export NC_ADMIN_EMAIL
NC_ADMIN_PASSWORD="${NC_ADMIN_PASSWORD:-}"
if [ "${#NC_ADMIN_PASSWORD}" -lt 8 ]; then
  # NocoDB re-applies NC_ADMIN_PASSWORD on every start, so this locks the super admin until it is fixed.
  NC_ADMIN_PASSWORD="$(head -c 32 /dev/urandom | od -An -tx1 | tr -d ' \n')"
  log "WARNING: NC_ADMIN_PASSWORD must have at least 8 characters. The super admin login is locked with a random password; set a valid NC_ADMIN_PASSWORD and redeploy."
fi
export NC_ADMIN_PASSWORD

case "${NC_PUBLIC_URL:-}" in
  http://?*|https://?*) ;;
  *) export NC_PUBLIC_URL="https://${RAILWAY_PUBLIC_DOMAIN:-localhost}"; log "WARNING: NC_PUBLIC_URL is not a URL; using $NC_PUBLIC_URL" ;;
esac

if [ "${NC_WORKER_CONTAINER:-false}" = "true" ]; then
  log "starting NocoDB worker (background jobs: imports, exports, duplication, webhooks)"
else
  [ "${NC_INVITE_ONLY_SIGNUP:-true}" = "true" ] && node /usr/src/app/railway-settings.mjs &
  log "starting NocoDB on [::]:${PORT}"
fi
exec /usr/src/appEntry/start.sh
