# Dockerfile PRODUCTION cho frontend: build React (Vite) rồi serve bằng Caddy
# (tự động HTTPS Let's Encrypt) + proxy /api sang backend.

# ---- Tầng build ----
FROM node:20-slim AS build
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
COPY . .
# Dùng .env.production -> VITE_API_URL=/api (gọi API cùng origin)
RUN npm run build

# ---- Tầng serve (Caddy) ----
FROM caddy:2-alpine AS app
COPY --from=build /app/dist /srv
COPY Caddyfile /etc/caddy/Caddyfile
EXPOSE 80 443
