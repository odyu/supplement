#!/bin/bash

cd $HOME/supplement/dotfiles

stow -v -R --no-folding -t "$HOME" zsh
stow -v -R --no-folding -t "$HOME" p10k
stow -v -R --no-folding -t "$HOME" ideavim
