#!/bin/bash
set -euo pipefail

echo "=== Setup packages ==="
echo ""

echo "Ensuring default shell is zsh"
CURRENT_SHELL="${SHELL:-}"
ZSH_PATH="$(command -v zsh || true)"
if [ -n "${ZSH_PATH}" ] && [ "${CURRENT_SHELL}" != "${ZSH_PATH}" ]; then
  echo "chsh -s ${ZSH_PATH}"
  chsh -s "${ZSH_PATH}"
else
  echo "Zsh already default shell at ${ZSH_PATH}, skipping."
fi
echo ""

echo "Toshy post-install setup placeholder"
echo "Add any Toshy-specific settings here if needed."
echo ""

echo "Package setup completed."
