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
  bluez
  bluez-utils
  fcitx5-configtool
  fcitx5-im
  fcitx5-mozc
  git
  keyd
  libffi
  libxslt
  libyaml
  neovim
  openssl
  python
  readline
  rust
  stow
  unzip
  zlib
  zsh
)
echo "sudo pacman -S --noconfirm --needed ${PACMAN_PACKAGES[*]}"
sudo pacman -S --noconfirm --needed "${PACMAN_PACKAGES[@]}"
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


echo "🔸 Install mise"
echo ""
if command -v mise &> /dev/null; then
  echo "✅ mise already installed."
else
  echo "curl https://mise.run | sh"
  curl https://mise.run | sh
fi
echo ""

echo "🔸 Install oh-my-zsh"
echo ""
OH_MY_ZSH_DIR="$HOME/.oh-my-zsh"
if [ -d "$OH_MY_ZSH_DIR" ]; then
  echo "✅ Oh My Zsh already exists at $OH_MY_ZSH_DIR, skipping install."
else
  echo 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"'
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi
echo ""

echo "🔸 Install powerlevel10k"
echo ""
ZSH_CUSTOM_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
P10K_DIR="$ZSH_CUSTOM_DIR/themes/powerlevel10k"
if [ -d "$P10K_DIR" ]; then
  echo "✅ Powerlevel10k already exists at $P10K_DIR, skipping install."
else
  echo "git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $P10K_DIR"
  mkdir -p "$ZSH_CUSTOM_DIR/themes"
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
fi
echo ""


echo "🎉 Install packages completed."
echo ""
