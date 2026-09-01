# If not running interactively, don't do anything.
[[ $- != *i* ]] && return

# Private environment variables (not committed).
[[ -f "$HOME/.bash_env" ]] && source "$HOME/.bash_env"

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

# Version control and package management.
alias g='git'
alias npm='pnpm'

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
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init bash)"
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
