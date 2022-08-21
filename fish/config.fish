if status is-interactive
and not set -q TMUX
  tmux new-session -A -s 0
end

alias vim=nvim
alias g=git
