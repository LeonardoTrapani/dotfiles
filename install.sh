#!/bin/bash
set -e

DOTFILES_DIR="$HOME/dotfiles"
REPO_URL="https://github.com/leonardotrapani/dotfiles.git"

echo "Installing dotfiles..."

# Clone the repository if it doesn't exist
if [ -d "$DOTFILES_DIR" ]; then
    echo "Dotfiles directory already exists. Pulling latest changes..."
    cd "$DOTFILES_DIR"
    git pull
else
    echo "Cloning dotfiles repository..."
    git clone "$REPO_URL" "$DOTFILES_DIR"
    cd "$DOTFILES_DIR"
fi

# Make post-install script executable
chmod +x "$DOTFILES_DIR/post-install.sh"

# Run post-install script
exec "$DOTFILES_DIR/post-install.sh"
