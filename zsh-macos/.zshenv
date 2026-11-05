# Environment for every zsh, including the non-interactive shells coding agents run (T3 Code,
# Claude Code, Codex). Mirrors the exports and PATH in ../bash/.bashrc: keep them in sync.

export EDITOR=nvim
export VISUAL=nvim
export GIT_CONFIG_GLOBAL="$HOME/.config/git/config"
export PYENV_ROOT="$HOME/.pyenv"
export PNPM_HOME="$HOME/Library/pnpm"
export TMUXP_CONFIGDIR="$HOME/.config/tmux/layouts"
export BUN_INSTALL="$HOME/.bun"
export _ZO_DOCTOR=0

# Directories that come before the system's, in this order. Missing ones are skipped (N-/).
user_paths=(
  "$HOME/.local/bin"
  "$HOME/bin"
  "$HOME/go/bin"
  "$HOME/.resend/bin"
  "$BUN_INSTALL/bin"
  "$PNPM_HOME"
  "$PYENV_ROOT/bin"
  /opt/homebrew/bin
  /opt/homebrew/sbin
)

typeset -U path
path=(${^user_paths}(N-/) $path)
