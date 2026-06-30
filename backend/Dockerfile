# Dockerfile PRODUCTION cho backend Phoenix (mix release đa tầng).
# Build: docker compose -f docker-compose.prod.yml build backend

# ---- Tầng build ----
FROM hexpm/elixir:1.18.3-erlang-27.3-debian-bookworm-20250317-slim AS build

RUN apt-get update -y && \
    apt-get install -y build-essential git && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app
RUN mix local.hex --force && mix local.rebar --force

ENV MIX_ENV=prod

# Cache deps
COPY mix.exs mix.lock ./
RUN mix deps.get --only prod
RUN mix deps.compile

# Mã nguồn + build release
COPY config config
COPY priv priv
COPY lib lib
COPY rel rel

RUN mix compile
RUN mix release

# ---- Tầng runtime (nhỏ gọn) ----
FROM debian:bookworm-slim AS app

RUN apt-get update -y && \
    apt-get install -y libstdc++6 libncurses6 openssl ca-certificates locales && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Locale UTF-8 (tên món tiếng Việt)
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen
ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8

WORKDIR /app
ENV MIX_ENV=prod PHX_SERVER=true

# Copy release đã build
COPY --from=build /app/_build/prod/rel/food_street ./

EXPOSE 4003

# Chạy migration rồi khởi động server (migrate idempotent)
CMD ["/bin/sh", "-c", "/app/bin/migrate && /app/bin/server"]
