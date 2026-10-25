# dev-vps

Contabo VPS on Ubuntu 24.04, reachable only through the tailnet (ufw drops everything else; SSH is key-only). User `leo`, with passwordless sudo and lingering on, so user units keep running after logout. Do routine upkeep without asking, and report what failed.

## Toolchain

- **System:** git, `gh`, tmux, jq, Node, build tools from apt; Tailscale; unattended upgrades.
- **CLI tools** through mise (`~/.config/mise/config.toml`): neovim, ripgrep, fd, fzf, bat, eza, starship, zoxide, delta, git-lfs, herdr, uv, tmuxp.
- **GNU Stow** built into `~/.local`.
- **npm globals** in `~/.npm-global`: Claude Code, Codex, `hunkdiff` (the `hunk` Git pager).
- **Agents:** Codex, and Claude Code as two accounts through the `claude-a` and `claude-b` wrappers (`CLAUDE_CONFIG_DIR` is `~/.claude-a` or `~/.claude-b`).
- **PATH:** `~/.profile` puts `~/.local/bin`, `~/.npm-global/bin` and the mise shims on `PATH` before it sources `~/.bashrc`, so agent shells and the prompt both find the tools.

## Dotfiles

`~/dotfiles` stays on `main`; every installed config is a symlink into it, so a change reaches this machine as a merged PR followed by `git -C ~/dotfiles pull`. Never edit an installed path or switch `~/dotfiles` off `main`: both change every thread's configuration.

- **Stowed** with `stow --no-folding`: `bash`, `git`, `nvim`, `tmux`, `bin`, `mcp`, `herdr`, `starship-macos`, plus `~/.inputrc` from `bash-macos`.
- **Agents:** `agents/setup.sh` links `AGENTS.md`, `claude-settings.json` and the skills into `~/.claude`, `~/.claude-a`, `~/.claude-b` and `~/.codex`. Rerun it after adding a skill.
- **Check** for links a harness replaced with a file, and writes through a link: `find ~/.bashrc ~/.claude*/settings.json ~/.claude*/CLAUDE.md ~/.codex/AGENTS.md -maxdepth 0 ! -type l` and `git -C ~/dotfiles status --short`.

## T3

The T3 server is the `t3code.service` user unit on `100.98.212.117:3773`. The Mac and the phone pair with it by IP; there is no T3 Connect.

## Datapizza VPN

An OpenVPN split tunnel, the system unit `openvpn-client@datapizza`, routes only Datapizza services such as `git.datapizza.tech` through `tun0`. It signs in with the user's own Google SSO.

dev-vps shares the tunnel with the tailnet as a subnet router: it advertises every `/32` route the VPN pushes on `tun0`, with IPv4 forwarding on (`/etc/sysctl.d/99-tailscale-subnet-router.conf`), so the Mac and the phone reach Datapizza services through it without their own VPN. When the VPN pushes different routes, advertise them again and ask the user to approve the new ones at https://login.tailscale.com/admin/machines:

```bash
sudo tailscale set --advertise-routes="$(ip -4 route show dev tun0 | awk '$1 !~ /^172\.31\.80\./ {r=$1; if (r !~ /\//) r=r"/32"; print r}' | paste -sd,)"
```

When `git.datapizza.tech` stops answering, run `vpn-login-url` (`/usr/local/bin`; it re-runs itself under sudo). It prints the unit's state and any pending login link; give the user that link right away, because it expires after about 3 minutes. With no link pending and the tunnel down, ask the user before `sudo systemctl restart openvpn-client@datapizza`, because the profile allows one session and the restart disconnects the Mac. Then run `vpn-login-url` again for the new link.

## Update

`sudo apt-get update && sudo apt-get upgrade -y`, `mise up`, `npm update -g`, then `git -C ~/dotfiles pull`. Update T3 only with no run active.

## Set up again

On a fresh Ubuntu with Tailscale and the `leo` user:

1. As root: `echo 'leo ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/99-leo-nopasswd && chmod 0440 /etc/sudoers.d/99-leo-nopasswd && visudo -c`, then `tailscale set --operator=leo` so `preview` and Funnel run without sudo, and `loginctl enable-linger leo`.
2. `sudo apt-get install -y git gh tmux jq nodejs npm build-essential unzip stow`, then [glab](https://gitlab.com/gitlab-org/cli/-/releases) into `~/.local/bin`, `curl -fsSL https://mise.run | sh` and `mise use -g` with the tools above.
3. `npm config set prefix ~/.npm-global`, `npm install -g @anthropic-ai/claude-code @openai/codex hunkdiff`, and the `claude-a` and `claude-b` wrappers in `~/.local/bin`: each sets `CLAUDE_CONFIG_DIR` and execs `~/.npm-global/bin/claude`.
4. Clone `~/dotfiles`, back up the conflicting files, stow the packages above, run `agents/setup.sh`, and order `~/.profile` as in [Toolchain](#toolchain).
5. `nvim --headless "+Lazy! sync" +qa`, then `herdr plugin link ~/.local/share/nvim/lazy/vim-herdr-navigation` and `git lfs install --skip-repo`.
6. T3 as the `t3code.service` user unit, paired by IP. The VPN unit, its web-login hook and `vpn-login-url` live only on this machine, outside the dotfiles: copy them from a backup of `/etc/openvpn/client`, `/etc/systemd/system/openvpn-client@datapizza.service.d`, `/usr/local/sbin/openvpn-dpz-weblogin` and `/usr/local/bin/vpn-login-url`.
7. Sign-ins, each link shown to the user: `gh auth login`, `glab auth login --hostname git.datapizza.tech`, `codex login --device-auth`, `claude-a auth login`, `claude-b auth login`.
