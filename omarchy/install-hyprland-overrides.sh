#!/bin/bash
set -eu

HYPRLAND_CONFIG="$HOME/.config/hypr/hyprland.conf"
OVERRIDES_CONFIG="$HOME/supplement/dotfiles/.config/hypr/hyprland-overrides.conf"

grep -qF "$OVERRIDES_CONFIG" "$HYPRLAND_CONFIG" || {
    echo -e "\n# Local overrides\nsource = $OVERRIDES_CONFIG" >> "$HYPRLAND_CONFIG"
    echo "[Done] Added source line to $HYPRLAND_CONFIG"
}