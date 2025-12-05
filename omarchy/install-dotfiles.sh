#!/bin/bash
set -euo pipefail

echo "✨ [Dotfiles] Start"

HOME_DIR="${HOME}"
DOTFILES_DIR="${HOME_DIR}/supplement/dotfiles"

echo "Home: ${HOME_DIR}"
echo "Dotfiles dir: ${DOTFILES_DIR}"

cd "${DOTFILES_DIR}"

packages=(zsh p10k ideavim)
for pkg in "${packages[@]}"; do
  echo "▶ stow -v -R --adopt --no-folding -t ${HOME_DIR} ${pkg}"
  stow -v -R --adopt --no-folding -t "${HOME_DIR}" "${pkg}"
done

echo "🎉 [Dotfiles] Completed"