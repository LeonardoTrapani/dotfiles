#!/bin/bash
set -e

echo "Setting up neovim config..."

# Remove omarchy's default nvim config
rm -rf ~/.config/nvim

# Stow our nvim config
cd ~/dotfiles && stow --no-folding nvim

# Create symlink for omarchy theme
ln -snf ~/.config/omarchy/current/theme/neovim.lua ~/.config/nvim/lua/omarchy-theme.lua

echo "Neovim setup complete!"
