#!/bin/bash
set -euo pipefail

echo "=== 08-install-dotfiles.sh ==="
echo "Linking configuration files with stow..."

# Stowのインストール確認
if ! command -v stow >/dev/null 2>&1; then
  echo "stow not found, installing..."
  sudo apt update
  sudo apt install -y stow
fi

HOME_DIR="${HOME}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "${SCRIPT_DIR}/../dotfiles" && pwd)"

if [ ! -d "${DOTFILES_DIR}" ]; then
  echo "Error: Dotfiles directory not found at ${DOTFILES_DIR}"
  exit 1
fi

cd "${DOTFILES_DIR}"

echo "Home directory: ${HOME_DIR}"
echo "Dotfiles directory: ${DOTFILES_DIR}"

# ---------------------------------------------------------
# Conflict Resolution Helper
# 邪魔なファイル（リンクでない実ファイル）があったらバックアップする関数
# ---------------------------------------------------------
resolve_conflict() {
  local target_file="${HOME_DIR}/$1"

  # ファイルが存在し、かつシンボリックリンクではない場合
  if [ -e "${target_file}" ] && [ ! -L "${target_file}" ]; then
    echo "Conflict detected: ${target_file} is a regular file."
    echo "Backing up to ${target_file}.bak..."
    mv "${target_file}" "${target_file}.bak"
  fi
}

# ---------------------------------------------------------
# Stow Execution
# ---------------------------------------------------------
link_dotfile() {
  local package=$1
  if [ -d "${package}" ]; then
    echo "Deploying ${package} dotfiles..."

    # 1. コンフリクト解消（主要なファイルのみチェック）
    # パッケージ名に応じて、邪魔になりそうなファイル名を指定して退避
    case "${package}" in
      "zsh")
        resolve_conflict ".zshrc"
        resolve_conflict ".zshenv"
        resolve_conflict ".zprofile"
        ;;
      "p10k")
        resolve_conflict ".p10k.zsh"
        ;;
      "ideavim")
        resolve_conflict ".ideavimrc"
        ;;
    esac

    # 2. Stow実行
    # -v: 詳細表示
    # -R: Restow (リンクの再生成・不要リンクの削除)
    # --no-folding: ディレクトリをリンクせず、中身のファイル個別にリンクする（推奨）
    # ※ --adopt は削除しました（リポジトリを破壊しないため）
    stow -v -R --no-folding -t "${HOME_DIR}" "${package}"
  else
    echo "Warning: ${package} directory not found in dotfiles, skipping."
  fi
}

link_dotfile "zsh"
link_dotfile "p10k"
link_dotfile "ideavim"
link_dotfile "fcitx5"

echo "Dotfiles deployment completed."