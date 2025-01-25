# dotfiles

1. Clone the repo
2. Run this script to link the files to the proper place

```
bash setup.sh
```

3. Install Homebrew

```zsh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew bundle --file ~/.dotfiles/Brewfile
```

4. Install Terminal

```
brew install --cask ghostty
```

4. Load Env Variables creating a file ~/.zshenv

```zsh
export ANTHROPIC_API_KEY=yourkey
export OTHER_KEYS_HERE=yourkey
```
