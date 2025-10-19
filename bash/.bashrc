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

export GIT_CONFIG_GLOBAL=~/.config/git/config

export PATH=$HOME/go/bin:$PATH

if command -v pyenv &> /dev/null; then
  eval "$(pyenv init -)"
fi

if command -v op &> /dev/null; then
  eval "$(op completion bash)"
fi

. "$HOME/.local/share/../bin/env"
