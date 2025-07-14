# Add user configurations here
# For HyDE to not touch your beloved configurations,
# we added 2 files to the project structure:
# 1. ~/.user.zsh - for customizing the shell related hyde configurations
# 2. ~/.zshenv - for updating the zsh environment variables handled by HyDE // this will be modified across updates

#  Plugins 
# oh-my-zsh plugins are loaded  in ~/.user.zsh file, see the file for more information

unset MAILCHECK

#  Variables 
# Add environment variables here

# -----------------------------
# PNPM
# -----------------------------
export PNPM_HOME="$HOME/.local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"


# -----------------------------
# Tmuxp
# -----------------------------
export TMUXP_CONFIGDIR="$HOME/.config/tmux/layouts"

# -----------------------------
# Private Environment Variables
# -----------------------------
# Load private environment variables (API keys, secrets)
ENV_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/environment"
[ -f "$ENV_DIR/private.env" ] && source "$ENV_DIR/private.env"

# -----------------------------
# Tools (fzf, zoxide)
# -----------------------------
eval "$(zoxide init zsh)"

#  This is your file 
# Add your configurations here
export EDITOR=nvim
# export EDITOR=code

unset -f command_not_found_handler # Uncomment to prevent searching for commands not found in package manager
