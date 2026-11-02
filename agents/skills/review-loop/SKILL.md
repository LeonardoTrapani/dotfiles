---
name: review-loop
description: Use when the user says "review loop" or "sol loop", and from ownership before the first push.
---

One reviewer, the latest GPT Sol model, reviews the diff from the merge-base with the target branch to the working tree, untracked files included. Run the checks that cover the change first and send no code they break.

- **Reviewer.** In T3 pick Sol from `orchestrator_capabilities` and start each round with a new `delegate_task` (`role: "review"`, new `clientRequestId`); elsewhere a native subagent on Sol. No Sol: report the blocker, never switch model.
- **Budget.** 3 rounds; up to 5 only when the user asks, or for security, permissions, auth, data loss or concurrency with a blocker or should still open. Stop when a round returns only nits; declined nits and comment, doc or format fixes need no new round.
- **Ledger.** Each finding's id, severity and outcome, carried across rounds.
- **Hands off.** Leave the change untouched while a round runs. A timeout, error or empty reply is not approval: cancel and restart the round with the ledger.
- **Findings.** Judge each one and its severity yourself: another path, a rare case or a small cost is a nit. Agree with the smallest fix, deleting or narrowing before adding a lock, cache, helper or option, plus one test that fails without it when the intent needs it. Disagree with evidence: file and line, test, output. Decline nits and out-of-scope items in one line as follow-ups. Then re-run the checks and `git diff --shortstat <base>`, and cut back what the review grew. Never agree just to end the loop.
- **Later rounds** send the same brief, the ledger with each id `fixed`, `disagree` or `declined` plus evidence, and the code changed since; Sol marks each old id `resolved` or `still open: <reason>`. Another round only while the budget lasts and a blocker or should is open, or behaviour changed after Sol's last approval.
- **End.** Agreed: no blocker or should open, no behaviour change since Sol's last round, no concern of yours. Stuck: a finding disputed after two replies, or the budget spent without approval; show both sides in two or three lines each and let the user decide.

Report the rounds, the fixed and declined findings with reasons, and the change size before and after.

Round 1 brief:

```text
Review only. Do not edit, commit, push, comment on PRs, or start subagents.
Repo: <abs path>  Base: <sha>  Intent: <1-2 sentences>  Out of scope: <scope>
Checks: <results, missing or already failing>  Standards: <CODING_STANDARDS.md, AGENTS.md...>
See: git diff <base>; git status --short (read untracked files).
Read surrounding code. Find bugs, broken callers, mismatches with the intent and
breaches of the standards. Skip style unless it hides a bug or breaks a documented
rule. Flag code, tests or guards the intent does not need.
blocker = intended case wrong. should = real bug callers hit within the intent, or a
standards breach. nit = the rest: other paths, rare cases, small costs, extra compat.
Reply:
VERDICT: APPROVE or CHANGES
F1 [blocker|should|nit] <file>:<line> <claim>. Fix: <suggestion> (stable ids)
```
