#!/bin/bash
set -euo pipefail

echo "🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸"
echo "🔸 Setup packages"
echo "🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸"
echo ""



echo "🔸 Changing default shell to zsh"
echo ""
CURRENT_SHELL="${SHELL:-}"
ZSH_PATH="$(command -v zsh || true)"
if [ -n "${ZSH_PATH}" ] && [ "${CURRENT_SHELL}" != "${ZSH_PATH}" ]; then
  echo "chsh -s ${ZSH_PATH}"
  chsh -s "${ZSH_PATH}"
else
  echo "✅ Zsh already default shell at $ZSH_PATH, skipping setup."
fi
echo ""



echo "🔸 Setup Hyprland overrides"
echo ""
HYPR_CONFIG_PATH="${HOME}/.config/hypr"
if [ -f "$HYPR_CONFIG_PATH/hyprland-overrides.conf" ]; then
  if ! grep -Fq "source = ~/.config/hypr/hyprland-overrides.conf" "$HYPR_CONFIG_PATH/hyprland.conf"; then
    echo "" >> "$HYPR_CONFIG_PATH/hyprland.conf"
    echo "source = ~/.config/hypr/hyprland-overrides.conf" >> "$HYPR_CONFIG_PATH/hyprland.conf"
    echo "✅ Successfully added hyprland-overrides.conf to source configuration!"
  else
    echo "✅ hyprland-overrides.conf is already added to source"
  fi
fi
echo ""



echo "🔸 Setup Waybar overrides"
echo ""
WAYBAR_CONFIG_PATH="${HOME}/.config/waybar"
if [ -f "$WAYBAR_CONFIG_PATH/config.jsonc" ]; then
  if ! grep -q "overrides.jsonc" "$WAYBAR_CONFIG_PATH/config.jsonc"; then
    # 最初の { の後に挿入
    sed -i '0,/{/s|{|{\n    "include": [ "~/.config/waybar/overrides.jsonc" ],|' "$WAYBAR_CONFIG_PATH/config.jsonc"
    echo "✅ Successfully added overrides.jsonc include to waybar config!"
  else
    echo "✅ overrides.jsonc include is already added to waybar config"
  fi
fi

if [ -f "$WAYBAR_CONFIG_PATH/style.css" ]; then
  if ! grep -q "@import \"overrides.css\"" "$WAYBAR_CONFIG_PATH/style.css"; then
    echo "" >> "$WAYBAR_CONFIG_PATH/style.css"
    echo '@import "overrides.css";' >> "$WAYBAR_CONFIG_PATH/style.css"
    echo "✅ Successfully added overrides.css import to waybar style!"
  else
    echo "✅ overrides.css import is already added to waybar style"
  fi
fi
echo ""



echo "🎉 Setup packages completed."
echo ""

