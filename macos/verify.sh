#!/usr/bin/env bash
set -u

failures=0
check_command() {
  if command -v "$1" >/dev/null 2>&1; then
    printf 'ok  %-12s %s\n' "$1" "$(command -v "$1")"
  else
    printf 'ERR %-12s missing\n' "$1"
    failures=$((failures + 1))
  fi
}

for command in git gh nvim tmux stow fzf rg fd bat eza zoxide mise; do
  check_command "$command"
done

if ssh -T -o BatchMode=yes -o ConnectTimeout=10 git@github.com 2>&1 \
    | grep -q "successfully authenticated"; then
  printf 'ok  %-12s authenticated\n' github-ssh
else
  printf 'ERR %-12s authentication failed\n' github-ssh
  failures=$((failures + 1))
fi

if [[ -L "$HOME/.zshrc" && -L "$HOME/.config/git/config" ]]; then
  printf 'ok  %-12s linked\n' dotfiles
else
  printf 'ERR %-12s expected links missing\n' dotfiles
  failures=$((failures + 1))
fi

exit "$failures"
