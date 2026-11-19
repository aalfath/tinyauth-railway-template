# Tinyauth on Railway

Railway template for [Tinyauth](https://tinyauth.app) ([tinyauthapp/tinyauth](https://github.com/tinyauthapp/tinyauth)), a small, OpenID Certified login server: a login page, forward-auth for reverse proxies, and an OpenID Connect provider for your other apps.

## What it deploys

One service, **Tinyauth**, built from this repo:

| | |
|---|---|
| Tinyauth | **v5.2.0** (2026-09-07) |
| Base image | `ghcr.io/tinyauthapp/tinyauth:v5.2.0@sha256:220aa235c76393a73fece831d7ba967b8698d3907fd8e3c4c952f699c7b142a5` (official image) |
| Volume | `/data`: the SQLite database (sessions, OIDC state), the OIDC signing keys and the resources folder |
| Health check | `/api/healthz` |

`start.sh` is the only addition to the upstream image. It points Tinyauth at Railway's `PORT` and public domain, creates the admin user from two plain variables, turns off Docker/Kubernetes label discovery (Railway has neither), and then runs the upstream `tinyauth` binary.

## Variables

| Variable | Default | Notes |
|---|---|---|
| `ADMIN_USERNAME` | `admin` | Username of the local admin user. |
| `ADMIN_PASSWORD` | `${{secret(24)}}` | Generated password for that user. Read it in the service's Variables tab. It's bcrypt-hashed on every boot, so changing it and redeploying changes the password. |
| `PORT` | `3000` | Port Tinyauth listens on. |

There are no prompts. Any other [Tinyauth setting](https://tinyauth.app/docs/reference/configuration) can be added as a `TINYAUTH_*` variable on the service, for example:

- `TINYAUTH_APPURL`: set it to `https://auth.YOUR-DOMAIN` once you add a custom domain. It defaults to the Railway domain.
- `TINYAUTH_AUTH_USERS`: more local users (`user:bcrypt-hash`, comma-separated); the admin is added in front of them.
- `TINYAUTH_OAUTH_PROVIDERS_<name>_*`: sign-in with GitHub, Google or any OAuth/OIDC provider.
- `TINYAUTH_OIDC_CLIENTS_<name>_*`: OIDC clients (apps that use Tinyauth as their identity provider).
- `TINYAUTH_ANALYTICS_ENABLED=false`: turns off upstream's periodic version check-in.

**Subdomain cookies.** `*.up.railway.app` is a public suffix, so a session can't be shared with other `*.up.railway.app` apps. On the Railway domain `start.sh` sets `TINYAUTH_AUTH_SUBDOMAINSENABLED=false`. To protect several apps with one login (forward-auth), put Tinyauth on a custom domain such as `auth.YOUR-DOMAIN` and set `TINYAUTH_APPURL` to it; subdomain cookies then default to on.

## Updates

Every change to this repo's `main` branch (a new Tinyauth release, a wrapper fix) shows up as an "update available" notice in the Railway projects deployed from this template. Read `CHANGELOG.md` before applying one. Your data stays on the `/data` volume across updates.
