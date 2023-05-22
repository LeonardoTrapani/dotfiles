alias vim=nvim
alias g=git

if type -q exa
  alias ll "exa -l -g --icons"
  alias lla "ll -a"
end

#Automatically start TMUX
#if status is-interactive
#    and not set -q TMUX
#    tmux new-session -A -s 0
#end
