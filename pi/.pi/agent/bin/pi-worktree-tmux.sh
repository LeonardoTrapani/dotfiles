#!/usr/bin/env bash

log() {
  printf '[pi-worktrees] %s\n' "$*"
}

sanitize_name() {
  printf '%s' "$1" | tr ' /:' '---' | tr -cd '[:alnum:]_.-'
}

worktree_safe_name() {
  local safe_name
  safe_name="$(sanitize_name "$worktree_name")"
  if [[ -z "$safe_name" ]]; then
    safe_name="worktree"
  fi
  printf '%s' "$safe_name"
}

worktree_session_name() {
  printf 'wt-%s' "$(worktree_safe_name)"
}

tmux_editor_command() {
  local shell_path="${SHELL:-/bin/bash}"
  printf "%s -lc 'exec nvim'" "$shell_path"
}

tmux_agent_command() {
  local shell_path="${SHELL:-/bin/bash}"
  printf "%s -lc 'if command -v py >/dev/null 2>&1; then exec py; elif command -v pi >/dev/null 2>&1; then exec pi; else printf \"[pi-worktrees] Neither py nor pi found\\n\"; exec \"\${SHELL:-/bin/bash}\"; fi'" "$shell_path"
}

git_submodule_paths() {
  if [[ ! -f "$worktree_path/.gitmodules" ]]; then
    return 0
  fi

  git -C "$worktree_path" config --file .gitmodules --get-regexp '^submodule\..*\.path$' 2>/dev/null \
    | awk '{ $1=""; sub(/^[[:space:]]+/, ""); print }'
}

git_submodule_count() {
  git_submodule_paths \
    | wc -l \
    | tr -d '[:space:]'
}

is_git_checkout() {
  local path=${1:?missing path}

  # For submodule init, being inside the parent worktree is not enough. A real
  # initialized submodule has its own .git file or directory at the submodule
  # root. Env-file copying can create plain directories at gitlink paths; those
  # must be moved before `git submodule update --init` can clone into them.
  [[ -e "$path/.git" ]]
}

move_stale_submodule_dirs_aside() {
  local backup_root=""
  local moved=0
  local rel path backup_path

  while IFS= read -r rel; do
    [[ -n "$rel" ]] || continue
    path="$worktree_path/$rel"

    if [[ ! -e "$path" ]]; then
      continue
    fi

    if is_git_checkout "$path"; then
      continue
    fi

    if [[ -z "$backup_root" ]]; then
      backup_root="$(mktemp -d "${TMPDIR:-/tmp}/pi-worktree-stale-submodules.XXXXXXXXXX")"
    fi

    backup_path="$backup_root/$rel"
    mkdir -p "$(dirname "$backup_path")"
    mv -- "$path" "$backup_path"
    moved=$((moved + 1))
    log "git submodules: moved stale non-git path aside: $rel -> $backup_path"
  done < <(git_submodule_paths)

  if (( moved > 0 )); then
    log "git submodules: moved $moved stale path(s) aside before init"
  fi
}

maybe_sync_git_submodules() {
  if [[ ! -d "$worktree_path" ]]; then
    log "git submodules: worktree path does not exist; skipping: $worktree_path"
    return 0
  fi

  if ! command -v git >/dev/null 2>&1; then
    log "git submodules: git is not installed; skipping"
    return 0
  fi

  local submodule_count
  submodule_count="$(git_submodule_count)"
  if [[ -z "$submodule_count" || "$submodule_count" == "0" ]]; then
    return 0
  fi

  move_stale_submodule_dirs_aside

  log "git submodules: syncing and updating $submodule_count module(s)"
  (
    cd "$worktree_path"
    git submodule sync --recursive
    git submodule update --init --recursive
  )
}

find_existing_tmux_window_target() {
  local safe_name
  safe_name="$(worktree_safe_name)"
  tmux list-windows -a -F '#{session_name}\t#{window_name}' 2>/dev/null | awk -F '\t' -v n="$safe_name" '$2==n {print $1 ":" $2; exit}'
}

find_existing_tmux_session_for_window() {
  local safe_name
  safe_name="$(worktree_safe_name)"
  tmux list-windows -a -F '#{session_name}\t#{window_name}' 2>/dev/null | awk -F '\t' -v n="$safe_name" '$2==n {print $1; exit}'
}

launch_tmux_workspace() {
  if ! command -v tmux >/dev/null 2>&1; then
    log "tmux is not installed; skipping tmux workspace creation"
    return 0
  fi

  local safe_name session_name editor_cmd agent_cmd window_target
  safe_name="$(worktree_safe_name)"
  session_name="$(worktree_session_name)"
  editor_cmd="$(tmux_editor_command)"
  agent_cmd="$(tmux_agent_command)"

  if [[ -n "${TMUX:-}" ]]; then
    log "Starting tmux window '$safe_name'"
    window_target="$(tmux new-window -d -P -F '#{session_name}:#{window_index}' -n "$safe_name" -c "$worktree_path" "$editor_cmd")"
    tmux split-window -h -t "$window_target" -c "$worktree_path" "$agent_cmd"
    tmux select-layout -t "$window_target" even-horizontal
    tmux select-window -t "$window_target"
    log "tmux window ready: $safe_name"
    return 0
  fi

  if tmux has-session -t "$session_name" 2>/dev/null; then
    session_name="${session_name}-$(date +%H%M%S)"
  fi

  log "Starting tmux session '$session_name'"
  window_target="$(tmux new-session -d -P -F '#{session_name}:#{window_index}' -s "$session_name" -c "$worktree_path" "$editor_cmd")"
  tmux split-window -h -t "$window_target" -c "$worktree_path" "$agent_cmd"
  tmux select-layout -t "$window_target" even-horizontal
  log "Attach with: tmux attach -t $session_name"
}

switch_or_launch_tmux_workspace() {
  if [[ ! -d "$worktree_path" ]]; then
    log "Worktree path does not exist: $worktree_path"
    return 1
  fi

  local session_name target_window existing_session
  session_name="$(worktree_session_name)"

  if ! command -v tmux >/dev/null 2>&1; then
    log "tmux is not installed; worktree path: $worktree_path${branch_name:+ (branch: $branch_name)}"
    return 0
  fi

  if [[ -n "${TMUX:-}" ]]; then
    if tmux has-session -t "$session_name" 2>/dev/null; then
      log "Switching tmux client to session '$session_name'"
      tmux switch-client -t "$session_name"
      return 0
    fi

    target_window="$(find_existing_tmux_window_target)"
    if [[ -n "$target_window" ]]; then
      log "Switching tmux client to window '$target_window'"
      tmux switch-client -t "$target_window"
      return 0
    fi

    launch_tmux_workspace
    return 0
  fi

  if tmux has-session -t "$session_name" 2>/dev/null; then
    log "tmux session already exists: $session_name"
    log "Attach with: tmux attach -t $session_name"
    return 0
  fi

  existing_session="$(find_existing_tmux_session_for_window)"
  if [[ -n "$existing_session" ]]; then
    log "tmux workspace already exists in session '$existing_session'"
    log "Attach with: tmux attach -t $existing_session"
    return 0
  fi

  launch_tmux_workspace
}
