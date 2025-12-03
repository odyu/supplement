#!/bin/bash

# Omarchy / Linux用インストーラーのテンプレート

echo "---------------------------------------"
echo "Running Omarchy (Linux) specific installation..."
echo "---------------------------------------"

# ここにLinux固有の処理を書く

# 例: パッケージのインストール
# sudo pacman -S --noconfirm --needed neovim git zsh stow

# 例: Stowの実行
# cd "$(dirname "$0")/../dotfiles" && stow .

# 例: Hyprland設定のsource追記チェック
HYPR_CONF="$HOME/.config/hypr/hyprland.conf"
OVERRIDE_LINE="source = ~/.config/hypr/hyprland-overrides.conf"

if [ -f "$HYPR_CONF" ]; then
    if ! grep -qF "$OVERRIDE_LINE" "$HYPR_CONF"; then
        echo "Adding override source to hyprland.conf..."
        echo "$OVERRIDE_LINE" >> "$HYPR_CONF"
    else
        echo "Override source already present in hyprland.conf."
    fi
fi

echo "Omarchy setup finished."