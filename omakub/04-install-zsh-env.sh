#!/bin/bash
set -euo pipefail

echo "=== 04-install-zsh-env.sh ==="
echo "Setting up shell environment and basic tools..."

# 1. apt install zsh curl git
echo "Installing zsh, curl, git..."
sudo apt update
sudo apt install -y zsh curl git

# 2. Oh My Zsh
if [ -d "${HOME}/.oh-my-zsh" ]; then
  echo "Oh My Zsh already installed."
else
  echo "Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# 3. Mise
echo "Installing mise..."
if command -v mise >/dev/null 2>&1; then
  MISE_BIN="$(command -v mise)"
elif [ -x "${HOME}/.local/bin/mise" ]; then
  MISE_BIN="${HOME}/.local/bin/mise"
else
  curl https://mise.run | sh
  MISE_BIN="${HOME}/.local/bin/mise"
fi

if [ -x "${MISE_BIN}" ]; then
  "${MISE_BIN}" use -g github-cli lazygit
else
  echo "Error: mise binary not found."
  exit 1
fi

# 4. Shell: chsh
ZSH_PATH="$(command -v zsh)"
if [ "${SHELL}" != "${ZSH_PATH}" ]; then
  echo "Changing default shell to zsh..."
  sudo chsh -s "${ZSH_PATH}" "${USER}"
else
  echo "Zsh is already the default shell."
fi

echo "Shell environment setup completed."
