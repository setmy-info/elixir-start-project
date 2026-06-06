# ── Stage 1: build OTP release ────────────────────────────────────────────────
FROM elixir:1.18-slim AS builder

WORKDIR /build

RUN apt-get update -q && \
    apt-get install -y --no-install-recommends build-essential git && \
    rm -rf /var/lib/apt/lists/*

ENV MIX_ENV=live

# Imre
#RUN mix local.hex --force && mix local.rebar --force

# Fetch deps first — layer is cached until mix.exs or mix.lock changes
COPY mix.exs mix.lock ./

# Imre
#RUN mix deps.get --only live
RUN mix deps.get

# Config is read at compile time (config.exs imports live.exs)
COPY config/ config/

# Application source and priv (static assets, example TOML config)
COPY lib/ lib/
COPY priv/ priv/

RUN mix deps.compile && mix release

# ── Stage 2: minimal runtime ───────────────────────────────────────────────────
FROM debian:bookworm-slim AS runtime

# SQLite driver, OpenSSL (crypto), ncurses (ERTS interactive mode), locale, certs
RUN apt-get update -q && \
    apt-get install -y --no-install-recommends \
        libsqlite3-0 libssl3 libncurses6 locales ca-certificates && \
    locale-gen en_US.UTF-8 && \
    rm -rf /var/lib/apt/lists/*

ENV LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

RUN useradd --create-home --shell /bin/sh calculator

WORKDIR /home/calculator

# Self-contained OTP release (includes bundled ERTS — no Elixir/Erlang needed here)
COPY --from=builder --chown=calculator:calculator /build/_build/live/rel/calculator_app ./

RUN mkdir -p log && chown calculator:calculator log

USER calculator

# Defaults — all can be overridden with -e at docker run time
ENV CALCULATOR_SERVER=true \
    PORT=4000 \
    CALCULATOR_LOG_DIR=/home/calculator/log \
    CALCULATOR_LOG_FILE=calculator_app.log \
    CALCULATOR_LOG_LEVEL=info

EXPOSE 4000

# `start` keeps the VM in the foreground — correct entry point for Docker
CMD ["bin/calculator_app", "start"]
