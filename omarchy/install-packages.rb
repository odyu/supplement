#!/usr/bin/env ruby
# frozen_string_literal: true

echo "📦 Starting Package Installation..."

# ==============================================================================
# 設定: インストールしたいパッケージのリスト
# ==============================================================================

# 1. 公式リポジトリ (pacman) から入れるもの
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

# 2. AUR (yay) から入れるもの
AUR_PACKAGES=(
    google-chrome
    bitwarden-bin       # パスワード管理 (Binary版でインストール時間を短縮)
    jetbrains-toolbox   # JetBrains製品(IntelliJなど)の管理ツール
    # visual-studio-code-bin
    # slack-desktop
    # 1password
)

# ==============================================================================
# 処理開始
# ==============================================================================

# --- 1. 公式パッケージのインストール ---
echo "-----------------------------------------------------"
echo "Installing Official Packages..."
echo "-----------------------------------------------------"
# --needed: 既にインストール済みならスキップ (冪等性確保)
sudo pacman -S --noconfirm --needed "${PACMAN_PACKAGES[@]}"


# --- 2. yay (AUR Helper) のセットアップ ---
echo "-----------------------------------------------------"
echo "Checking AUR Helper (yay)..."
echo "-----------------------------------------------------"

if ! command -v yay &> /dev/null; then
    echo "⚠️ yay not found. Installing from AUR..."
    TEMP_DIR=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git "$TEMP_DIR/yay"
    
    pushd "$TEMP_DIR/yay" > /dev/null
    makepkg -si --noconfirm
    popd > /dev/null
    
    rm -rf "$TEMP_DIR"
    echo "✅ yay installed successfully."
else
    echo "✅ yay is already installed."
fi


# --- 3. AURパッケージのインストール ---
echo "-----------------------------------------------------"
echo "Installing AUR Packages..."
echo "-----------------------------------------------------"
# yay も --needed が使えるので冪等性が保たれます
yay -S --noconfirm --needed "${AUR_PACKAGES[@]}"


echo "✅ All packages installation sequence completed."
