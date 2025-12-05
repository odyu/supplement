#!/bin/bash
set -euo pipefail


echo "🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸"
echo "🔸 Deploy dotfiles"
echo "🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸"
echo ""

HOME_DIR="${HOME}"
DOTFILES_DIR="${HOME_DIR}/supplement/dotfiles"
cd "${DOTFILES_DIR}"

echo "Home directory: ${HOME_DIR}"
echo "Dotfiles directory: ${DOTFILES_DIR}"
echo "Working directory: $(pwd)"

echo "🔸 Deploy zsh dotfiles"
echo ""
echo "stow -v -R --adopt --no-folding -t ${HOME_DIR} zsh"
stow -v -R --adopt --no-folding -t "${HOME_DIR}" zsh
echo ""

echo "🔸 Deploy p10k dotfiles"
echo ""
echo "stow -v -R --adopt --no-folding -t ${HOME_DIR} p10k"
stow -v -R --adopt --no-folding -t "${HOME_DIR}" p10k
echo ""

echo "🔸 Deploy ideavim dotfiles"
echo ""
echo "stow -v -R --adopt --no-folding -t ${HOME_DIR} ideavim"
stow -v -R --adopt --no-folding -t "${HOME_DIR}" ideavim
echo ""

echo "🔸 Deploy hyprland dotfiles"
echo ""
echo "stow -v -R --adopt --no-folding -t ${HOME_DIR} hyprland"
stow -v -R --adopt --no-folding -t "${HOME_DIR}" hyprland
echo ""

echo "🔸 Deploy fcitx5 dotfiles"
echo ""
echo "stow -v -R --adopt --no-folding -t ${HOME_DIR} fcitx5"
stow -v -R --adopt --no-folding -t "${HOME_DIR}" fcitx5
echo ""

echo "🎉 Deploy dotfiles completed."
