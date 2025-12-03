#!/bin/bash

set -euo pipefail

ANYENV_DIR="$HOME/.anyenv"
if [ -d "$ANYENV_DIR" ]; then
  echo "[anyenv] Already installed at $ANYENV_DIR"
else
  echo "[anyenv] Installing to $ANYENV_DIR ..."
  git clone https://github.com/anyenv/anyenv "$ANYENV_DIR"
fi

if [ -d "$HOME/.oh-my-zsh" ]; then
  echo "[oh-my-zsh] Already installed."
else
  echo "[oh-my-zsh] Installing..."
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

ZSH_CUSTOM_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
P10K_DIR="$ZSH_CUSTOM_DIR/themes/powerlevel10k"
if [ -d "$P10K_DIR" ]; then
  echo "[p10k] Already installed at $P10K_DIR"
else
  echo "[p10k] Installing to $P10K_DIR ..."
  mkdir -p "$ZSH_CUSTOM_DIR/themes"
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
fi

echo "[Middleware] Completed."
