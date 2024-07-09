alias vim="nvim"
alias g="git"

source ~/.dotfiles/zsh/zsh-z/zsh-z.plugin.zsh

# pnpm
export PNPM_HOME="/Users/leonardotrapani/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
