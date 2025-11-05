# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
source ~/.local/share/omarchy/default/bash/rc

# Find packages without leaving the terminal
alias yayf="yay -Slq | fzf --multi --preview 'yay -Sii {1}' --preview-window=down:75% | xargs -ro yay -S"

# Text editors
alias v='nvim'
alias vim='nvim'

# Version control
alias g='git'

# Package manager
alias npm='pnpm'

# Tmux
alias tls='tmuxp load'
alias tks='tmux kill-session'
alias tksv='tmux kill-server'

tn() {
  if [ -n "$TMUX" ]; then
    tmux switch-client -t "$1" 2>/dev/null || tmux new-session -d -s "$1" && tmux switch-client -t "$1"
  else
    tmux new -A -s "$1"
  fi
}

# Clear terminal
alias c='clear'

# Create directory and parent directories if needed
alias mkdir='mkdir -p'

export _ZO_DOCTOR=0

export TMUXP_CONFIGDIR="$HOME/.config/tmux/layouts"

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

export PATH="/home/trapani/.cache/.bun/bin:$PATH"

export GIT_CONFIG_GLOBAL=~/.config/git/config

export PATH=$HOME/go/bin:$PATH

if command -v pyenv &> /dev/null; then
  eval "$(pyenv init -)"
fi

if command -v op &> /dev/null; then
  eval "$(op completion bash)"
fi

. "$HOME/.local/share/../bin/env"


latcompile() {
  local file="$1"
  [[ -z "$file" || "${file##*.}" != "tex" || ! -f "$file" ]] && {
    echo "Usage: latcompile path/to/file.tex"; return 2; }

  # Choose a LaTeX engine (first available)
  local engine=""
  for e in xelatex lualatex pdflatex; do
    command -v "$e" >/dev/null 2>&1 && { engine="$e"; break; }
  done
  [[ -z "$engine" ]] && { echo "No LaTeX engine found. Install TeX Live."; return 2; }

  # Need inotifywait for file watching
  command -v inotifywait >/dev/null 2>&1 || {
    echo "inotifywait not found. Install: sudo pacman -S inotify-tools"; return 2; }

  local dir base
  dir="$(dirname -- "$file")"
  base="$(basename -- "$file" .tex)"

  _latcleanup() {
    rm -f -- "$dir/$base".{aux,log,out,toc,lof,lot,bbl,blg,fls,fdb_latexmk,nav,snm,synctex.gz,xdv,bcf,run.xml,ilg,idx,ind,thm,acn,acr,alg,glg,glo,gls,ist,loe,los,loc} 2>/dev/null
  }
  trap _latcleanup EXIT INT TERM

  # Initial build
  "$engine" -interaction=nonstopmode -halt-on-error "$file" && _latcleanup

  # Watch dir; rebuild when source/bib/assets change
  while inotifywait -qq -e close_write,move,create,delete "$dir"; do
    # Rebuild only if relevant files changed
    if find "$dir" -maxdepth 1 -type f | grep -qE "$base\.tex|\.bib$|\.sty$|\.cls$|\.png$|\.jpe?g$|\.pdf$|\.eps$|\.svg$|\.tikz$"; then
      "$engine" -interaction=nonstopmode -halt-on-error "$file" && _latcleanup
    fi
  done
}
