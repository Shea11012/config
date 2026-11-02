FROM caddy:builder AS builder

ENV GIT_TERMINAL_PROMPT=0 \
    GIT_ASKPASS=/bin/true \
    GOPROXY=https://proxy.golang.org,direct

RUN git config --global credential.helper "" || true
RUN xcaddy build \
    --with github.com/git001/caddyv2-upload

FROM caddy:latest

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
