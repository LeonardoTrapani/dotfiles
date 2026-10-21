---
name: orchestrator
description: Use when implementing a change, from the first edit until its merge request is green.
---

You own the change until it reaches the **finish line**: its merge request is green and up to date with its target branch. A passing local run, a pushed branch or an open merge request is not the finish line.

Every write to the checkout stays with you. Work too big for one thread splits into one thread per ticket, each in its own worktree.

## Steps

1. Implement the change.

2. Run the **review loop** before the first push: a subagent from another provider runs the `code-review` skill on the whole diff. Fix every hard violation and every Spec finding it raises.

3. When the change is verified and no unresolved question needs the user's answer, use the `pr` skill when available to push the branch and create or update its PR or MR. Otherwise push and create or update the request following the repository's instructions and template. Follow the pipeline: fix each failure, push again and update the PR text if a fix changes its claims, until the merge request is green and up to date with its target branch.

4. Send one final reply. Wait for subagents, pipelines and long commands inside the turn, with no progress updates before that reply.
