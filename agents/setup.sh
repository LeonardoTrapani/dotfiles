#!/usr/bin/env bash
# Links this folder's agent instructions, settings and skills into Claude Code and Codex.
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)

link() { mkdir -p "$(dirname "$2")"; ln -sfn "$1" "$2"; }

link "$here/AGENTS.md" ~/.claude/CLAUDE.md
link "$here/AGENTS.md" ~/.codex/AGENTS.md
link "$here/claude-settings.json" ~/.claude/settings.json

for dir in ~/.claude/skills ~/.codex/skills; do
  mkdir -p "$dir"
  find "$dir" -maxdepth 1 -type l -lname '*/.better-skills/*' -delete
  find "$dir" -maxdepth 1 -type l ! -exec test -e {} \; -delete
  for skill in "$here"/skills/*/; do
    link "${skill%/}" "$dir/$(basename "$skill")"
  done
done
