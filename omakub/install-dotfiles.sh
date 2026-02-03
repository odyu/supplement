#!/bin/bash
set -euo pipefail

echo "=== Deploy dotfiles ==="
echo ""

HOME_DIR="${HOME}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "${SCRIPT_DIR}/../dotfiles" && pwd)"
cd "${DOTFILES_DIR}"

echo "Home directory: ${HOME_DIR}"
echo "Dotfiles directory: ${DOTFILES_DIR}"
echo "Working directory: $(pwd)"
echo ""

echo "Deploy zsh dotfiles"
stow -v -R --adopt --no-folding -t "${HOME_DIR}" zsh
echo ""

echo "Deploy p10k dotfiles"
stow -v -R --adopt --no-folding -t "${HOME_DIR}" p10k
echo ""

echo "Deploy ideavim dotfiles"
stow -v -R --adopt --no-folding -t "${HOME_DIR}" ideavim
echo ""

echo "Deploy fcitx5 dotfiles"
stow -v -R --adopt --no-folding -t "${HOME_DIR}" fcitx5
echo ""

echo "Dotfiles deployment completed."
