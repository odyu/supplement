#!/bin/bash

# ==============================================================================
# Omarchy (Linux) Setup Script
# ==============================================================================

set -e # エラーが発生したら即終了

# 色の定義
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")/dotfiles" # ../dotfiles を指す

echo -e "${BLUE}=== Starting Omarchy Setup ===${NC}"

# ==============================================================================
# 1. 追加パッケージのインストール (Omarchyに標準でないもの)
# ==============================================================================
echo -e "${BLUE}[1/5] Installing additional packages...${NC}"

PACKAGES=(
    stow
    unzip
)

echo "Installing: ${PACKAGES[*]}"
sudo pacman -S --noconfirm --needed "${PACKAGES[@]}"

echo -e "${GREEN}✔ Additional packages installed.${NC}"

# ==============================================================================
# 2. 外部ツールのセットアップ (Oh My Zsh, anyenv)
# ==============================================================================
echo -e "${BLUE}[2/5] Setting up external tools...${NC}"

# --- Oh My Zsh ---
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

    if [ -f "$HOME/.zshrc" ]; then
        echo "Removing default .zshrc..."
        rm "$HOME/.zshrc"
    fi
else
    echo "  -> Oh My Zsh is already installed."
fi

# --- anyenv ---
if [ ! -d "$HOME/.anyenv" ]; then
    echo "Installing anyenv..."
    git clone https://github.com/anyenv/anyenv "$HOME/.anyenv"
    mkdir -p "$HOME/.anyenv/plugins"
    git clone https://github.com/znz/anyenv-update.git "$HOME/.anyenv/plugins/anyenv-update"
else
    echo "  -> anyenv is already installed."
fi

echo -e "${GREEN}✔ External tools setup completed.${NC}"

# ==============================================================================
# 3. Dotfilesの展開 (GNU Stow) - 強制適用モード
# ==============================================================================
echo -e "${BLUE}[3/5] Deploying dotfiles...${NC}"

if [ -d "$DOTFILES_DIR" ]; then
    # もし前回作成した除外リストが残っていたら削除して、Stow対象に戻す
    IGNORE_FILE="$DOTFILES_DIR/.stow-local-ignore"
    if [ -f "$IGNORE_FILE" ]; then
        echo "Removing .stow-local-ignore to enable full linking..."
        rm "$IGNORE_FILE"
    fi

    echo "Linking dotfiles from $DOTFILES_DIR"

    pushd "$DOTFILES_DIR" > /dev/null

    # --adopt: 既存ファイルがある場合、それをリポジトリに取り込む形でリンクを強制作成する
    stow -v -t "$HOME" --adopt .

    # adoptによってリポジトリ側のファイルが既存ファイルの内容で書き換わってしまうのを防ぐため、
    # git restore でリポジトリの状態（本来配布したい設定）に戻す
    git restore .

    popd > /dev/null

    echo -e "${GREEN}✔ Dotfiles deployed (forced).${NC}"
else
    echo -e "${YELLOW}Warning: dotfiles directory not found at $DOTFILES_DIR${NC}"
fi

# ==============================================================================
# 4. デフォルトシェルの確認
# ==============================================================================
echo -e "${BLUE}[4/5] Checking default shell...${NC}"

CURRENT_SHELL=$(basename "$SHELL")
if [ "$CURRENT_SHELL" != "zsh" ]; then
    echo "Changing default shell to zsh..."
    chsh -s "$(which zsh)"
    echo -e "${GREEN}✔ Shell changed to zsh.${NC}"
else
    echo "  -> Default shell is already zsh."
fi

# ==============================================================================
# 5. Hyprland設定 (Omarchy固有)
# ==============================================================================
echo -e "${BLUE}[5/5] Configuring Hyprland overrides...${NC}"

# Step 3のStowによって、既に ~/.config/hypr/hyprland-overrides.conf に
# シンボリックリンクが作成されているはずです。
# ここでは hyprland.conf 本体への追記のみを行います。

TARGET_CONF_DIR="$HOME/.config/hypr"
OVERRIDES_FILE="hyprland-overrides.conf"
HYPR_CONF="$TARGET_CONF_DIR/hyprland.conf"

# 絶対パス($HOME)を使用してglobbing errorを防ぐ
OVERRIDE_LINE="source = $HOME/.config/hypr/$OVERRIDES_FILE"

if [ -f "$HYPR_CONF" ]; then
    # 既に追記済みかチェック（チルダ版と絶対パス版の両方をチェックして重複防止）
    if ! grep -qF "source = $HOME/.config/hypr/$OVERRIDES_FILE" "$HYPR_CONF" && ! grep -qF "source = ~/.config/hypr/$OVERRIDES_FILE" "$HYPR_CONF"; then
        echo "Adding override source to hyprland.conf..."
        echo "" >> "$HYPR_CONF"
        echo "# Load custom supplements (Overrides)" >> "$HYPR_CONF"
        echo "$OVERRIDE_LINE" >> "$HYPR_CONF"
        echo -e "${GREEN}✔ Added source directive to $HYPR_CONF${NC}"
    else
        echo "  -> hyprland.conf already includes overrides source."
    fi
else
    echo -e "${YELLOW}Warning: $HYPR_CONF not found. Skipping source addition.${NC}"
fi

echo -e "${BLUE}=== Omarchy Setup Finished ===${NC}"