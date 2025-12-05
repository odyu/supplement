#!/bin/bash
set -euo pipefail

echo "🧩 [Hyprland Overrides] Start"

HYPRLAND_CONFIG="$HOME/.config/hypr/hyprland.conf"
OVERRIDES_CONFIG="$HOME/supplement/dotfiles/.config/hypr/hyprland-overrides.conf"

echo "Hyprland config: ${HYPRLAND_CONFIG}"
echo "Overrides file: ${OVERRIDES_CONFIG}"

if grep -qF "$OVERRIDES_CONFIG" "$HYPRLAND_CONFIG"; then
  echo "Already sourced overrides in ${HYPRLAND_CONFIG}. Skipping."
else
  echo -e "\n# Local overrides\nsource = $OVERRIDES_CONFIG" >> "$HYPRLAND_CONFIG"
  echo "[Done] Added source line to $HYPRLAND_CONFIG"
fi

echo "🎉 [Hyprland Overrides] Completed"