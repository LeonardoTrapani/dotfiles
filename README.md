# Dotfiles

My dotfiles for Arch Linux with Hyprland (using [Omarchy](https://omarchy.app))

## Setup

```bash
git clone https://github.com/leonardotrapani/dotfiles.git ~/dotfiles
cd ~/dotfiles
stow <package>  # symlink a package
```

## Stow Packages

Uses [GNU Stow](https://www.gnu.org/software/stow/) for symlink management. From the dotfiles directory:

```bash
stow <package>   # install
stow -D <package> # uninstall
```

| Package | Contents |
|---------|----------|
| `bash` | .bashrc |
| `bin` | custom scripts (~/.local/bin) |
| `git` | git config |
| `herdr` | Herdr terminal workspace manager config |
| `hypr` | Hyprland config (monitors, bindings, autostart) |
| `nvim` | Neovim config (kickstart-based) |
| `omarchy` | Omarchy branding/customization |
| `opencode` | OpenCode AI config + custom commands |
| `pi` | Pi agent config (`~/.pi/agent`) |
| `tmux` | tmux config + themes |
| `walker` | Walker launcher config |
| `waybar` | Waybar config + styling |

## Vim/Herdr navigation

Neovim installs [vim-herdr-navigation](https://github.com/paulbkim-dev/vim-herdr-navigation) through Lazy and links the same checkout into Herdr. In normal mode, `Ctrl+h/j/k/l` moves across Neovim splits and Herdr panes. Outside Herdr, navigation falls back to tmux.

## Scripts

- `post-install.sh` - full setup (packages, tmux plugins, stow bin/opencode/pi)
- `scripts/setup-nvim.sh` - nvim dependencies
- `scripts/setup-trezor.sh` - Trezor udev rules

## 1Password SSH

Go to 1Password settings -> Developer -> enable SSH agent
