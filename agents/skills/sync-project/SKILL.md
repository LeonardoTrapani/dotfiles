---
name: sync-project
description: >-
  Syncs a project after a release: prepares the Italian release announcement in
  Leonardo's style starting from the last Discord announcement, and brings Jira
  in line with the MRs (open and ready → To Review, merged but not deployed →
  To Deploy, deployed → Done). Use for "sync project", "prepara il messaggio di
  release", "cosa è uscito?" or "sistema Jira". Does not merge, deploy, or send
  the Discord message unless requested.
disable-model-invocation: true
---
# Sync project

Two outputs: a release message colleagues can use, and a Jira board that matches
what is actually in review, merged and deployed. Load the `environment` skill
first: GitLab and Jira (`acli`) have their own access rules.

## Codex subagent

Discord is computer use, so it goes to a Codex subagent (`delegate_task` to
Codex with computer use). Start it at the beginning to read the latest message in
the release channel (default **Datapizza Space → 📢┊releases**): its text, date,
release/version it covers, and links. At the end, send it the final text, the
attachment folder and `references/discord-draft.md` to prepare the draft. It
reads and drafts; it never sends unless the user asked to send. Jira transitions
and every file edit stay with you.

## Release announcement

1. **Establish the boundaries.** The previous boundary is the release covered by
   the last Discord announcement; the new one is the latest release's changelog
   MR (or the tag or range the user gave). A versioning MR may contain only
   package-version and changelog edits: its own diff is not the feature
   inventory. When releases since the last announcement were never announced,
   label the message a cumulative update. Ask only when an unresolved boundary
   materially changes the message. Keep the user's priorities and exclusions.
2. **Inventory everything in the interval.** Read the aggregate changelog and
   enumerate merged MRs/commits between the boundaries, following pagination.
   Read descriptions, relevant changes and media; inspect source or docs where
   descriptions leave product behavior unclear. Account for every MR as a
   feature, fix, technical change, duplicate, or non-announcement item, and
   reconcile with the package notes so changes without changesets surface too.
   For GitLab, prefer authenticated `glab api`. Register the release MR with
   thread-linking tools when available; MRs read only as sources are background.
3. **Propose macroareas before writing.** Group the inventory by product
   capability or audience benefit, not package or MR. Present each area with its
   concrete changes, practical effect, MRs and available media. Recommend which
   areas lead, which go under smaller improvements, and which stay only in the
   changelog. If the user already gave priorities or asked for an end-to-end
   draft, proceed without another approval. On "c'è altro?", compare the post
   against the inventory and report what remains.
4. **Verify claims.** Read final merged behavior, not an early MR description.
   Check unsupported operations, migrations and real provider availability
   before claiming broad coverage. Keep speed claims at their supported
   boundary. Merged, published and deployed are distinct observed states; do not
   claim an unverified rollout.
5. **Collect media and the changelog.** Download and inspect screenshots or
   recordings from the MRs; prefer a working product state. Caption accurately,
   without implying a stand-in provider was a live integration. Put the chosen
   files in a dedicated folder. Link the aggregate changelog for this exact
   release: official release notes if complete, otherwise the release MR's
   all-package notes.
6. **Write the message.** Read `references/style.md`. Deliver a reviewable draft
   with its attachments and the changelog link. Apply user corrections to the
   current draft, keeping scope and destination.
7. **Prepare Discord** through the Codex subagent. Default to an unsent draft.

## Jira sync

1. **Collect the MRs.** Open MRs, MRs merged since the oldest non-Done issue
   they reference, and the deployed state: the commit running in production
   from the deployment evidence (GitLab environments/deployments, the deploy
   pipeline, or project guidance). An MR is deployed only when its merge commit
   is an ancestor of that commit; merged is not deployed.
2. **Map MRs to issues** through the issue key in branch, title, description or
   commits. Also search the board's non-Done issues with `acli jira workitem
   search --jql` to catch issues whose MR moved on.
3. **Compute the expected status** of each issue from its least advanced MR:
   - open and not draft → **To Review**
   - merged, not deployed → **To Deploy**
   - deployed → **Done**
   Draft MRs and issues without MRs keep their status.
4. **Apply forward moves** with `acli jira workitem transition --key ... --status
   ...`. Report, without applying, moves backward (e.g. Done with an open MR),
   MRs without an issue key, and statuses the workflow rejects.
5. **Report** a table: issue, MR(s), previous status, new status, evidence.

Completion: the draft (text, media, changelog link) is reviewable in the
requested place, the Discord composer visibly holds it unsent or a concrete
blocker is reported, and every Jira issue in scope is synced or listed with why
it was not.
