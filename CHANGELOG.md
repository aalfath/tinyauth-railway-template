# Changelog

## 5.2.0-r2 (2026-11-19)

No breaking changes. README only: adds the Deploy on Railway button for the published template `tinyauth`. Nothing to do on applied deploys.

## 5.2.0-r1 (2026-11-19)

First release of this template.

- Tinyauth v5.2.0, official image `ghcr.io/tinyauthapp/tinyauth:v5.2.0` pinned by digest `sha256:220aa235c76393a73fece831d7ba967b8698d3907fd8e3c4c952f699c7b142a5`.
- Admin user from `ADMIN_USERNAME` and a generated `ADMIN_PASSWORD`, hashed at boot. No default password.
- All state on one volume at `/data`. Health check `/api/healthz`.
