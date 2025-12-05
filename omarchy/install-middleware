#!/bin/bash
set -euo pipefail

echo "🛠️ [Middleware] Start"

ANYENV_DIR="$HOME/.anyenv"
if ! [ -d "$ANYENV_DIR" ]; then
  echo "Cloning anyenv into $ANYENV_DIR"
  git clone https://github.com/anyenv/anyenv "$ANYENV_DIR"
else
  echo "anyenv already exists at $ANYENV_DIR, skipping clone."
fi

if ! [ -d "$HOME/.oh-my-zsh" ]; then
  echo "Installing oh-my-zsh (non-interactive)"
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "oh-my-zsh already installed, skipping."
fi

ZSH_CUSTOM_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
P10K_DIR="$ZSH_CUSTOM_DIR/themes/powerlevel10k"
if ! [ -d "$P10K_DIR" ]; then
  echo "Installing powerlevel10k theme into $P10K_DIR"
  mkdir -p "$ZSH_CUSTOM_DIR/themes"
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
else
  echo "powerlevel10k already present, skipping."
fi

echo "🎉 [Middleware] Completed"
