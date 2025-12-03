#!/bin/bash

set -e # エラーが発生したら即終了

# 色の定義
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# スクリプトが存在するディレクトリの絶対パスを取得
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# ---------------------------------------------------
# 関数定義: Gitの変更状況チェック (Dirty Check)
# ---------------------------------------------------
check_git_status() {
    # そもそもGitリポジトリでない場合（Zip解凍など）はチェックをスキップして正常終了(0)とする
    if ! git -C "$SCRIPT_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        return 0
    fi

    # 未コミットの変更があるかチェック
    if [ -n "$(git -C "$SCRIPT_DIR" status --porcelain)" ]; then
        echo -e "${RED}---------------------------------------${NC}"
        echo -e "${RED}[ERROR] Repository is dirty (uncommitted changes).${NC}"
        echo "Gitリポジトリに未コミットの変更があります。"
        echo "再現性を保つため、commit または stash してから実行してください。"
        echo -e "${RED}---------------------------------------${NC}"

        # 変更されたファイルを表示
        git -C "$SCRIPT_DIR" status --short

        # エラー(1)を返す
        return 1
    fi

    # 問題なければ正常終了(0)
    return 0
}

# ---------------------------------------------------
# 関数定義: OS判定
# ---------------------------------------------------
detect_os() {
    case "$(uname -s)" in
        Darwin*)
            echo "macOS"
            ;;
        Linux*)
            echo "Linux"
            ;;
        *)
            echo "Unknown"
            ;;
    esac
}

# ===================================================
# メイン処理開始
# ===================================================

echo -e "${BLUE}=== Supplement Installer Started ===${NC}"
echo -e "Repository Root: ${SCRIPT_DIR}"

# 1. Gitチェックを実行
# --------------------
# 関数がエラー(1)を返した場合、if文の中に入りexitする
if ! check_git_status; then
    echo -e "${RED}Aborting installation.${NC}"
    exit 1
fi

# 2. OSチェックと分岐
# --------------------
OS=$(detect_os)
echo -e "Detected OS: ${GREEN}${OS}${NC}"

# 分岐処理
if [ "$OS" == "macOS" ]; then
    echo -e "${BLUE}>>> Starting macOS Setup...${NC}"

    # 実行権限の付与（念の為）
    chmod +x "$SCRIPT_DIR/mac/install.sh"

    # macOS用スクリプトの実行
    "$SCRIPT_DIR/mac/install.sh"

elif [ "$OS" == "Linux" ]; then
    echo -e "${BLUE}>>> Starting Omarchy (Linux) Setup...${NC}"

    # Omarchy (Arch Linux) かどうかの簡易チェック（任意）
    if [ -f /etc/arch-release ]; then
        echo -e "${GREEN}Arch Linux detected.${NC}"
    else
        echo -e "${YELLOW}Warning: This script is optimized for Omarchy (Arch Linux).${NC}"
    fi

    # 実行権限の付与
    chmod +x "$SCRIPT_DIR/omarchy/install_all.sh"

    # Linux用スクリプトの実行
    "$SCRIPT_DIR/omarchy/install_all.sh"

else
    echo -e "${YELLOW}Error: Unsupported OS type: $(uname -s)${NC}"
    exit 1
fi

echo -e "${GREEN}=== All Installation Scripts Completed Successfully ===${NC}"