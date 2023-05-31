# dotfiles
1. Clone the repo
2. Link the files to the proper folders
```ln -s ~/.dotfiles/nvim/ ~/.config
ln -s ~/.dotfiles/.zshrc ~/.zshrc
ln -s ~/.dotfiles/linearmouse/ ~/.config
ln -s ~/.dotfiles/.gitconfig ~/.gitconfig
ln -s ~/.dotfiles/.warp/ ~/.warp
ln -s ~/.dotfiles/.tmux.conf ~/.tmux.conf
ln -s ~/.dotfiles/github-copilot/ ~/.config/
```
3. Install Homebrew
```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew bundle --file ~/.dotfiles/Brewfile
```
