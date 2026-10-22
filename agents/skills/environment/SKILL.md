---
name: environment
description: Use before the first command of a session, a video, a voice-over, and before a step that needs an account, a secret, a dashboard or an external service.
---

This machine is one Mac running Claude Code and Codex. Before asking the user for access, check whether you already have it:

- **GitLab** (`git.datapizza.tech`): `glab`, signed in. It answers only through the user's VPN: when it does not and you need to push or fetch, ask the user to reconnect and carry on with everything else.
- **GitHub**: `gh`, signed in.
- **Jira**: `acli`, signed in.
- **AWS**: `aws`. When the token has expired, run `aws sso login` and give the user the printed URL.
- **1Password**: `op`. Each new shell waits for the user's approval in the app, so read a secret and use it in the same command.
- **Voice**: generate speech with ElevenLabs. Find its API key in 1Password with `op item list --categories "API Credential" --vault Personal`, and read it in the command that calls ElevenLabs.
- **Product analytics**: `posthog-cli`.
- **Dual**: the `dual` MCP server.
- **A dashboard behind the user's login**: a Codex subagent with computer use on the user's Chrome, read-only unless the user asked for a change.
- **A secret the user must type**: `request_secret`.

For any other service, account or integration, search the **Executor** MCP first, then call `invoke` with the tool it returns.

## Video

Before making any video, read [references/video.md](references/video.md): videos
are made with Psychopomp, narrated with ElevenLabs, and real captures are delegated
to Codex.
