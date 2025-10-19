#!/bin/bash
set -e

sudo pacman -S --needed - < pacman.txt
yay -S --needed --noconfirm - < yay_aur.txt

omarchy-webapp-install "Tasks" https://tasks.google.com/tasks/ https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/todoist.svg
omarchy-webapp-install "Bocconi" https://youatb.unibocconi.it/ https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/synology-calendar.png

rm -rf ~/.tmux/plugins
mkdir -p ~/.tmux/plugins
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm 2>/dev/null || true
~/.tmux/plugins/tpm/bin/install_plugins

./scripts/setup-trezor.sh

echo "Installation complete!"
