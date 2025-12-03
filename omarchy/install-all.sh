#!/bin/bash
echo "📦 Starting Package Installation..."

PACMAN_PACKAGES=(
    base-devel
    git
    stow
    unzip
    neovim
    zsh
    # ripgrep
    # fzf
    # tmux
)

AUR_PACKAGES=(
    google-chrome
    # visual-studio-code-bin
    # slack-desktop
    # 1password
)

sudo pacman -S --noconfirm --needed "${PACMAN_PACKAGES[@]}"

yay -S --noconfirm --needed "${AUR_PACKAGES[@]}"

echo "✅ All packages installation sequence completed."

$HOME/supplement/omarchy/install-hyprland-overrides.sh

