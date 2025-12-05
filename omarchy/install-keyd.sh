#!/bin/bash
set -euo pipefail


echo "🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸"
echo "🔸 Setup keyd"
echo "🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸"
echo ""

KEYD_SRC="${DOTFILES_DIR}/keyd/default.conf"
KEYD_DEST="/etc/keyd/default.conf"

if [ -f "${KEYD_SRC}" ]; then
  # ディレクトリがない場合の保険
  if [ ! -d "/etc/keyd" ]; then
     echo "Creating /etc/keyd directory..."
     sudo mkdir -p /etc/keyd
  fi

  echo "Linking ${KEYD_SRC} -> ${KEYD_DEST}"
  sudo ln -sf "${KEYD_SRC}" "${KEYD_DEST}"

  # keydがインストールされている場合のみリロードを実行
  if command -v keyd >/dev/null 2>&1; then
    echo "Reloading keyd configuration..."
    sudo keyd reload
  fi
else
  echo "⚠️  File not found: ${KEYD_SRC} (Skipping keyd)"
fi
echo ""

echo "🎉 Deploy dotfiles completed."
