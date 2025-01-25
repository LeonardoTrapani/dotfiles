#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE}")"

git pull origin main

function doIt() {
  ln -sf ~/.dotfiles/nvim/ ~/.config
  ln -sf ~/.dotfiles/linearmouse/ ~/.config
  ln -sf ~/.dotfiles/.gitconfig ~/.gitconfig
  ln -sf ~/.dotfiles/.tmux.conf ~/.tmux.conf
  ln -sf ~/.dotfiles/zsh/.zshenv ~/.zshenv
  ln -sf ~/.dotfiles/zsh/.zshrc ~/.zshrc
  ln -sf ~/.dotfiles/zsh/.zprofile ~/.zprofile
  ln -sf ~/.dotfiles/zsh/.p10k.zsh ~/.p10k.zsh
  ln -sf ~/.dotfiles/ghostty/ ~/.config
}

if [ "$1" == "--force" -o "$1" == "-f" ]; then
  doIt
else
  read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1
  echo ""
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    doIt
  fi
fi
unset doIt
