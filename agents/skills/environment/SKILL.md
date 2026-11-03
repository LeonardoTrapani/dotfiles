---
name: environment
description: Use before the first command of a session, a preview link, a video, a voice-over, a resource-heavy run, a step on another machine, machine maintenance, and before a step that needs an account, a secret, a dashboard or an external service.
---

Run `hostname` first. Two machines share this configuration from `~/dotfiles`, both in one tailnet; from the Mac use full names (`<name>.tail5a2724.ts.net`) or IPs.

- **`dev-vps`** (`100.98.212.117`): always-on Ubuntu VPS where most agent work runs. Setup and upkeep: [references/dev-vps.md](references/dev-vps.md).
- **Mac** (`macbook-pro-di-leonardo`): the user's laptop, with 1Password, Chrome and the GPU.

Agents do not SSH between them: for a step only the other machine can do, give the user the command to run there.

## Access

Check what you already have before asking.

- **GitHub** `gh`, **Jira** `acli`, **PostHog** `posthog-cli`: signed in.
- **GitLab** (`git.datapizza.tech`) `glab`: answers only through the Datapizza VPN on `dev-vps`. When it stops answering, follow [Datapizza VPN](references/dev-vps.md#datapizza-vpn), or from the Mac ask the user to run `vpn-login-url` on `dev-vps`. Never connect the VPN from the Mac.
- **AWS** `aws`: profiles `dualos-dev`, `dualos-prod`, `datapizza-prod`. Expired token: `aws sso login --sso-session datapizza --use-device-code --no-browser`, then give the user the link.
- **1Password** `op`: read a secret in the same command that uses it. On `dev-vps` it sees only shared vaults, never Personal.
- **Anything else**: search the **Executor** MCP. A secret the user must type: `request_secret`.
- **Mac only**: a dashboard behind the user's login goes to a Codex subagent with computer use on Chrome, read-only unless asked. Videos and voice-overs: read [references/video.md](references/video.md) first.

## Previews

- **Mac**: links are `http://localhost:<port>`, never `127.0.0.1`.
- **`dev-vps`**: from the worktree root, `preview '<dev command> --host $HOST --port $PORT'` prints the tailnet link; `preview log`, `preview stop`. One per worktree, never as a background task. Webhooks: [references/dev-vps.md](references/dev-vps.md#webhooks).

Share a link only after its pages, assets and API calls load.

## Resources

`dev-vps` is shared with other threads: before a heavy build or test run check `free -h`, run heavy commands one at a time, and stop only processes this thread started.
