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

echo "🔸 Setup Hyprland overrides"
echo ""
HYPR_CONFIG_PATH="${HOME}/.config/hypr"
if [ -f "${HYPR_CONFIG_PATH}/hyprland-override.conf" ]; then
  cat "source = ${HYPR_CONFIG_PATH}/hyprland-override.conf" >> "${HYPR_CONFIG_PATH}/hyprland.conf"
fi

if [ -f "${HYPR_CONFIG_PATH}/monitor-overrides.conf" ]; then
  cat "source ${HYPR_CONFIG_PATH}/monitor-overrides.conf" >> "${HYPR_CONFIG_PATH}/monitors.conf"
fi
echo ""

echo "🎉 Setup packages completed."
echo ""

