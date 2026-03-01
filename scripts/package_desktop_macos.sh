#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

if ! command -v flutter >/dev/null 2>&1; then
  if [[ -x "$HOME/tools/flutter/bin/flutter" ]]; then
    export PATH="$HOME/tools/flutter/bin:$PATH"
  fi
fi

if ! command -v flutter >/dev/null 2>&1; then
  echo "[ERROR] flutter 未找到。请先安装 Flutter 或配置 PATH。"
  exit 1
fi

echo "[1/3] 拉取依赖..."
flutter pub get

echo "[2/3] 构建 macOS release..."
flutter build macos

APP_DIR="build/macos/Build/Products/Release/zerotierapi.app"
if [[ ! -d "$APP_DIR" ]]; then
  echo "[ERROR] 找不到 .app 目录，构建可能失败。"
  exit 1
fi

mkdir -p dist

echo "[3/3] 打包发布文件..."
ditto -c -k --sequesterRsrc --keepParent "$APP_DIR" "dist/zerotierapi-macos.zip"

echo "完成: dist/zerotierapi-macos.zip"
echo "解压后双击 zerotierapi.app 即可运行。"
