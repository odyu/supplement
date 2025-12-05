#!/bin/bash
set -euo pipefail

echo ""
echo "🔶 🔶 🔶 🔶 🔶 🔶 🔶 🔶 🔶 🔶 🔶 🔶 🔶 🔶 🔶 🔶 🔶 🔶 🔶 🔶 🔶 🔶 🔶 🔶"
echo "🔶"
echo "🔶   INSTALL SUPPLEMENT for Omarchy 🐧"
echo "🔶"
echo "🔶 🔶 🔶 🔶 🔶 🔶 🔶 🔶 🔶 🔶 🔶 🔶 🔶 🔶 🔶 🔶 🔶 🔶 🔶 🔶 🔶 🔶 🔶 🔶"
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "Script directory: ${SCRIPT_DIR}"
echo "Home directory: ${HOME}"

echo "[1/5] Running install-packages..."
"${SCRIPT_DIR}/install-packages"

echo "[2/5] Running install-middleware..."
"${SCRIPT_DIR}/install-middleware"

echo "[3/5] Running install-dotfiles..."
"${SCRIPT_DIR}/install-dotfiles"

echo "[4/5] Running install-hyprland-overrides..."
"${SCRIPT_DIR}/install-hyprland-overrides"

echo "[5/5] Running setup-pacakges..."
"${SCRIPT_DIR}/setup-pacakges"


echo ""
echo "😄 FINISHED SUPPLEMENT"
echo ""
