# If not running interactively, don't do anything.
[[ $- != *i* ]] && return

# Private environment variables (not committed).
[[ -f "$HOME/.bash_env" ]] && source "$HOME/.bash_env"

# Omarchy's portable interactive-shell defaults.
shopt -s histappend
HISTCONTROL=ignoreboth
HISTSIZE=32768
HISTFILESIZE="$HISTSIZE"
set +h
export BAT_THEME=ansi
export MANROFFOPT="-c"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# Load Omarchy defaults when this config is used on an Omarchy installation.
[[ -f "$HOME/.local/share/omarchy/default/bash/rc" ]] \
  && source "$HOME/.local/share/omarchy/default/bash/rc"

export EDITOR=nvim
export VISUAL=nvim
export GIT_CONFIG_GLOBAL="$HOME/.config/git/config"
export PYENV_ROOT="$HOME/.pyenv"
export PNPM_HOME="$HOME/Library/pnpm"
export TMUXP_CONFIGDIR="$HOME/.config/tmux/layouts"

path_prepend() {
  [[ -d "$1" && ":$PATH:" != *":$1:"* ]] && PATH="$1:$PATH"
}

path_prepend "/opt/homebrew/sbin"
path_prepend "/opt/homebrew/bin"
path_prepend "$PYENV_ROOT/bin"
path_prepend "$PNPM_HOME"
path_prepend "$HOME/go/bin"
path_prepend "$HOME/bin"
path_prepend "$HOME/.local/bin"
export PATH
unset -f path_prepend

# Text editors and agents.
alias v='nvim'
alias vim='nvim'
alias oc='opencode'
alias occ='opencode --continue'
alias cc='claude --dangerously-skip-permissions'
alias ccc='claude --dangerously-skip-permissions --continue'
alias cx='codex --dangerously-bypass-approvals-and-sandbox'
alias h='herdr'

# Omarchy-style file navigation and previews.
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
alias npm='pnpm'
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
export _ZO_DOCTOR=0

command -v pyenv >/dev/null 2>&1 && eval "$(pyenv init - bash)"

if [[ ${TERM:-} != dumb ]] && command -v starship >/dev/null 2>&1; then
  eval "$(starship init bash)"
fi

command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init bash)"
# Activate mise last so its prompt hook is retained alongside Starship/zoxide.
command -v mise >/dev/null 2>&1 && eval "$(mise activate bash)"

if command -v fzf >/dev/null 2>&1; then
  eval "$(fzf --bash)"
fi

if [[ -r /opt/homebrew/etc/profile.d/bash_completion.sh ]]; then
  source /opt/homebrew/etc/profile.d/bash_completion.sh
fi

if command -v op >/dev/null 2>&1; then
  source <(op completion bash)
fi

# Compile a LaTeX file, watch its directory, and clean generated artifacts.
# On macOS, install fswatch; on Linux this continues to use inotifywait.
latcompile() {
  local file="$1"
  [[ -z "$file" || "${file##*.}" != tex || ! -f "$file" ]] && {
    echo "Usage: latcompile path/to/file.tex"; return 2; }

  local engine="" e
  for e in xelatex lualatex pdflatex; do
    command -v "$e" >/dev/null 2>&1 && { engine="$e"; break; }
  done
  [[ -z "$engine" ]] && { echo "No LaTeX engine found."; return 2; }

  local dir base
  dir="$(dirname -- "$file")"
  base="$(basename -- "$file" .tex)"

  _latcleanup() {
    rm -f -- "$dir/$base".{aux,log,out,toc,lof,lot,bbl,blg,fls,fdb_latexmk,nav,snm,synctex.gz,xdv,bcf,run.xml,ilg,idx,ind,thm,acn,acr,alg,glg,glo,gls,ist,loe,los,loc} 2>/dev/null
  }
  trap _latcleanup EXIT INT TERM

  "$engine" -interaction=nonstopmode -halt-on-error "$file" && _latcleanup

  if command -v fswatch >/dev/null 2>&1; then
    fswatch -o "$dir" | while read -r _; do
      "$engine" -interaction=nonstopmode -halt-on-error "$file" && _latcleanup
    done
  elif command -v inotifywait >/dev/null 2>&1; then
    while inotifywait -qq -e close_write,move,create,delete "$dir"; do
      "$engine" -interaction=nonstopmode -halt-on-error "$file" && _latcleanup
    done
  else
    echo "Install fswatch (macOS) or inotify-tools (Linux) to watch for changes."
    return 2
  fi
}

# Linux-only OpenVPN helpers remain available when openvpn3 is installed.
vpnrefresh() {
  local config="${1:-datapizza}"
  command -v openvpn3 >/dev/null 2>&1 || {
    echo "openvpn3 is not installed"; return 127; }
  if openvpn3 sessions-list 2>/dev/null | rg -q "Config name: $config"; then
    openvpn3 session-manage --config "$config" --disconnect >/dev/null 2>&1 || true
    openvpn3 session-manage --cleanup >/dev/null 2>&1 || true
  fi
  openvpn3 session-start --config "$config"
}

vpnrestart() {
  local config="${1:-datapizza}"
  command openvpn3 session-manage --config "$config" --restart --timeout 45
}

vpnlogs() {
  local since="${1:--30m}"
  command -v journalctl >/dev/null 2>&1 || {
    echo "journalctl is not available on macOS"; return 127; }
  journalctl --no-pager --since "$since" \
    | rg -i 'openvpn|datapizza|403|forbidden|auth|failed|error|expire|connect|tls|http|saml|oauth|url|web'
}

alias dpvpn='vpnrefresh datapizza'

# Portable Omarchy helpers.
compress() { tar -czf "${1%/}.tar.gz" "${1%/}"; }
alias decompress='tar -xzf'

fip() {
  (( $# < 2 )) && echo "Usage: fip <host> <port1> [port2] ..." && return 1
  local host="$1" port
  shift
  for port in "$@"; do
    ssh -f -N -L "${port}:localhost:${port}" "$host" \
      && echo "Forwarding localhost:$port -> $host:$port"
  done
}

dip() {
  (( $# == 0 )) && echo "Usage: dip <port1> [port2] ..." && return 1
  local port
  for port in "$@"; do
    pkill -f "ssh.*-L ${port}:localhost:${port}" \
      && echo "Stopped forwarding port $port" \
      || echo "No forwarding on port $port"
  done
}

lip() {
  pgrep -af "ssh.*-L [0-9]+:localhost:[0-9]+" || echo "No active forwards"
}
