---
name: environment
description: Use before the first command of a session, and before a step that needs an account, a secret, a dashboard or an external service.
---

# Environment

One Mac running Claude Code and Codex.

| Need | Use |
| --- | --- |
| GitLab (`git.datapizza.tech`) | `glab`, signed in |
| GitHub | `gh`, signed in |
| Jira | `acli`, signed in |
| AWS | `aws`; on an expired token run `aws sso login` and give me the printed URL |
| Secrets in 1Password | `op`; each new shell waits for my approval in the app, so read and use a secret in one command |
| Product analytics | `posthog-cli` |
| Dual itself | the `dual` MCP server |
| A dashboard behind my login | a Codex subagent with computer use on my Chrome, read-only unless I asked |
| A secret I must type | `request_secret` |
| Anything else: a service, an account, an integration | search the Executor MCP first, then `invoke` |

`git.datapizza.tech` is reachable only through my VPN. When it does not answer and you need to push or fetch, stop and ask me to reconnect it; everything else can continue meanwhile.
