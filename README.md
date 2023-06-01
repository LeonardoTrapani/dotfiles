# dotfiles
1. Clone the repo
2. Run this script to link the files to the proper place
```
bash setup.sh
```

3. Install Homebrew
```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew bundle --file ~/.dotfiles/Brewfile
```

4. Install other software

Packer (nvim package manager)
```
git clone --depth 1 https://github.com/wbthomason/packer.nvim\
~/.local/share/nvim/site/pack/packer/start/packer.nvim
```
