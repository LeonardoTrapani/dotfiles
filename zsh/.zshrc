alias vim="nvim"
alias g="git"
alias npm="pnpm"

source ~/.dotfiles/zsh/zsh-z/zsh-z.plugin.zsh

eval "$(fzf --zsh)"

# pnpm
export PNPM_HOME="/Users/leonardotrapani/Library/pnpm"
case ":$PATH:" in
*":$PNPM_HOME:"*) ;;
*) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

export PATH="/opt/homebrew/bin:$PATH"
export PATH="/opt/homebrew/opt/python@3.11/libexec/bin:$PATH"
