---
name: dos-triage
description: >-
  Triage Dual's DOS delivery board and Discord feedback. First audits Jira tickets
  in Doing / PR Review / To deploy against GitLab MRs and the last release, asks
  for confirmation and moves them; then recaps open posts in the Discord bugs and
  questions-and-feature-requests forums, with drill-down by category or post.
  Use for "triage DOS", "sistema gli stati dei ticket", "recap Discord bugs/feature requests".
disable-model-invocation: true
---
# DOS triage

Two phases, in order. Phase 1 writes to Jira only after confirmation. Phase 2 is
read-only unless the user asks for a specific change. Talk to the user in Italian.

## Phase 1: Jira states vs MRs

Status meaning in project DOS:

- **PR Review**: an MR is open and ready (not draft).
- **To deploy**: merged into `master` but not yet in a completed release. The
  release boundary is the newest `dual-release-0.0.<pipeline>` tag. The open
  `changeset-release/master` MR (Version Packages) carries these changes.
- **Done**: every MR is contained in a completed release.
- **Doing**: work in progress, at most draft MRs.

1. From the Dual repo (`~/dev/dual`), run
   `python3 ~/.claude/skills/dos-triage/scripts/audit-jira.py > /tmp/dos-audit.json`.
   It fetches tags, reads tickets with `acli`, reads MRs with `glab`, and suggests a
   status from MRs that name the key in their title, branch or description.
2. Resolve the tickets where `suggested` is `null` (no MR names the key).
   Compare the ticket summary with `mrsWithoutKey` and with MR titles
   (`glab api "projects/dual%2Fdual/merge_requests?search=<words>&in=title&state=all"`).
   Mark these matches as "abbinata dal titolo". If nothing matches, propose
   moving the ticket back to Doing or To Do. Treat a ticket whose MRs are all
   released, but whose Discord post or comments still list open work, as "Done?"
   and say why.
3. Show the proposed moves in a table: ticket, current status, proposed status,
   evidence (MR numbers, merge date, release). Show only rows that change, plus
   the doubtful ones. Name the release tag and the open Version Packages MR.
4. Ask with `AskUserQuestion`: apply all the certain moves, choose which ones, or
   skip. Leave the "?" rows out of "apply all" unless the user includes them.
5. On confirmation, move each ticket with
   `acli jira workitem transition --key DOS-<n> --status "<status>" --yes --json`
   (status names: `Doing`, `PR Review`, `To deploy`, `Done`). Report each result;
   on failure, show the error and continue with the rest. Then run the script
   again and confirm that no unexpected difference remains.

## Phase 2: Discord bugs and feature requests

Read [references/discord.md](references/discord.md) for IDs, the fetch script
and tag updates.

1. Switch the Dual MCP context to team **Dual OS** and fetch the open posts.
   Restore the original context at the end of the phase, even after an error.
2. Read the Jira status of every DOS key the posts mention with a single
   `acli jira workitem search --jql "key in (...)" --fields key,status,summary --json`.
3. Group each open post into a category:
   - **A. Discord tag behind Jira**: the linked ticket is To deploy or Done, or the
     post is Open while its ticket is Done. Propose Done once released.
   - **B. Bugs without a ticket**: bugs forum, no DOS key or only keys of other work.
   - **C. Questions / feature requests without a ticket**: sort by weight (urgency
     or blocker stated in the post, customer, number of messages).
   - **D. Tracked**: Noted or In progress with a live ticket. List them briefly.
   Also flag posts that are In progress with no ticket, and old archived posts
   that are still open.
4. Show an overview: counts per forum and tag, then the four categories with
   post title, author, date, customer/priority, and linked tickets. Link each post.
5. Offer a drill-down with `AskUserQuestion`: one category at a time, or a single
   post. For a post, read the full thread and summarize the request, the
   discussion, decisions, open questions and linked tickets; then suggest an
   action (create a ticket, link an existing one, change the tag, close as
   duplicate, ask for information). Run each write (Jira ticket, Discord tag,
   Discord reply) only after explicit confirmation of the exact change. New Jira
   tickets follow the Dual repo's `docs/agents/issue-tracker.md`.

Show tables and overviews as an `html_render` page in Italian, using the theme
variables. Keep the chat reply to what the page does not show.
