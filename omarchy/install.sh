#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "[Omarchy] Step 1/4: Installing base packages..."
bash "$SCRIPT_DIR/install-packages.sh"

echo "[Omarchy] Step 2/4: Installing middleware (anyenv, oh-my-zsh, p10k)..."
bash "$SCRIPT_DIR/install-middleware.sh"

echo "[Omarchy] Step 3/4: Deploying dotfiles via GNU Stow..."
bash "$SCRIPT_DIR/install-dotfiles.sh"

echo "[Omarchy] Step 4/4: Applying Hyprland overrides..."
bash "$SCRIPT_DIR/install-hyprland-overrides.sh"

echo "[Omarchy] All steps completed successfully."

