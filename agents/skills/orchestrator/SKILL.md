---
name: orchestrator
description: Use when implementing a change, from the first edit until its merge request is green.
---

You own the change until it reaches the **finish line**: its merge request is green and up to date with its target branch. A passing local run, a pushed branch or an open merge request is not the finish line.

Delegate to **subagents** anything that would fill your context: lookups, research, reviews, screenshots and recordings. Use cheap models for lookups and Codex for anything that happens in a browser. Every write to the checkout stays with you. Work too big for one thread splits into one thread per ticket, each in its own worktree.

## Steps

1. Implement the change.

2. Run the **review loop** before the first push: a subagent on a different model reviews the whole diff and calls the Skill tool with `review`. Fix every P1 and P2 it raises.

3. Push, then follow the pipeline. Fix each failure and push again until the merge request is green and up to date with its target branch.

4. Send one final reply. Wait for subagents, pipelines and long commands inside the turn, with no progress updates before that reply.
