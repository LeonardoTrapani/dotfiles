---
name: ownership
description: Use only when the user says "own it", "have ownership", "take ownership" or types /ownership.
---

Own the change until its PR or MR is green and up to date with its target branch. You make every edit to the checkout; work too big for one thread splits into one thread per ticket, each in its own worktree.

1. **Draft.** An open, ready request on this branch goes back to draft before the first edit (`glab mr update <id> --draft`, `gh pr ready <id> --undo`). Only the user marks it ready.
2. **Implement**, then run the checks that cover the change and fix what it breaks.
3. **Review** the whole change with `review-loop` before the first push.
4. **Prove it end to end** on the reviewed code: run the real journey as its user or caller would (T3 browser, API, CLI or the app's own interface), the way the repository says, or with the `run` skill. Run the same journey on the target branch for the Before. Mocked tests are not proof. This request covers using the browser on your own work. A fix that changes behaviour goes back through `review-loop`. If no end-to-end run is possible, say why and what you proved instead.
5. **Publish** with the `pr` skill, the captures as Evidence, once there is no question waiting on the user.
6. **Babysit.** Handle the checks and comments already there, then `watch_pull_request` and end the turn; outside T3, follow the pipeline inside the turn. On each wake, act only on what is newer than the last push: verify each bot or reviewer finding against the source, fix the real ones and CI failures, prove each fix, and reply to the rest with a written reason. Keep the PR at the size its goal needs. A wake that needs nothing ends the turn silently. The watcher reports conflicts, not a branch that is behind: rebase yourself. Green and up to date: `unwatch_pull_request` and hand back; unwatch before asking a question too.
