---
name: environment
description: Use before the first command of a session, a preview link, a video, a voice-over, a resource-heavy run, a step on another machine, machine maintenance, and before a step that needs an account, a secret, a dashboard or an external service.
---

Two machines run Claude Code and Codex with this same configuration, linked from `~/dotfiles`. Run `hostname` first: what you can reach depends on which one you are on. Both are in one tailnet; from the Mac use full names (`<name>.tail5a2724.ts.net`) or IPs, because the home router resolves short names to `127.0.0.1`.

| Machine | Tailnet | Role |
| --- | --- | --- |
| `dev-vps` | `100.98.212.117` | Always-on Ubuntu VPS where most agent work runs, driven through T3 from the Mac and the phone. Setup, upkeep and the VPN: [references/dev-vps.md](references/dev-vps.md) |
| Mac | `macbook-pro-di-leonardo` | The user's laptop, with 1Password, Chrome and the GPU |
| `iphone192` | | T3 client only |
| `jarvis-box` | | Grok bot's machine, not for agent work |

T3 tools reach only the threads of the machine you are on, and agents do not SSH between the Mac and `dev-vps`. For a step only the other machine can do, give the user the command or the message to run there.

## Access

Before asking the user for access, check whether you already have it.

- **GitHub**: `gh`, signed in.
- **GitLab** (`git.datapizza.tech`): `glab`, signed in. It answers only through the Datapizza VPN, which runs on `dev-vps` and reaches the Mac through the tailnet; the Mac never connects its own VPN, because one session is allowed and it would drop `dev-vps`'s. When GitLab stops answering, follow [Datapizza VPN](references/dev-vps.md#datapizza-vpn) on `dev-vps`, or from the Mac ask the user to run `vpn-login-url` there. Carry on with everything else meanwhile.
- **Jira** (`datapizza.atlassian.net`): `acli`, signed in.
- **AWS**: `aws`, with the profiles `dualos-dev`, `dualos-prod` and `datapizza-prod` on the `datapizza` SSO session. When the token has expired, run `aws sso login --sso-session datapizza --use-device-code --no-browser` and give the user the printed link.
- **1Password**: `op`. On the Mac each new shell waits for the user's approval in the app, so read a secret and use it in the same command. On `dev-vps`, `op` runs as a service account that reads the shared vaults, such as "Shared with Agents", but never Personal: ask the user to copy a Personal item there.
- **Voice**: generate speech with ElevenLabs. Find its API key in 1Password with `op item list --categories "API Credential"`, and read it in the command that calls ElevenLabs.
- **Product analytics**: `posthog-cli`, signed in to the Dual OS project.
- **Dual**: the `dual` MCP server.
- **Any other service, account or integration**: search the **Executor** MCP first, then call `invoke` with the tool it returns.
- **A secret the user must type**: `request_secret`.

Only on the Mac; from `dev-vps`, ask the user to run the step there:

- **A dashboard behind the user's login**: a Codex subagent with computer use on the user's Chrome, read-only unless the user asked for a change.
- **Video**: see [Video](#video).

## Previews

On `dev-vps`, share a running app as a tailnet HTTPS link with `preview`, run from the worktree root. It runs the command as a systemd user unit named after the worktree, with `HOST=127.0.0.1` and a `PORT` fixed by the worktree path, and prints `https://dev-vps.tail5a2724.ts.net:<port>`, which the user opens from the Mac or the phone.

```bash
preview 'bun run dev --host $HOST --port $PORT'   # start, or restart on the latest code
preview log                                       # its output
preview stop                                      # when the user is done with it
```

- **One per worktree.** Never start a dev server as a background task: it dies with the turn and a second copy doubles its memory.
- **Share** the link only after it loads its pages, assets and API calls.
- **Webhooks** need a public URL: Funnel publishes one port of 443, 8443 or 10000 on the internet, so expose only the webhook path, `tailscale funnel --bg --https=<port> --set-path <path> http://127.0.0.1:<app port><path>`, and remove it with `... --set-path <path> off` when done.

## Resource budget

`dev-vps` (12 cores, 47 GB, no swap) is shared with the user's other threads. Before a heavy build, install or test run, check `free -h` and the heaviest processes (`ps -eo pid,comm,rss,pcpu --sort=-rss | head`). Run this thread's heavy commands one at a time, and stop only processes this thread started.

## Video

Videos are made on the Mac (they need its GPU and 1Password). Before making any
video, read [references/video.md](references/video.md): videos are made with
Psychopomp, narrated with ElevenLabs, and real captures are delegated to Codex.
