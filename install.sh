#!/bin/bash

set -e # エラーが発生したら即終了

# 色の定義
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# スクリプトが存在するディレクトリの絶対パスを取得
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo -e "${BLUE}=== Supplement Installer Started ===${NC}"
echo -e "Repository Root: ${SCRIPT_DIR}"

# OS判定と分岐
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

OS=$(detect_os)
echo -e "Detected OS: ${GREEN}${OS}${NC}"

# 共通関数の読み込み（必要であれば common.sh などを作ってここで source する）

# 分岐処理
if [ "$OS" == "macOS" ]; then
    echo -e "${BLUE}>>> Starting macOS Setup...${NC}"

    # 実行権限の付与（念の為）
    chmod +x "$SCRIPT_DIR/mac/install.sh"

    # macOS用スクリプトの実行
    "$SCRIPT_DIR/mac/install_mac.sh"

elif [ "$OS" == "Linux" ]; then
    echo -e "${BLUE}>>> Starting Omarchy (Linux) Setup...${NC}"

    # Omarchy (Arch Linux) かどうかの簡易チェック（任意）
    if [ -f /etc/arch-release ]; then
        echo -e "${GREEN}Arch Linux detected.${NC}"
    else
        echo -e "${YELLOW}Warning: This script is optimized for Omarchy (Arch Linux).${NC}"
    fi

    # 実行権限の付与
    chmod +x "$SCRIPT_DIR/omarchy/install.sh"

    # Linux用スクリプトの実行
    "$SCRIPT_DIR/omarchy/install_linux.sh"

else
    echo -e "${YELLOW}Error: Unsupported OS type: $(uname -s)${NC}"
    exit 1
fi

echo -e "${GREEN}=== All Installation Scripts Completed Successfully ===${NC}"