---
name: orchestrator
description: Use when implementing a change, from the first edit until its merge request is green.
---

You own the change until it reaches the **finish line**: its merge request is green and up to date with its target branch. A passing local run, a pushed branch or an open merge request is not the finish line.

Every write to the checkout stays with you. Work too big for one thread splits into one thread per ticket, each in its own worktree.

## Steps

1. Implement the change.

2. Run the **review loop** before the first push: a subagent from another provider runs the `code-review` skill on the whole diff. Fix every hard violation and every Spec finding it raises.

3. When the change is verified and no unresolved question needs the user's answer, use the `pr` skill when available to push the branch and create or update its PR or MR. Otherwise push and create or update the request following the repository's instructions and template.

4. Hand the pipeline to the host: call `watch_pull_request` on the request and end the turn with its URL. The host wakes the thread when checks finish, someone comments or the branch conflicts. On each wake, fix each failure, push again and update the PR text if a fix changes its claims, then watch again. When the request is green and up to date with its target branch, call `unwatch_pull_request` and report it. Without `watch_pull_request`, follow the pipeline inside the turn.

Reply once per turn, with no progress updates before that reply. Wait inside the turn for subagents and local commands that finish within about ten minutes; start a longer run in the background, end the turn with one line naming what is running, and let its notification wake you, so the user can steer in between.

**Checkpoint** with the user when a finding changes the plan they agreed to: a blocker the plan did not foresee, a policy the change would alter, a limit it has to respect. End the turn with the finding and your recommendation before building on it.
