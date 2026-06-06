# Runtime-only image — the OTP release must be built on the host before docker build.
# Build first:  MIX_ENV=live mix deps.get --only live && MIX_ENV=live mix release
# Then:         docker build -t setmyinfo/calculator-app:latest .
FROM almalinux:10-minimal

# SQLite NIF, OpenSSL (Erlang crypto), ncurses (ERTS), UTF-8 locale, TLS certs
RUN microdnf install -y \
        sqlite-libs \
        openssl-libs \
        ncurses-libs \
        glibc-langpack-en \
        shadow-utils \
        ca-certificates \
    && microdnf clean all

ENV LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

RUN useradd --create-home --shell /bin/sh calculator

WORKDIR /home/calculator

# Pre-built OTP release (includes bundled ERTS — no Elixir/Erlang needed here)
COPY --chown=calculator:calculator _build/live/rel/calculator_app ./

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
