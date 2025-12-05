#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "Script directory: ${SCRIPT_DIR}"
echo "Home directory: ${HOME}"

echo "[1/5] Running install-packages..."
"${SCRIPT_DIR}/install-packages.sh"

echo "[2/5] Running install-middleware..."
"${SCRIPT_DIR}/install-middleware.sh"

echo "[3/5] Running install-dotfiles..."
"${SCRIPT_DIR}/install-dotfiles.sh"

echo "[4/5] Running install-hyprland-overrides..."
"${SCRIPT_DIR}/install-hyprland-overrides.sh"

echo "[5/5] Running setup-pacakges..."
"${SCRIPT_DIR}/setup-pacakges.sh"
