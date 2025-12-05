#!/bin/bash
set -euo pipefail

echo "🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸"
echo "🔸 Install packages"
echo "🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸"

# インストール対象（公式）
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
# インストール対象（AUR）
AUR_PACKAGES=(
  google-chrome
  bitwarden-bin
  jetbrains-toolbox
)

echo "yay -S --noconfirm --needed ${AUR_PACKAGES[@]}"
yay -S --noconfirm --needed "${AUR_PACKAGES[@]}"
echo ""

echo "✅ Package installation sequence completed."
echo ""

