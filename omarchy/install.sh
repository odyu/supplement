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

TARGET_CONF_DIR="$HOME/.config/hypr"
OVERRIDES_FILE="hyprland-overrides.conf"
TARGET_FILE="$TARGET_CONF_DIR/$OVERRIDES_FILE"

# 【変更点】ソースファイルを dotfiles 配下から取得するように変更
# ここで ../dotfiles/.config/hypr/hyprland-overrides.conf を指します
SOURCE_FILE="$DOTFILES_DIR/.config/hypr/$OVERRIDES_FILE"

HYPR_CONF="$TARGET_CONF_DIR/hyprland.conf"
OVERRIDE_LINE="source = $HOME/.config/hypr/$OVERRIDES_FILE"

# リポジトリ内に設定ファイルが存在するか確認
if [ ! -f "$SOURCE_FILE" ]; then
    echo -e "${YELLOW}Warning: $SOURCE_FILE not found in repository.${NC}"
    # 存在しない場合、Stowディレクトリ構造に合わせて作成を試みる
    echo "Creating an empty file at $SOURCE_FILE to prevent errors..."
    mkdir -p "$(dirname "$SOURCE_FILE")"
    touch "$SOURCE_FILE"
fi

# 5-1. ディレクトリ作成
mkdir -p "$TARGET_CONF_DIR"

# 5-2. 設定ファイルのコピー (Link -> Copy 変換処理)
# ----------------------------------------------------
# Step 3のStowによって、TARGET_FILEは既に「シンボリックリンク」になっているはずです。
# ここでそれを検知し、実体コピーに置き換えます。

if [ -L "$TARGET_FILE" ]; then
    # シンボリックリンクだった場合は削除して実体コピーに置き換える
    # (バックアップはStowが管理しているので、ここではシンプルにリンク解除→コピーでOK)
    echo "  -> Symlink found (created by Stow). Replacing with physical copy."
    rm "$TARGET_FILE"
    cp "$SOURCE_FILE" "$TARGET_FILE"
    echo -e "${GREEN}✔ Copied $OVERRIDES_FILE (Replaced symlink)${NC}"

elif [ -e "$TARGET_FILE" ]; then
    # 実体ファイルがある場合、内容を比較して差分があれば更新
    if cmp -s "$SOURCE_FILE" "$TARGET_FILE"; then
        echo "  -> File already up to date: $OVERRIDES_FILE"
    else
        BACKUP_NAME="${TARGET_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
        echo "  -> ⚠ Existing file differs. Backing up to $BACKUP_NAME"
        mv "$TARGET_FILE" "$BACKUP_NAME"
        cp "$SOURCE_FILE" "$TARGET_FILE"
        echo -e "${GREEN}✔ Copied $OVERRIDES_FILE${NC}"
    fi
else
    # 新規作成 (Stowが何らかの理由でリンクを作らなかった場合など)
    cp "$SOURCE_FILE" "$TARGET_FILE"
    echo -e "${GREEN}✔ Copied $OVERRIDES_FILE${NC}"
fi

# 5-3. source設定の追記 (絶対パス版)
# ----------------------------------------------------
if [ -f "$HYPR_CONF" ]; then
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