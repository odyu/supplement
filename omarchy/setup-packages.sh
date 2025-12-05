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



echo "🔸 Enable keyd"
echo ""
if ! systemctl is-enabled --quiet keyd; then
  echo "sudo systemctl enable keyd --now"
  sudo systemctl enable keyd --now
else
  echo "✅ Already enabled keyd"
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



echo "🎉 Setup packages completed."
echo ""

