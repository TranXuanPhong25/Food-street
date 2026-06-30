#!/usr/bin/env bash
# =============================================================================
# Setup server cho bản DOCKER — chỉ cần cài Docker. Chạy MỘT LẦN trên VPS Ubuntu.
#   git clone <repo> /opt/food_street
#   cd /opt/food_street && bash scripts/server_bootstrap_docker.sh
# =============================================================================
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "==> [1/3] Cài Docker Engine + compose plugin (nếu chưa có)"
if ! command -v docker >/dev/null; then
  curl -fsSL https://get.docker.com | sudo sh
  sudo usermod -aG docker "$USER"
  echo "    Đã cài Docker. ĐĂNG XUẤT/ĐĂNG NHẬP lại để dùng docker không cần sudo."
else
  echo "    Docker đã có: $(docker --version)"
fi

echo "==> [2/3] Mở firewall (80/443/SSH)"
if command -v ufw >/dev/null; then
  sudo ufw allow OpenSSH || true
  sudo ufw allow 80/tcp || true
  sudo ufw allow 443/tcp || true
  sudo ufw --force enable || true
fi

echo "==> [3/3] Tạo file .env (nếu chưa có)"
if [ ! -f "$REPO_DIR/.env" ]; then
  cp "$REPO_DIR/.env.prod.example" "$REPO_DIR/.env"
  echo "    ĐÃ TẠO .env — BẮT BUỘC sửa PHX_HOST, SECRET_KEY_BASE, DB_PASS."
else
  echo "    .env đã tồn tại — bỏ qua."
fi

cat <<DONE

==============================================================
 Xong. Bước tiếp theo:
   1. Sửa $REPO_DIR/.env  (PHX_HOST, SECRET_KEY_BASE, DB_PASS)
      - Sinh secret nhanh:  openssl rand -base64 64
      - Dùng IP: PHX_HOST=<ip> và CADDY_EXTRA_TLS="tls internal" (HTTPS tự ký)
      - Có domain: trỏ DNS A record về IP, để CADDY_EXTRA_TLS trống
   2. Deploy:   bash scripts/deploy_remote_docker.sh
   4. Seed dữ liệu (chạy 1 lần, sau khi stack chạy):
        docker compose -f docker-compose.prod.yml exec backend /app/bin/seed
==============================================================
DONE
