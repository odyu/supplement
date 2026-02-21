#!/bin/bash
set -euo pipefail

echo "🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸"
echo "🔸 Install packages"
echo "🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸"
echo ""

echo "🔸 Install packages By PACMAN"
echo ""
PACMAN_PACKAGES=(
  bluez-utils
  bluez
  fcitx5-configtool
  fcitx5-im
  fcitx5-mozc
  keyd
  stow
  sheldon
  zsh
  nautilus
  gvfs
)
echo "sudo pacman -Syyu --noconfirm --needed ${PACMAN_PACKAGES[*]}"
sudo pacman -Syyu --noconfirm --needed "${PACMAN_PACKAGES[@]}"
echo ""


echo "🔸 Install packages By AUR"
echo ""
AUR_PACKAGES=(
  google-chrome
  jetbrains-toolbox
  visual-studio-code-bin
)
echo "yay -S --noconfirm --needed ${AUR_PACKAGES[*]}"
yay -S --noconfirm --needed "${AUR_PACKAGES[@]}"
echo ""


echo "🎉 Install packages completed."
echo ""
