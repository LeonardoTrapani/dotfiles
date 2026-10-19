---
name: delegate
description: >-
  Delegates work to interactive coding-agent sessions (Codex, Claude Code,
  OpenCode, or another user-chosen CLI) as Herdr panes or tmux windows in the
  current workspace or an isolated worktree. Use when the user asks to delegate
  work, hand off tasks to a separate agent, choose a coding agent, spawn agent
  tabs/windows/panes, or includes the standalone terms "worktree" or "wt" in a
  delegation request. Do not use for listing, cleaning up, pruning, removing, or
  otherwise managing Git worktrees unless the user also asks to delegate work to
  an interactive coding agent. Do not use for ordinary subagent Task tool
  delegation, non-interactive run jobs, or file-based handoff documents unless
  explicitly requested.
---
# Delegate

Hand work to separate interactive coding-agent TUI sessions — one delegate unit (Herdr pane or tmux window) per thread, either in the current checkout or an isolated linked worktree.

## Detect

1. Multiplexer: `HERDR_ENV=1` → Herdr. Before any Herdr command, follow `herdr` for its environment guard, current CLI, pane IDs, layout, agent status, and waits. Else `TMUX` set → tmux. Else ask one short question: create a new tmux session, or use the normal subagent Task tool instead.
2. Agent: honor a user-named agent. Otherwise mirror the current session: `CODEX_THREAD_ID` or `CODEX_CI` → `codex`; `CLAUDECODE` or `CLAUDE_CODE*` → `claude`; `OPENCODE*` → `opencode`. Confirm the command exists with `command -v`.
3. Choice: when no installed mirror is clear, list the installed candidates from `codex`, `claude`, `pi`, `opencode`, and `gemini`, then ask the user to choose one or name another command. Present Codex as an option; never silently substitute a different agent.

Interactive mode is the invariant. Use non-interactive modes such as `codex exec`, `claude -p`, or `opencode run` only when the user explicitly requests them.

## Spawn

One delegate per thread, with a stable short name (`run-lifecycle`, `api-design`, `review-fix`).

### Choose topology

1. Treat standalone `worktree` or `wt` in the delegation request as an explicit request for an isolated linked worktree. Do not ask whether the user meant a normal pane.
2. Without either term, stay in the current checkout and use the default pane/window flow below.
3. Before creating a worktree, inspect the current Git status. If the task depends on uncommitted changes, ask whether to commit them, base from a commit, or proceed without them. Never imply that a new worktree includes uncommitted changes.

### Herdr worktree

When `worktree` or `wt` was requested:

1. Follow the Herdr skill and inspect the installed `herdr worktree` command group. List existing worktrees for the current checkout before mutating state.
2. Derive a short branch and workspace label from the task. Use the current checkout as the source, the current `HEAD` as the base, and `--no-focus` so the caller keeps focus.
3. Create the linked worktree with `herdr worktree create`. Read the workspace ID, root pane ID, and checkout path from its JSON result; never predict them.
4. If the branch or worktree already exists, do not force-create or delete it. Inspect it, then use `herdr worktree open` when it is safe and not already open. If its workspace is already open, reuse its root pane only when it is idle and clearly belongs to this task; otherwise ask.
5. Launch the agent in the returned root pane. Do not split the caller's pane.
6. Tell an implementation delegate to commit its finished work unless the user says not to. Include the branch, checkout path, workspace ID, and pane ID in the report.

The command shape is:

```bash
herdr worktree create --cwd '<current-checkout>' --branch '<short-name>' --base HEAD --label '<short-name>' --no-focus --json
```

Treat this as a shape, not fixed syntax: the installed Herdr CLI is authoritative.

### Herdr current workspace

Without a worktree request, default to a sibling pane in the current tab and workspace. Use the Herdr skill's layout rule to split right or down with `--current --no-focus`, then read the returned pane ID from JSON. Do not create a tab, workspace, or worktree unless the user asks for one.

Rename the pane and launch only the agent's normal executable:

```bash
herdr pane rename '<pane_id>' '<short-name>'
herdr pane run '<pane_id>' '<agent-executable>'
```

Follow `herdr` to inspect the pane and wait until the agent is idle. Then submit the self-contained prompt separately:

```bash
herdr pane run '<pane_id>' '<self-contained prompt>'
```

Do not pass the first task as an argv prompt in Herdr. The separate `pane run` call keeps the agent interactive and lets Herdr track its state.

### tmux

When `worktree` or `wt` was requested, create or open a linked Git worktree before launching the window. Inspect `git worktree list` and follow an existing checkout-path convention. If no convention is clear, ask one short question for the branch and path. Never force an existing branch or path. Set the new window's working directory to that worktree and report both its branch and path.

In either topology, launch a new window in the current session, with the prompt passed through the agent's interactive prompt argument:

- codex: `codex '<self-contained prompt>'`
- claude: `claude '<self-contained prompt>'`
- opencode: `opencode --prompt '<self-contained prompt>'`
- other: inspect local help. If the interactive form is unclear, ask for the exact launch command.

```bash
tmux new-window -t "$(tmux display-message -p '#S'):" -n '<short-name>' -c '<workspace>' "<agent launch command>"
```

Quote names, paths, and prompts. Stay in the current workspace/session; create a detached tmux session only when the user asks for one.

## Self-contained prompt

The delegate sees nothing of this conversation; the prompt must carry everything. Always state the mode — implement, research, discuss, or review — so the delegate knows whether to change code.

```text
<Implement|Research|Discuss|Review> <specific task> in <workspace>.

Context: <brief current state, relevant unstaged changes, or decisions>.

Read first: <important local files and reference repos>.

Constraints: <package manager, no code changes if discussion-only, style rules, safety constraints>.

Expected result: <what the delegate should produce or change>.

Verification: <commands to run, or say no verification if discussion-only>.
```

## Report

Done when every delegated thread has a running session and the user has, per delegate: its name and one sentence of its prompt. Delegation lives entirely in these sessions — write handoff files (the `handoff` skill) only on explicit request.
