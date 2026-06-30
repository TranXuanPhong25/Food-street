#!/usr/bin/env bash
# =============================================================================
# Chạy TRÊN SERVER (bản Docker). deploy.sh gọi qua SSH sau khi git pull.
# Build lại image + chạy lại stack. Migration tự chạy trong container backend.
#
# Chạy thủ công trên server:
#   cd /opt/food_street && git pull && bash scripts/deploy_remote_docker.sh
# =============================================================================
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_DIR"

COMPOSE="docker compose -f docker-compose.prod.yml"

[ -f .env ] || { echo "LỖI: thiếu file .env (copy từ .env.prod.example)"; exit 1; }

echo "==> Build + khởi động stack (db + backend + web)"
$COMPOSE up -d --build

echo "==> Dọn image cũ không dùng"
docker image prune -f >/dev/null 2>&1 || true

echo "==> Trạng thái"
$COMPOSE ps

echo "==> Health check (chờ backend sẵn sàng)"
for i in $(seq 1 30); do
  if $COMPOSE exec -T backend /app/bin/food_street rpc "1+1" >/dev/null 2>&1; then
    echo "✓ Backend OK"
    exit 0
  fi
  sleep 2
done
echo "✗ Backend chưa phản hồi sau 60s — xem log: $COMPOSE logs backend"
exit 1
