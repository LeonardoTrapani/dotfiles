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

for command in bash git gh nvim tmux stow fzf rg fd bat eza zoxide mise; do
  check_command "$command"
done

if /opt/homebrew/bin/bash -lic 'exit' >/dev/null 2>&1; then
  printf 'ok  %-12s clean startup\n' bash
else
  printf 'ERR %-12s startup failed\n' bash
  failures=$((failures + 1))
fi

tmux_socket="dotfiles-verify-$$"
if tmux -L "$tmux_socket" -f "$HOME/.config/tmux/tmux.conf" \
    new-session -d -s verify 2>/dev/null; then
  tmux -L "$tmux_socket" kill-server 2>/dev/null || true
  printf 'ok  %-12s config loaded\n' tmux-config
else
  printf 'ERR %-12s config failed\n' tmux-config
  failures=$((failures + 1))
fi

if ssh -T -o BatchMode=yes -o ConnectTimeout=10 git@github.com 2>&1 \
    | grep -q "successfully authenticated"; then
  printf 'ok  %-12s authenticated\n' github-ssh
else
  printf 'ERR %-12s authentication failed\n' github-ssh
  failures=$((failures + 1))
fi

if [[ -L "$HOME/.bashrc" && -L "$HOME/.bash_profile" \
    && -L "$HOME/.config/git/config" ]]; then
  printf 'ok  %-12s linked\n' dotfiles
else
  printf 'ERR %-12s expected links missing\n' dotfiles
  failures=$((failures + 1))
fi

exit "$failures"
