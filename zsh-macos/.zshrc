# Interactive zsh, mirroring ../bash/.bashrc: aliases, history, prompt, and tools.

# macOS's path_helper (/etc/zprofile) moves system directories first in login shells: put the
# user's back in front, as bash has them.
path=(${^user_paths}(N-/) $path)

HISTFILE="$HOME/.zsh_history"
HISTSIZE=32768
SAVEHIST="$HISTSIZE"
setopt APPEND_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE

export BAT_THEME=ansi
export MANROFFOPT="-c"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

alias v='nvim'
alias vim='nvim'
alias oc='opencode'
alias occ='opencode --continue'
alias cc='claude --dangerously-skip-permissions'
alias ccc='claude --dangerously-skip-permissions --continue'
alias cx='codex --dangerously-bypass-approvals-and-sandbox'
alias h='herdr'

if command -v eza >/dev/null 2>&1; then
  alias ls='eza -lh --group-directories-first --icons=auto'
  alias lsa='ls -a'
  alias lt='eza --tree --level=2 --long --icons --git'
  alias lta='lt -a'
fi

alias ff="fzf --preview 'bat --style=numbers --color=always {}'"
alias eff='$EDITOR "$(ff)"'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

if command -v zoxide >/dev/null 2>&1; then
  alias cd='zd'
  zd() {
    if (( $# == 0 )); then
      builtin cd ~ || return
    elif [[ -d $1 ]]; then
      builtin cd "$1" || return
    else
      if ! z "$@"; then
        echo "Error: Directory not found"
        return 1
      fi
      printf '󱞩 '
      pwd
    fi
  }
fi

# Version control and package management.
alias g='git'
alias gcm='git commit -m'
alias gcam='git commit -a -m'
alias gcad='git commit -a --amend'
alias mup='MISE_MINIMUM_RELEASE_AGE=0 mise up'
n() { if (( $# == 0 )); then command nvim .; else command nvim "$@"; fi; }

# Tmux.
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

# Original convenience aliases.
alias c='clear'
alias mkdir='mkdir -p'

command -v pyenv >/dev/null 2>&1 && eval "$(pyenv init - zsh)"
if [[ ${TERM:-} != dumb ]] && command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"
# Activate mise last so its prompt hook is retained alongside Starship/zoxide.
command -v mise >/dev/null 2>&1 && eval "$(mise activate zsh)"
command -v fzf >/dev/null 2>&1 && source <(fzf --zsh)


# Added by Antigravity CLI installer
export PATH="/Users/LeonardoTrapani/.local/bin:$PATH"
