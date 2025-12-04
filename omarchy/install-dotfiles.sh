#!/bin/bash

set -euo pipefail

cd "$HOME/supplement/dotfiles"

# 配布（stow）
stow -v -R --no-folding -t "$HOME" zsh
stow -v -R --no-folding -t "$HOME" p10k
stow -v -R --no-folding -t "$HOME" ideavim
