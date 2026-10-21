---
name: pr
description: Use when creating or updating a pull request or merge request, or writing its title or description.
---

## Repository conventions

Read the repository's instructions and applicable PR or MR template before writing.
On GitLab, look in `.gitlab/merge_request_templates/`, using `Default.md` unless
the repository or user selects another template. On GitHub, look for the repository's
pull request template. Preserve required sections and checklists; mark an item
complete only when its requirement has been met. Without a template, choose headings
that fit the change.

## Title and body

Describe this PR's complete change at behavior, architecture and contract level.
Write for a reviewer who has not read the conversation. Lead with the problem and
resulting behavior; use a concrete trigger and before/after example when helpful.

Use Markdown lists for distinct changes, tables for comparisons and headings for
separate concerns. Concision does not mean flattening structure into prose. Include
material risks, migrations and deciding evidence; link supporting detail. Keep
verified behavior distinct from expectations. Leave implementation walkthroughs to
the diff; omit process, test counts, inventories, generic caveats and repeated
summaries. Describe the current head, not how the PR got there: no "now also",
"updated" or "fixed review" narration.

## Evidence

A behavior change gets a visible demonstration from its real input through its
observable result. This applies to backend, API, CLI and infrastructure changes too:
show the consuming interface, terminal, requests and results, or traces as appropriate.
A video proves a sequence; screenshots prove states and outcomes. Include changed
failure paths when they matter. An HTML mock or animation of intended behavior does
not prove the implementation works.

Compare before and after on the same data when needed. For a recording or proof
video, read the [video reference](../environment/references/video.md) for capture,
composition and verification.

Inspect each capture and embed it under its claim. On GitHub, keep an uploaded video
URL alone in its paragraph so it renders as a player. Command output supports,
rather than replaces, feasible captures. For text-only changes, show the relevant
document or checked example. If capture is unavailable or nothing runs, state the
limitation and show the strongest real evidence without claiming end-to-end verification.

## Publish

Use the current branch's reviewed, verified commits and the intended target branch.
Read the branch's push remote to select the host and repository; use `environment`
for access. For self-hosted GitLab, explicitly target that host and repository.
Push the branch and create the PR with `gh` on GitHub or the MR with `glab` on GitLab;
update an existing request for this branch instead of opening a duplicate. Pass the
description through a body file or the host's equivalent so Markdown stays literal.
Keep the title and body accurate after pushes that change their claims.

Register the request with the thread's PR-linking tool when available. Read back
text-only titles and descriptions through the host CLI/API; inspect the published
page when embeds or layout need verification, including image and video rendering.
Return the request URL.
