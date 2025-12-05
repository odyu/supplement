#!/bin/bash
set -euo pipefail

echo "🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸"
echo "🔸 Install packages"
echo "🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸"
echo ""

echo "🔸 Install packages By PACMAN"
echo ""
PACMAN_PACKAGES=(
  base-devel
  git
  stow
  unzip
  neovim
  zsh
)
echo "sudo pacman -S --noconfirm --needed ${PACMAN_PACKAGES[@]}"
sudo pacman -S --noconfirm --needed "${PACMAN_PACKAGES[@]}"
echo ""


echo "🔸 Install packages By AUR"
echo ""
AUR_PACKAGES=(
  google-chrome
  bitwarden-bin
  jetbrains-toolbox
)
echo "yay -S --noconfirm --needed ${AUR_PACKAGES[@]}"
yay -S --noconfirm --needed "${AUR_PACKAGES[@]}"
echo ""


echo "🔸 Install anyenv"
echo ""
ANYENV_DIR="$HOME/.anyenv"
if [ -d "$ANYENV_DIR" ]; then
  echo "Anyenv already exists at $ANYENV_DIR, skipping clone."
else
  echo "git clone https://github.com/anyenv/anyenv $ANYENV_DIR"
  git clone https://github.com/anyenv/anyenv "$ANYENV_DIR"
fi


echo "✅ Package installation sequence completed."
echo ""

