#!/usr/bin/env bash
set -euo pipefail

echo "🔧 Starting dotfiles setup..."

# Install TPM (Tmux Plugin Manager)
echo "🔧 Installing TPM (Tmux Plugin Manager)..."
TPM_DIR="$HOME/.tmux/plugins/tpm"

if [ -d "$TPM_DIR" ]; then
    echo "✅ TPM already installed at $TPM_DIR"
else
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
    echo "✅ TPM installed"
fi

### -----------------------------
# Stow files in the Stow directory
### -----------------------------
echo "🔧 Stowing dotfiles..."
STOW_DIR="$HOME/dotfiles/Stow"
if [ -d "$STOW_DIR" ]; then
    cd "$STOW_DIR" || exit
    for dir in */; do
        dir=${dir%/}  # Remove trailing slash
        echo "🔧 Stowing $dir..."
        stow -v -t "$HOME" "$dir"
    done
    echo "✅ Dotfiles stowed successfully."
else
    echo "❌ Stow directory not found at $STOW_DIR"
fi


# -----------------------------
# Run installation scripts
# -----------------------------
echo "🔧 Running installation scripts..."
INSTALL_SCRIPT="$HOME/dotfiles/Scripts/install.sh"
if [ -f "$INSTALL_SCRIPT" ]; then
    chmod +x "$INSTALL_SCRIPT"
    "$INSTALL_SCRIPT"
    echo "✅ Installation scripts executed successfully."
else
    echo "❌ Installation script not found at $INSTALL_SCRIPT"
fi

echo "✅ Setup complete. You may want to restart your shell."
