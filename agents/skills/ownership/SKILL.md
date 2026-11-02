---
name: ownership
description: Own a change from the first edit until its merge request is green.
disable-model-invocation: true
---

Own the change until its PR or MR is green and up to date with its target branch; a passing local run, a push or an open request is not done. You make every edit to the checkout. Work too big for one thread splits into one thread per ticket, each in its own worktree.

1. **Draft.** An open, ready request on this branch goes back to draft before the first edit (`glab mr update <id> --draft`, `gh pr ready <id> --undo`). Only the user marks it ready.
2. **Implement**, then run the checks that cover the change and fix what it breaks.
3. **Review** the whole change with the loop below before the first push.
4. **Publish** once verified, agreed in review and with no question waiting on the user: the `pr` skill, or the repository's instructions and template.
5. **Watch.** `watch_pull_request`, then end the turn; the host wakes you on checks, comments and conflicts. Each wake: fix, push, update the PR text if its claims changed, watch again. Green and up to date: `unwatch_pull_request`. Without the tool, follow the pipeline inside the turn.

## Review loop

One reviewer, the latest GPT Sol model, reviews the diff from the merge-base with the target branch to the working tree, untracked files included. In T3 pick it from `orchestrator_capabilities` and start each round with a new `delegate_task` (`role: "review"`, new `clientRequestId`); elsewhere a native subagent on Sol. No Sol: report the blocker, never switch model.

- **Budget.** 3 rounds; up to 5 only when the user asks, or for security, permissions, auth, data loss or concurrency with a blocker or should still open. Stop when a round returns only nits; declined nits and comment, doc or format fixes need no new round.
- **Ledger.** Each finding's id, severity and outcome, carried across rounds.
- **Hands off.** Leave the change untouched while a round runs. A timeout, error or empty reply is not approval: cancel and restart the round with the ledger.
- **Findings.** Judge each one and its severity yourself: another path, a rare case or a small cost is a nit. Agree with the smallest fix, deleting or narrowing before adding a lock, cache, helper or option, plus one test that fails without it when the intent needs it. Disagree with evidence: file and line, test, output. Decline nits and out-of-scope items in one line as follow-ups. Then re-run the checks and `git diff --shortstat <base>`, and cut back what the review grew. Never agree just to end the loop.
- **Later rounds** send the same brief, the ledger with each id `fixed`, `disagree` or `declined` plus evidence, and the code changed since; Sol marks each old id `resolved` or `still open: <reason>`. Another round only while the budget lasts and a blocker or should is open, or behaviour changed after Sol's last approval.
- **End.** Agreed: no blocker or should open, no behaviour change since Sol's last round, no concern of yours. Stuck: a finding disputed after two replies, or the budget spent without approval; show both sides in two or three lines each and let the user decide.

Report the rounds, the fixed and declined findings with reasons, and the change size before and after.

```text
Review only. Do not edit, commit, push, comment on PRs, or start subagents.
Repo: <absolute path>  Base: <sha>
Intent: <1-2 sentences>  Out of scope: <what this change leaves alone>
Checks: <results, including missing or already failing checks>
Standards: <CODING_STANDARDS.md, CONTRIBUTING.md, AGENTS.md...>
Diff: git diff <base>, plus the untracked files in git status --short.
Read the surrounding code. Find bugs, broken callers, mismatches with the intent
and breaches of the standards; flag code, tests or guards the intent does not
need. Skip style unless it hides a bug or breaks a documented rule.
blocker = the intended case is wrong.
should = a real bug callers hit within the intent, or a breach of a documented standard.
nit = everything else: other paths, rare cases, small costs, extra compatibility.
Reply:
VERDICT: APPROVE or CHANGES
F1 [blocker|should|nit] <file>:<line> <claim>. Fix: <suggestion>
Keep ids stable across rounds.
```
