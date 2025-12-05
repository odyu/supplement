#!/bin/bash
set -euo pipefail

echo "🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸"
echo "🔸 Setup keyd"
echo "🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸"
echo ""

# このスクリプトがあるディレクトリ (omarchy/keyd) を取得
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 変数定義: 自分の隣にある default.conf をソースとする
KEYD_SRC="${CURRENT_DIR}/default.conf"
KEYD_DEST="/etc/keyd/default.conf"

# 1. keyd がインストールされているか確認 (なければインストール)
if ! command -v keyd >/dev/null 2>&1; then
    echo "📦 keyd is not installed. Installing..."
    sudo pacman -S --noconfirm keyd
else
    echo "✅ keyd is already installed."
fi

# 2. 設定ファイルのリンク作成
if [ -f "${KEYD_SRC}" ]; then
  # ディレクトリがない場合の保険
  if [ ! -d "/etc/keyd" ]; then
     echo "Creating /etc/keyd directory..."
     sudo mkdir -p /etc/keyd
  fi

  echo "Linking ${KEYD_SRC} -> ${KEYD_DEST}"
  sudo ln -sf "${KEYD_SRC}" "${KEYD_DEST}"
else
  echo "⚠️  File not found: ${KEYD_SRC} (Skipping keyd setup)"
  exit 1
fi

# 3. サービスの有効化 (enable --now)
echo "Checking keyd service status..."
if ! systemctl is-enabled --quiet keyd; then
  echo "🚀 Enabling keyd service..."
  sudo systemctl enable keyd --now
else
  echo "✅ keyd service is already enabled."
fi

# 4. 設定のリロード (念の為)
# サービスが動いている場合のみリロードをかける
if systemctl is-active --quiet keyd; then
    echo "🔄 Reloading keyd configuration..."
    sudo keyd reload
fi

echo ""
echo "🎉 Setup keyd completed."