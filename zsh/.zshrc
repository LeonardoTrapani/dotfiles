# aliases
alias vim="nvim"
alias v="nvim"
alias g="git"
alias npm="pnpm"
alias ls='ls --color'
alias tls='tmuxp load'

unset MAILCHECK

# pnpm
export PNPM_HOME="/Users/leonardotrapani/Library/pnpm"
case ":$PATH:" in
*":$PNPM_HOME:"*) ;;
*) export PATH="$PNPM_HOME:$PATH" ;;
esac

# Homebrew
export PATH="/opt/homebrew/bin:$PATH"
export PATH="/opt/homebrew/opt/python@3.11/libexec/bin:$PATH"

eval "$(fzf --zsh)"

eval "$(starship init zsh)"
export STARSHIP_CONFIG=~/.config/starship/starship.toml

export TMUXP_CONFIGDIR=$HOME/.config/tmux/layouts/

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
# [[ ! -f ~/.dotfiles/zsh/.p10k.zsh ]] || source ~/.dotfiles/zsh/.p10k.zsh

# source $(brew --prefix)/share/powerlevel10k/powerlevel10k.zsh-theme
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh-completions:$FPATH

  autoload -Uz compinit
  compinit
fi

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

. $HOMEBREW_PREFIX/etc/profile.d/z.sh

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-j}'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' menu select

# Keybinds
bindkey "^[[A" history-search-backward
bindkey "^[[B" history-search-forward

