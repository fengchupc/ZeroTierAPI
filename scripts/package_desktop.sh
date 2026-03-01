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

echo "[1/3] 清理并拉取依赖..."
flutter pub get

echo "[2/3] 构建 Linux release..."
flutter build linux

ARCH="$(uname -m)"
BUNDLE_DIR="build/linux/${ARCH}/release/bundle"
if [[ ! -d "$BUNDLE_DIR" ]]; then
  BUNDLE_DIR="build/linux/arm64/release/bundle"
fi

if [[ ! -d "$BUNDLE_DIR" ]]; then
  echo "[ERROR] 找不到 Linux bundle 目录，构建可能失败。"
  exit 1
fi

mkdir -p dist
PKG_NAME="zerotierapi-linux-${ARCH}.tar.gz"

echo "[3/3] 打包发布文件..."
tar -C "$BUNDLE_DIR" -czf "dist/${PKG_NAME}" .

echo "完成: dist/${PKG_NAME}"
echo "解压后双击可执行文件 zerotierapi 即可运行。"
