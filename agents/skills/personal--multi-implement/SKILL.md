---
name: multi-implement
description: >-
  Launches one interactive Herdr worktree session per ticket through delegate,
  with every PR/MR targeting the branch from which the batch was invoked. Use
  for "multi-implement 183, 184, 186" or explicit requests to implement multiple
  tickets in separate Herdr worktrees. Do not use for implementation in the
  current checkout, worktree maintenance, or non-Herdr delegation.
---
# Multi-implement

A thin batch wrapper around delegate: one ticket, one worktree, one interactive agent.

## Flow

1. Parse comma- or whitespace-separated ticket identifiers, preserving their spelling
   and order; remove duplicates. Ask for ticket identifiers if none were supplied.
2. Require `HERDR_ENV=1`. Otherwise stop and ask to run from Herdr; this skill has
   no tmux or headless fallback.
3. Before launching anything, capture the calling checkout, its branch with
   `git symbolic-ref --quiet --short HEAD`, and its commit with `git rev-parse HEAD`.
   If HEAD is detached, ask for the target branch before proceeding. Freeze this
   branch as the PR/MR target and this commit as the base for every worktree in
   the batch. The target is not the repository's default branch or a child's branch.
4. Read and follow `delegate` for agent selection,
   dirty-checkout handling, Herdr prerequisites, worktree creation/reuse, interactive
   launch, readiness checks, and reporting. Resolve agent selection once for the
   batch. Treat every ticket as an explicit isolated Herdr worktree request, using
   the captured checkout and commit as the source and base. Keep the caller's focus.
5. For each ticket, launch the selected agent in that worktree's root pane through
   delegate, then submit this minimal prompt separately once the agent is ready.
   Substitute the actual ticket and captured target branch:

   ```text
   $implement <ticket>. Once finished, commit your work, push your implementation branch, and create a PR/MR targeting branch `<calling-branch>`. Do not merge it. Report the PR/MR URL, or any blocker preventing its creation.
   ```

   Preserve the literal `$implement` skill trigger when sending the prompt;
   quote it so the shell cannot expand `$implement` as an environment variable.
   Use this prompt instead of delegate's expanded context template. Launch all
   ticket sessions without waiting for their implementations to finish. Each
   worktree starts from the same captured commit, not another ticket's branch.
   On a launch failure, report the affected ticket and preserve successful sessions;
   inspect existing sessions before retrying to avoid duplicate delegates.
6. Finish when every ticket has either a running interactive session with its prompt
   submitted or a reported launch blocker. Report the shared target branch and,
   per ticket, the implementation branch, checkout path, workspace ID, and pane ID.
   Distinguish launched work from completed implementation or an already-created PR/MR.
