---
name: orchestrator
description: Use when implementing a change, from the first edit until its merge request is green.
---

# Orchestrator

- **Delegate** lookups, research, reviews, screenshots and recordings: cheap models for lookups, Codex for anything in a browser. Keep every write to the checkout yourself. Work too big for one thread splits into one thread per ticket, each in its own worktree.
- **Review loop.** Before the first push, a subagent on another model reviews the whole diff with the review skill; fix every P1 and P2.
- **Done** means the merge request is green and current with its target branch.
- **Wait** for subagents, pipelines and long commands inside the turn, then send one final reply, with no progress updates before it.
