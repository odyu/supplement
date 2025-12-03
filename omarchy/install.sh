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
# 1. 必要なパッケージのインストール
# ==============================================================================
echo -e "${BLUE}[1/5] Installing system packages...${NC}"

# インストールするパッケージリスト
# --needed: 既にインストールされている場合はスキップ
PACKAGES=(
    stow
    unzip
    # 他に必要なものがあればここに追加 (例: tmux, fzf, ripgrep)
)

echo "Installing: ${PACKAGES[*]}"
sudo pacman -S --noconfirm --needed "${PACKAGES[@]}"

echo -e "${GREEN}✔ System packages installed.${NC}"

# ==============================================================================
# 2. 外部ツールのセットアップ (Oh My Zsh, anyenv)
# ==============================================================================
echo -e "${BLUE}[2/5] Setting up external tools...${NC}"

# --- Oh My Zsh ---
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

    # インストーラーが作成したデフォルトの .zshrc を削除
    # (あとで自分のdotfilesをリンクするため)
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

    # anyenv-update プラグインも入れておく
    mkdir -p "$HOME/.anyenv/plugins"
    git clone https://github.com/znz/anyenv-update.git "$HOME/.anyenv/plugins/anyenv-update"
else
    echo "  -> anyenv is already installed."
fi

echo -e "${GREEN}✔ External tools setup completed.${NC}"

# ==============================================================================
# 3. Dotfilesの展開 (GNU Stow)
# ==============================================================================
echo -e "${BLUE}[3/5] Deploying dotfiles...${NC}"

if [ -d "$DOTFILES_DIR" ]; then
    echo "Linking dotfiles from $DOTFILES_DIR"

    # dotfilesディレクトリに移動してstowを実行
    pushd "$DOTFILES_DIR" > /dev/null

    # -v: 詳細表示
    # -t ~: ホームディレクトリをターゲットにする
    # -R: Restow (リンクの貼り直し・不要リンクの削除)
    stow -v -t "$HOME" -R .

    popd > /dev/null
    echo -e "${GREEN}✔ Dotfiles deployed.${NC}"
else
    echo -e "${YELLOW}Warning: dotfiles directory not found at $DOTFILES_DIR${NC}"
fi

# ==============================================================================
# 4. デフォルトシェルの切り替え (Zsh)
# ==============================================================================
echo -e "${BLUE}[4/5] Checking default shell...${NC}"

CURRENT_SHELL=$(basename "$SHELL")
if [ "$CURRENT_SHELL" != "zsh" ]; then
    echo "Changing default shell to zsh..."
    # ユーザーのパスワード入力を求める場合があります
    chsh -s "$(which zsh)"
    echo -e "${GREEN}✔ Shell changed to zsh. Please log out and back in for changes to take effect.${NC}"
else
    echo "  -> Default shell is already zsh."
fi

# ==============================================================================
# 5. Hyprland設定 (Omarchy固有)
# ==============================================================================
echo -e "${BLUE}[5/5] Configuring Hyprland overrides...${NC}"

TARGET_CONF_DIR="$HOME/.config/hypr"
OVERRIDES_FILE="hyprland-overrides.conf"
TARGET_FILE="$TARGET_CONF_DIR/$OVERRIDES_FILE"
SOURCE_FILE="$SCRIPT_DIR/$OVERRIDES_FILE"
HYPR_CONF="$TARGET_CONF_DIR/hyprland.conf"
OVERRIDE_LINE="source = ~/.config/hypr/$OVERRIDES_FILE"

# 5-1. ディレクトリ作成
mkdir -p "$TARGET_CONF_DIR"

# 5-2. シンボリックリンク作成 (バックアップ機能付き)
if [ -L "$TARGET_FILE" ] && [ "$(readlink -f "$TARGET_FILE")" = "$SOURCE_FILE" ]; then
    echo "  -> Link already correct: $OVERRIDES_FILE"
else
    if [ -e "$TARGET_FILE" ]; then
        BACKUP_NAME="${TARGET_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
        echo "  -> ⚠ Existing file found. Backing up to $BACKUP_NAME"
        mv "$TARGET_FILE" "$BACKUP_NAME"
    fi
    ln -sf "$SOURCE_FILE" "$TARGET_FILE"
    echo -e "${GREEN}✔ Linked $OVERRIDES_FILE${NC}"
fi

# 5-3. source設定の追記
if [ -f "$HYPR_CONF" ]; then
    if ! grep -qF "$OVERRIDE_LINE" "$HYPR_CONF"; then
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