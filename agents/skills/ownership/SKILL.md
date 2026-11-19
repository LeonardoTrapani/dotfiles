---
name: ownership
description: Use when the user says "own it", "have ownership", "take ownership", "parti", "vai" or types /ownership, and for a code change with nothing left for the user to decide.
---

Own the change until its PR or MR is green and up to date with its target branch. You make every edit to the checkout; work too big for one thread splits into one thread per ticket, each in its own worktree.

1. **Draft.** An open, ready request on this branch goes back to draft before the first edit (`glab mr update <id> --draft`, `gh pr ready <id> --undo`). Only the user marks it ready.
2. **Before.** When the change is visible, capture the Before on the target branch before the first edit, by the `pr` skill's Evidence.
3. **Implement** the approved plan and prototype, then run the checks that cover the change and fix what it breaks.
4. **Review** the whole change with `review-loop` before the first push, or with `council` when the user asks for it.
5. **Prove it end to end** on the reviewed code yourself, as its user or caller would: web in T3's browser, native in the Device panel, a CLI or API by running it, the way the repository says or the `run` skill finds. This request covers the preview and device tools on your own work. A desktop app or a dashboard behind the user's login goes to a Codex subagent with computer use. Mocked tests are not proof. A fix that changes behaviour goes back through the review. If no end-to-end run is possible, say why and what you proved instead.
6. **Publish** with the `pr` skill, the captures as Evidence, once there is no question waiting on the user.
7. **Babysit.** Handle the checks and comments already there, then `watch_pull_request` and end the turn; outside T3, follow the pipeline inside the turn. On each wake, act only on what is newer than the last push: verify each bot or reviewer finding against the source, fix the real ones and CI failures, prove each fix, and reply to the rest with a written reason. Keep the PR at the size its goal needs. A wake that needs nothing ends the turn silently. The watcher reports conflicts, not a branch that is behind: rebase yourself. Green and up to date: `unwatch_pull_request` and hand back; unwatch before asking a question too.
