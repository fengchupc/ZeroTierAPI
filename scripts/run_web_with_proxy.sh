#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

PROXY_HOST="${PROXY_HOST:-127.0.0.1}"
PROXY_PORT="${PROXY_PORT:-3000}"
WEB_HOST="${WEB_HOST:-127.0.0.1}"
WEB_PORT="${WEB_PORT:-8080}"
MODE="${MODE:-release}"

if [[ "${1:-}" == "--debug" ]]; then
  MODE="debug"
elif [[ "${1:-}" == "--release" ]]; then
  MODE="release"
fi

if ! command -v flutter >/dev/null 2>&1; then
  if [[ -x "$HOME/tools/flutter/bin/flutter" ]]; then
    export PATH="$HOME/tools/flutter/bin:$PATH"
  fi
fi

if ! command -v flutter >/dev/null 2>&1; then
  echo "[ERROR] flutter 未找到。请先安装 Flutter 或配置 PATH。"
  exit 1
fi

if ! command -v dart >/dev/null 2>&1; then
  echo "[ERROR] dart 未找到。请先安装 Flutter/Dart 或配置 PATH。"
  exit 1
fi

is_port_in_use() {
  local port="$1"
  if command -v ss >/dev/null 2>&1; then
    ss -ltn "sport = :${port}" | tail -n +2 | grep -q .
    return $?
  fi

  if command -v lsof >/dev/null 2>&1; then
    lsof -iTCP:"${port}" -sTCP:LISTEN -t >/dev/null 2>&1
    return $?
  fi

  return 1
}

echo "[1/3] 准备依赖..."
flutter pub get

if is_port_in_use "$PROXY_PORT"; then
  echo "[2/3] 代理端口 ${PROXY_PORT} 已被占用，跳过启动 proxy。"
  echo "      若该端口不是本项目代理，请修改 PROXY_PORT 后重试。"
else
  LOG_DIR="$ROOT_DIR/.logs"
  mkdir -p "$LOG_DIR"
  PROXY_LOG="$LOG_DIR/proxy-${PROXY_PORT}.log"

  echo "[2/3] 启动 proxy: ${PROXY_HOST}:${PROXY_PORT} (后台)"
  PROXY_HOST="$PROXY_HOST" PROXY_PORT="$PROXY_PORT" \
    nohup dart run bin/proxy_server.dart >"$PROXY_LOG" 2>&1 &

  sleep 1
  if is_port_in_use "$PROXY_PORT"; then
    echo "      proxy 已启动，日志: $PROXY_LOG"
  else
    echo "      [WARN] proxy 可能启动失败，请检查日志: $PROXY_LOG"
  fi
fi

if is_port_in_use "$WEB_PORT"; then
  echo "[3/3] Web 端口 ${WEB_PORT} 已被占用，跳过启动 Flutter web。"
  echo "      如果已有服务在该端口，可直接访问: http://${WEB_HOST}:${WEB_PORT}"
  exit 0
fi

echo "[3/3] 启动 Flutter web (${MODE}): http://${WEB_HOST}:${WEB_PORT}"
if [[ "$MODE" == "debug" ]]; then
  flutter run -d web-server --web-hostname "$WEB_HOST" --web-port "$WEB_PORT"
else
  flutter run -d web-server --release --web-hostname "$WEB_HOST" --web-port "$WEB_PORT"
fi
