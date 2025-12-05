#!/bin/bash
set -euo pipefail

echo "🧰 [Setup Packages] Start"

CURRENT_SHELL="${SHELL:-}"
ZSH_PATH="$(command -v zsh || true)"
echo "Current SHELL: ${CURRENT_SHELL}"
echo "Detected zsh path: ${ZSH_PATH}"

if [ -n "${ZSH_PATH}" ] && [ "${CURRENT_SHELL}" != "${ZSH_PATH}" ]; then
  echo "Changing default shell to zsh (${ZSH_PATH})"
  chsh -s "${ZSH_PATH}"
else
  echo "Default shell already zsh or zsh not found. Skipping."
fi

echo "🎉 [Setup Packages] Completed"
