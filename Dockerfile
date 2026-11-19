# Tinyauth v5.2.0, official image pinned by version and digest.
FROM ghcr.io/tinyauthapp/tinyauth:v5.2.0@sha256:220aa235c76393a73fece831d7ba967b8698d3907fd8e3c4c952f699c7b142a5

COPY start.sh /usr/local/bin/railway-start.sh
RUN chmod 755 /usr/local/bin/railway-start.sh

# All state (SQLite database, OIDC signing keys, resources) lives here. Mount a volume on /data.
VOLUME ["/data"]

ENTRYPOINT ["/usr/local/bin/railway-start.sh"]
