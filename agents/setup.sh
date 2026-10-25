#!/usr/bin/env bash
# Links this folder's agent instructions, settings and skills into Claude Code and Codex.
# Every Claude config dir is covered: ~/.claude plus any ~/.claude-*/ used through
# CLAUDE_CONFIG_DIR (e.g. one per account).
set -euo pipefail
shopt -s nullglob
here=$(cd "$(dirname "$0")" && pwd)

link() { mkdir -p "$(dirname "$2")"; ln -sfn "$1" "$2"; }

claude_dirs=(~/.claude)
for dir in ~/.claude-*/; do claude_dirs+=("${dir%/}"); done

for dir in "${claude_dirs[@]}"; do
  link "$here/AGENTS.md" "$dir/CLAUDE.md"
  link "$here/claude-settings.json" "$dir/settings.json"
done
link "$here/AGENTS.md" ~/.codex/AGENTS.md

for dir in "${claude_dirs[@]/%//skills}" ~/.codex/skills; do
  mkdir -p "$dir"
  find "$dir" -maxdepth 1 -type l -lname '*/.better-skills/*' -delete
  find "$dir" -maxdepth 1 -type l ! -exec test -e {} \; -delete
  for skill in "$here"/skills/*/; do
    link "${skill%/}" "$dir/$(basename "$skill")"
  done
done
