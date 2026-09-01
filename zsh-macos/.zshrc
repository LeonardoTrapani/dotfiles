# Private environment variables (not committed)
[[ -f "$HOME/.zsh_env" ]] && source "$HOME/.zsh_env"

export EDITOR=nvim
export VISUAL=nvim
export GIT_CONFIG_GLOBAL="$HOME/.config/git/config"
export PNPM_HOME="$HOME/Library/pnpm"
export PYENV_ROOT="$HOME/.pyenv"

path=(
  "$HOME/.local/bin"
  "$HOME/bin"
  "$HOME/go/bin"
  "$PNPM_HOME"
  "$PYENV_ROOT/bin"
  /opt/homebrew/bin
  /opt/homebrew/sbin
  $path
)
export PATH

alias g=git
alias v=nvim
alias vim=nvim
alias c=clear
alias mkdir='mkdir -p'
alias npm=pnpm
alias tls='tmuxp load'
alias tks='tmux kill-session'
alias tksv='tmux kill-server'

tn() {
  if [[ -n "${TMUX:-}" ]]; then
    tmux switch-client -t "$1" 2>/dev/null \
      || { tmux new-session -d -s "$1" && tmux switch-client -t "$1"; }
  else
    tmux new -A -s "$1"
  fi
}

command -v brew >/dev/null 2>&1 && eval "$(brew shellenv)"
command -v pyenv >/dev/null 2>&1 && eval "$(pyenv init - zsh)"
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"
command -v mise >/dev/null 2>&1 && eval "$(mise activate zsh)"
command -v fzf >/dev/null 2>&1 && source <(fzf --zsh)
command -v op >/dev/null 2>&1 && eval "$(op completion zsh)"
