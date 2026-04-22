#!/usr/bin/env bash
set -euo pipefail

main_worktree=${1:?missing main worktree path}
worktree_path=${2:?missing worktree path}
worktree_name=${3:?missing worktree name}
branch_name=${4:-}

log() {
  printf '[pi-worktrees] %s\n' "$*"
}

sanitize_name() {
  printf '%s' "$1" | tr ' /:' '---' | tr -cd '[:alnum:]_.-'
}

copy_env_files() {
  local src="$main_worktree"
  local dst="$worktree_path"
  local copied=0
  local skipped=0

  while IFS= read -r -d '' file; do
    local rel="${file#"$src"/}"
    local dest="$dst/$rel"

    mkdir -p "$(dirname "$dest")"

    if [[ -e "$dest" ]]; then
      skipped=$((skipped + 1))
      continue
    fi

    cp -p -- "$file" "$dest"
    copied=$((copied + 1))
  done < <(
    find "$src" \
      \( -path "$src/.git" -o -path "$src/.git/worktrees" -o -path "$src/node_modules" -o -path "$src/.turbo" -o -path "$src/.worktrees" \) -prune -o \
      -type f \( -name '.env' -o -name '.env.*' -o -name '.envrc' \) -print0
  )

  if (( copied == 0 && skipped == 0 )); then
    log "env files: none found"
  else
    log "env files: copied $copied, skipped $skipped"
  fi
}

is_bun_project() {
  if [[ -f "$worktree_path/bun.lock" || -f "$worktree_path/bun.lockb" ]]; then
    return 0
  fi

  if [[ -f "$worktree_path/package.json" ]] && grep -Eq '"packageManager"[[:space:]]*:[[:space:]]*"bun@' "$worktree_path/package.json"; then
    return 0
  fi

  return 1
}

maybe_bun_install() {
  if ! is_bun_project; then
    log "No Bun project detected; skipping bun install"
    return 0
  fi

  if ! command -v bun >/dev/null 2>&1; then
    log "Bun project detected, but bun is not installed; skipping bun install"
    return 0
  fi

  log "Bun project detected; running bun install"
  (
    cd "$worktree_path"
    bun install
  )
}

launch_tmux_workspace() {
  if ! command -v tmux >/dev/null 2>&1; then
    log "tmux is not installed; skipping tmux workspace creation"
    return 0
  fi

  local shell_path="${SHELL:-/bin/bash}"
  local safe_name
  safe_name="$(sanitize_name "$worktree_name")"
  if [[ -z "$safe_name" ]]; then
    safe_name="worktree"
  fi

  if [[ -n "${TMUX:-}" ]]; then
    log "Starting tmux window '$safe_name'"
    tmux new-window -d -n "$safe_name" -c "$worktree_path" "$shell_path -lc 'nvim'"
    tmux split-window -h -t "$safe_name" -c "$worktree_path" "$shell_path -lc 'pi'"
    tmux select-layout -t "$safe_name" even-horizontal
    tmux select-window -t "$safe_name"
    log "tmux window ready: $safe_name"
    return 0
  fi

  local session_name="wt-$safe_name"
  if tmux has-session -t "$session_name" 2>/dev/null; then
    session_name="${session_name}-$(date +%H%M%S)"
  fi

  log "Starting tmux session '$session_name'"
  tmux new-session -d -s "$session_name" -c "$worktree_path" "$shell_path -lc 'nvim'"
  tmux split-window -h -t "$session_name" -c "$worktree_path" "$shell_path -lc 'pi'"
  tmux select-layout -t "$session_name" even-horizontal
  log "Attach with: tmux attach -t $session_name"
}

copy_env_files
maybe_bun_install
launch_tmux_workspace

log "Worktree ready: $worktree_path${branch_name:+ (branch: $branch_name)}"
