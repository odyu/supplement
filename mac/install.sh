#!/bin/bash

# macOS用インストーラーのテンプレート

echo "---------------------------------------"
echo "Running macOS specific installation..."
echo "---------------------------------------"

# ここにMac固有の処理を書く

# 例: Homebrewのチェックとインストール
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Homebrew is already installed."
fi

# 例: Stowの実行（親ディレクトリのdotfilesを対象にする）
# cd "$(dirname "$0")/../dotfiles" && stow .

echo "macOS setup finished."