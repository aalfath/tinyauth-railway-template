#!/bin/sh
# Railway wrapper for Tinyauth: derives the settings Railway can provide, creates the
# admin user from ADMIN_USERNAME / ADMIN_PASSWORD, then starts the upstream binary.
set -eu

# Listen on Railway's PORT.
export TINYAUTH_SERVER_PORT="${TINYAUTH_SERVER_PORT:-${PORT:-3000}}"
export TINYAUTH_SERVER_ADDRESS="${TINYAUTH_SERVER_ADDRESS:-0.0.0.0}"

# Public URL: the Railway domain unless the deployer set one.
if [ -z "${TINYAUTH_APPURL:-}" ] && [ -n "${RAILWAY_PUBLIC_DOMAIN:-}" ]; then
  export TINYAUTH_APPURL="https://${RAILWAY_PUBLIC_DOMAIN}"
fi
if [ -z "${TINYAUTH_APPURL:-}" ]; then
  echo "railway-start: set TINYAUTH_APPURL (for example https://auth.YOUR-DOMAIN) or add a public domain" >&2
  exit 1
fi

# *.up.railway.app is on the public suffix list, so cookies can't be shared with sibling
# subdomains there. Keep subdomain cookies off on Railway domains; on your own domain the
# upstream default (on) applies unless you set TINYAUTH_AUTH_SUBDOMAINSENABLED.
case "$TINYAUTH_APPURL" in
  *.up.railway.app|*.up.railway.app/*) export TINYAUTH_AUTH_SUBDOMAINSENABLED="${TINYAUTH_AUTH_SUBDOMAINSENABLED:-false}" ;;
esac
case "$TINYAUTH_APPURL" in
  https://*) export TINYAUTH_AUTH_SECURECOOKIE="${TINYAUTH_AUTH_SECURECOOKIE:-true}" ;;
esac

# No Docker socket or Kubernetes API on Railway: skip label discovery.
export TINYAUTH_LABELPROVIDER="${TINYAUTH_LABELPROVIDER:-none}"

# Admin user from plain variables. Tinyauth wants username:bcrypt-hash, so hash it here
# on every boot: changing ADMIN_PASSWORD and redeploying changes the password.
if [ -n "${ADMIN_PASSWORD:-}" ]; then
  ADMIN_USERNAME="${ADMIN_USERNAME:-admin}"
  hash_line="$(NO_COLOR=1 tinyauth user create --username "$ADMIN_USERNAME" --password "$ADMIN_PASSWORD" \
    | grep -m1 -- '--auth.users=' | sed 's/^.*--auth\.users=//' | tr -d '[:space:]')"
  case "$hash_line" in
    "$ADMIN_USERNAME":\$2*) ;;
    *) echo "railway-start: could not hash ADMIN_PASSWORD" >&2; exit 1 ;;
  esac
  if [ -n "${TINYAUTH_AUTH_USERS:-}" ]; then
    export TINYAUTH_AUTH_USERS="${hash_line},${TINYAUTH_AUTH_USERS}"
  else
    export TINYAUTH_AUTH_USERS="$hash_line"
  fi
fi
unset ADMIN_PASSWORD

mkdir -p /data/resources /data/oidc
exec tinyauth "$@"
