#!/bin/bash
set -euo pipefail

echo "🔸 🔸 🔸 🔸 🔸 🔸 🔸 🔸 🔸 🔸 🔸 🔸 🔸 🔸 🔸 🔸 🔸 🔸 🔸 🔸 🔸 🔸 🔸 🔸"
echo "🔸  Install packages"
echo "🔸 🔸 🔸 🔸 🔸 🔸 🔸 🔸 🔸 🔸 🔸 🔸 🔸 🔸 🔸 🔸 🔸 🔸 🔸 🔸 🔸 🔸 🔸 🔸"

# インストール対象（公式）
PACMAN_PACKAGES=(
  base-devel
  git
  stow
  unzip
  neovim
  zsh
)

# インストール対象（AUR）
AUR_PACKAGES=(
  google-chrome
  bitwarden-bin
  jetbrains-toolbox
)

sudo pacman -S --noconfirm --needed "${PACMAN_PACKAGES[@]}"
yay -S --noconfirm --needed "${AUR_PACKAGES[@]}"

echo "✅ Package installation sequence completed."

