---
name: orchestrator
description: Use when implementing a change, from the first edit until its merge request is green.
---

You own the change until it reaches the **finish line**: its merge request is green and up to date with its target branch. A passing local run, a pushed branch or an open merge request is not the finish line.

Every write to the checkout stays with you. Work too big for one thread splits into one thread per ticket, each in its own worktree.

## Steps

1. Implement the change.

2. Before the first push, run the **review loop** below on the whole change.

3. When the change is verified, the review loop has ended in agreement and no unresolved question needs the user's answer, use the `pr` skill when available to push the branch and create or update its PR or MR. Otherwise push and create or update the request following the repository's instructions and template.

4. Hand the pipeline to the host: call `watch_pull_request` on the request and end the turn with its URL. The host wakes the thread when checks finish, someone comments or the branch conflicts. On each wake, fix each failure, push again and update the PR text if a fix changes its claims, then watch again. When the request is green and up to date with its target branch, call `unwatch_pull_request` and report it. Without `watch_pull_request`, follow the pipeline inside the turn.

Wait for subagents and long local commands inside the turn, and reply once per turn, with no progress updates before that reply.

## Review loop

One reviewer, the latest GPT Sol model, reviews the **change**: the diff from its merge-base with the target branch to the working tree, untracked files included. Keep the change as small as its intent allows: answer each finding with the smallest fix, and push back when a finding is wrong or out of scope.

### Budget

- Run at most 3 rounds. Go up to 5 only when the user asks, or for security, permissions, auth, data loss or concurrency while a blocker or should stays open with evidence.
- Stop early when a round returns only nits. Declined nits and fixes to comments, docs or formatting need no new round.
- Keep a **ledger** of each finding's id, severity and outcome.

### Rounds

Before round 1, run the checks that cover the change and fix what the change breaks. In T3, pick the latest Sol model from `orchestrator_capabilities` and start every round with a new `delegate_task` (`role: "review"`, a new `clientRequestId`); elsewhere use a native subagent running Sol. When nothing can run Sol, report the blocker instead of switching to another model.

Leave the change untouched while a round runs. A timeout, an error or an empty reply is not approval: cancel the task and restart the round with the ledger.

Round 1 brief:

```text
Review only. Do not edit, commit, push, comment on PRs, or start subagents.
Repo: <absolute path>  Base: <sha>
Intent: <1-2 sentences>  Out of scope: <what this change leaves alone>
Checks: <results, including missing or already failing checks>
Standards: <files documenting the repo's coding standards: CODING_STANDARDS.md, CONTRIBUTING.md, AGENTS.md...>
Diff: git diff <base>; read the untracked files listed by git status --short.
Read the surrounding code. Find bugs, broken callers, mismatches with the intent
and breaches of the standards. Skip style unless it hides a bug or breaks a
documented rule. Flag code, tests or guards the intent does not need.
blocker = the intended case is wrong.
should = a real bug callers will hit within the intent, or a breach of a documented standard.
nit = everything else: other paths, rare cases, small performance costs, extra compatibility.
Reply:
VERDICT: APPROVE or CHANGES
F1 [blocker|should|nit] <file>:<line> <claim>. Fix: <suggestion>
Keep ids stable across rounds.
```

Later rounds send the same brief and diff command, the ledger with each id marked `fixed`, `disagree` or `declined` plus its evidence, and the code changed since the last round. Sol reviews only that code and the open ids, marking each old id `resolved` or `still open: <reason>`. Start another round only while the budget lasts and a blocker or should is still open, or behaviour changed after Sol's last approval.

### Findings

Check each finding and its severity yourself: another path, a rare case or a small cost is a nit, whatever its label.

- **Agree**: make the smallest fix, deleting or narrowing code before adding a lock, cache, helper or option. Add one focused test that fails without the fix when the intent needs it.
- **Disagree**: say why, with evidence: a file and line, a test, command output.
- **Nit or out of scope**: decline in one line and list it as a follow-up.

Then re-run the checks and `git diff --shortstat <base>`; if the review grew the change, cut it back first. Never agree just to end the loop.

### End

- **Agreed**: no blocker or should is open, behaviour has not changed since Sol's last round, and you have no concern of your own. A round with only nits counts as approval.
- **Stuck**: a finding is still disputed after two replies, or the budget ran out without approval. Show both sides in two or three lines each and let the user decide.

Report the rounds, the model, the fixed and declined findings with their reasons, and the size of the change before and after the review.
