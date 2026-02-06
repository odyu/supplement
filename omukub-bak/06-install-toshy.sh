#!/bin/bash
set -euo pipefail

echo "=== 06-install-toshy.sh ==="
echo "Installing Toshy (Key remapper)..."

TOSHY_DIR="${HOME}/toshy"

if [ -d "${TOSHY_DIR}/.git" ]; then
  echo "Updating Toshy at ${TOSHY_DIR}..."
  git -C "${TOSHY_DIR}" pull --ff-only || echo "Warning: Toshy update failed."
elif [ -d "${TOSHY_DIR}" ]; then
  echo "Toshy directory exists but is not a git repo, skipping clone."
else
  echo "Cloning Toshy..."
  git clone https://github.com/RedBearAK/toshy.git "${TOSHY_DIR}"
fi

if [ -f "${TOSHY_DIR}/setup_toshy.py" ]; then
  echo "Running Toshy setup..."
  cd "${TOSHY_DIR}"
  # 修正: sudo を削除しました。
  # Toshyは一般ユーザーで実行する必要があります（内部で必要に応じてパスワードを聞かれます）。
  ./setup_toshy.py install
else
  echo "Error: Toshy setup script not found at ${TOSHY_DIR}/setup_toshy.py"
  exit 1
fi

echo "Toshy installation completed."