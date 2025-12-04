#!/bin/bash

set -euo pipefail

cd "$HOME/supplement/dotfiles"

# 既存ファイルがあってもエラーにせず、リンクに置き換える
stow -v -R --adopt --no-folding -t "$HOME" zsh
stow -v -R --adopt --no-folding -t "$HOME" p10k
stow -v -R --adopt --no-folding -t "$HOME" ideavim