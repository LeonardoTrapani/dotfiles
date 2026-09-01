#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BREWFILE="$DOTFILES_DIR/macos/Brewfile"
BACKUP_DIR="$HOME/.dotfiles-backups/$(date +%Y%m%d-%H%M%S)"
PACKAGES=(
  bash
  bash-macos
  git-macos
  ghostty-macos
  starship-macos
  herdr
  tmux
  nvim
  bin
  opencode
  mcp
  pi
)
DRY_RUN=false

usage() {
  cat <<'EOF'
Usage: macos/setup.sh [--dry-run]

Install the macOS terminal toolchain and link compatible dotfiles.
Existing files that conflict with Stow are moved into a timestamped backup.
SSH configuration and 1Password data are never modified.
EOF
}

log() { printf '[macos-setup] %s\n' "$*"; }

run() {
  if "$DRY_RUN"; then
    printf '+ '
    printf '%q ' "$@"
    printf '\n'
  else
    "$@"
  fi
}

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    -h|--help) usage; exit 0 ;;
    *) printf 'Unknown argument: %s\n' "$arg" >&2; usage >&2; exit 2 ;;
  esac
done

if [[ "$(uname -s)" != Darwin ]]; then
  printf 'This installer is for macOS only.\n' >&2
  exit 1
fi

if ! command -v brew >/dev/null 2>&1; then
  printf 'Homebrew is required. Install it from https://brew.sh and rerun this script.\n' >&2
  exit 1
fi

log "Installing command-line tools from macos/Brewfile"
if "$DRY_RUN"; then
  run brew bundle check --file "$BREWFILE"
else
  brew bundle --file "$BREWFILE"
fi

# Older revisions used a zsh-macos package. Remove only links owned by that
# package when upgrading; never remove an unrelated user-managed .zshrc.
if [[ -d "$DOTFILES_DIR/zsh-macos" ]] && command -v stow >/dev/null 2>&1; then
  log "Removing legacy zsh-macos links"
  run stow --dir "$DOTFILES_DIR" --target "$HOME" --delete zsh-macos
fi

# Migrate revisions that linked ~/.bashrc from bash-macos. The canonical file
# now lives in the shared bash package.
if [[ -L "$HOME/.bashrc" \
    && "$(readlink "$HOME/.bashrc")" == *"dotfiles/bash-macos/.bashrc" ]]; then
  log "Removing legacy bash-macos .bashrc link"
  run unlink "$HOME/.bashrc"
fi

backup_conflicts() {
  local package="$1" source relative target
  while IFS= read -r -d '' source; do
    relative="${source#"$DOTFILES_DIR/$package/"}"
    target="$HOME/$relative"
    if [[ -e "$target" || -L "$target" ]]; then
      if [[ -L "$target" && "$(realpath "$target")" == "$source" ]]; then
        continue
      fi
      log "Backing up $target to $BACKUP_DIR/$relative"
      run mkdir -p "$BACKUP_DIR/$(dirname "$relative")"
      run mv "$target" "$BACKUP_DIR/$relative"
    fi
  done < <(find "$DOTFILES_DIR/$package" -type f -print0)
}

for package in "${PACKAGES[@]}"; do
  backup_conflicts "$package"
  log "Linking $package"
  run stow --dir "$DOTFILES_DIR" --target "$HOME" --no-folding "$package"
done

log "Installing Pi extension dependencies"
while IFS= read -r -d '' package_json; do
  extension_dir="$(dirname "$package_json")"
  # Linux-generated lockfiles can omit optional macOS packages. Install from
  # package.json without rewriting the shared lockfile on either platform.
  run npm install --prefix "$extension_dir" --package-lock=false

  extension_name="$(basename "$extension_dir")"
  live_node_modules="$HOME/.pi/agent/extensions/$extension_name/node_modules"
  if [[ -e "$live_node_modules" || -L "$live_node_modules" ]]; then
    if [[ -L "$live_node_modules" \
        && "$(realpath "$live_node_modules")" == "$extension_dir/node_modules" ]]; then
      continue
    fi
    log "Backing up $live_node_modules to $BACKUP_DIR/.pi/agent/extensions/$extension_name/node_modules"
    run mkdir -p "$BACKUP_DIR/.pi/agent/extensions/$extension_name"
    run mv "$live_node_modules" "$BACKUP_DIR/.pi/agent/extensions/$extension_name/node_modules"
  fi
  run ln -s "$extension_dir/node_modules" "$live_node_modules"
done < <(find "$DOTFILES_DIR/pi/.pi/agent/extensions" -mindepth 2 -maxdepth 2 \
  -name package.json -print0)

log "Installing Neovim plugins"
run nvim --headless "+Lazy! sync" "+qa"

HERDR_NVIM_PLUGIN="$HOME/.local/share/nvim/lazy/vim-herdr-navigation"
if "$DRY_RUN"; then
  run herdr plugin link "$HERDR_NVIM_PLUGIN"
elif [[ -d "$HERDR_NVIM_PLUGIN" ]]; then
  herdr plugin link "$HERDR_NVIM_PLUGIN" >/dev/null
else
  printf 'Expected Neovim/Herdr plugin checkout is missing: %s\n' \
    "$HERDR_NVIM_PLUGIN" >&2
  exit 1
fi

if ! "$DRY_RUN"; then
  git lfs install --skip-repo
fi

log "Done. Open a new Ghostty window (configured for Bash), then run: macos/verify.sh"
