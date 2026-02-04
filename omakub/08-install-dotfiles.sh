#!/bin/bash
set -euo pipefail

echo "=== 08-install-dotfiles.sh ==="
echo "Linking configuration files with stow..."

if ! command -v stow >/dev/null 2>&1; then
  echo "stow not found, installing..."
  sudo apt update
  sudo apt install -y stow
fi

HOME_DIR="${HOME}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# 既存の構成では ../dotfiles にあると想定
DOTFILES_DIR="$(cd "${SCRIPT_DIR}/../dotfiles" && pwd)"

if [ ! -d "${DOTFILES_DIR}" ]; then
  echo "Error: Dotfiles directory not found at ${DOTFILES_DIR}"
  exit 1
fi

cd "${DOTFILES_DIR}"

echo "Home directory: ${HOME_DIR}"
echo "Dotfiles directory: ${DOTFILES_DIR}"

link_dotfile() {
  local target=$1
  if [ -d "${target}" ]; then
    echo "Deploying ${target} dotfiles..."
    stow -v -R --adopt --no-folding -t "${HOME_DIR}" "${target}"
  else
    echo "Warning: ${target} directory not found in dotfiles, skipping."
  fi
}

link_dotfile "zsh"
link_dotfile "p10k"
link_dotfile "ideavim"
link_dotfile "fcitx5"

echo "Dotfiles deployment completed."
