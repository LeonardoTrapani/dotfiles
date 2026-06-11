#!/usr/bin/env bash
set -euo pipefail

main_worktree=${1:?missing main worktree path}
worktree_path=${2:?missing worktree path}
worktree_name=${3:?missing worktree name}
branch_name=${4:-}

script_path="$(readlink -f "${BASH_SOURCE[0]}")"
script_dir="$(cd "$(dirname "$script_path")" && pwd)"
# shellcheck source=/dev/null
source "$script_dir/pi-worktree-tmux.sh"

switch_or_launch_tmux_workspace

log "Switched worktree context: $worktree_path${branch_name:+ (branch: $branch_name)}"
