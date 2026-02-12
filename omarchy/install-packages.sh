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
)
echo "sudo pacman -Syyu --noconfirm --needed ${PACMAN_PACKAGES[*]}"
sudo pacman -Syyu --noconfirm --needed "${PACMAN_PACKAGES[@]}"
echo ""


echo "🔸 Install packages By AUR"
echo ""
AUR_PACKAGES=(
  bitwarden-bin
  google-chrome
  jetbrains-toolbox
)
echo "yay -S --noconfirm --needed ${AUR_PACKAGES[*]}"
yay -S --noconfirm --needed "${AUR_PACKAGES[@]}"
echo ""


echo "🎉 Install packages completed."
echo ""
