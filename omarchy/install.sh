#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

bash "$SCRIPT_DIR/install-packages.sh"
bash "$SCRIPT_DIR/install-middleware.sh"
bash "$SCRIPT_DIR/install-dotfiles.sh"
bash "$SCRIPT_DIR/install-hyprland-overrides.sh"

bash "$SCRIPT_DIR/setup-pacakges.sh"

echo "[Omarchy] All steps completed successfully."

