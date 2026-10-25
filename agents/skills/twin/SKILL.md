---
name: twin
description: Use when you need personal context about Leonardo (who he is, his preferences, accounts, people close to him, his work at Datapizza, clients, shared rules) that the repo and the conversation don't give you, and when he tells you something about himself worth keeping.
---

Leonardo's life context lives in the `twin` repo, cloned at `~/.twin`.

1. If `~/.twin` does not exist: `gh repo clone LeonardoTrapani/twin ~/.twin`. Otherwise: `git -C ~/.twin switch -q main && git -C ~/.twin pull -q --rebase`.
2. Read `~/.twin/AGENTS.md`, then `INDEX.md`, and follow links only to what the task needs.
3. To save a durable fact, open a pull request: Twin Maintainer reviews and merges it. In `~/.twin`, make the edit on a new `claude-code/<topic>` branch following the rules in `AGENTS.md`, commit it as `[claude-code] <what changed>`, push the branch and run `gh pr create` with what changed and why in the body. One topic per pull request; never push to `main`. Then `git switch main`.
4. Watch the pull request for a merge or a comment: call `link_pull_request` and `watch_pull_request`, then end your turn. On a comment, fix it on the same branch and push. On a merge, pull `main` and call `unwatch_pull_request`. Without those tools, give Leonardo the link.
