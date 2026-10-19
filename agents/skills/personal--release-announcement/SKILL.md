---
name: release-announcement
description: >-
  Prepares Italian release announcements in Leonardo's style from a release MR,
  tag, or change range, with selected screenshots and a full changelog link. Use
  for "prepara il messaggio di release", "cosa è uscito?", or preparing a
  release draft in Discord. Does not merge, deploy, or publish unless requested.
---
# Release announcement

Turn release evidence into a message colleagues can use: lead with the major
capabilities, explain practical consequences, and attach useful product captures.

## Workflow

1. **Start from the latest release's changelog MR.** Use the supplied changelog
   MR; otherwise find the latest release/versioning MR and establish its release
   commit. Identify the preceding release's commit to bound the changes included
   in this release. A versioning MR may contain only package-version and changelog
   edits: its own diff is not the full feature inventory. Honor an explicit tag
   or range instead. Read the latest channel announcement when accessible to
   identify unannounced changes from earlier releases; label that wider scope as
   a cumulative update. Ask only when an unresolved boundary materially changes
   the message. Keep the user's priorities and exclusions for this announcement.
2. **Find everything else in the release interval.** Read the aggregate changelog
   and enumerate merged MRs/commits between the established release boundaries,
   following pagination. Read originating descriptions, relevant changes, and
   media; inspect source or docs where descriptions leave product behavior unclear.
   Account for every MR in the interval as a feature, fix, technical change,
   duplicate, or non-announcement item. Reconcile this inventory with the package
   notes so changes without changesets are discovered too. Deduplicate package
   notes that describe the same change. Record earlier-release items separately.
   For GitLab, prefer authenticated
   `glab api`; use project guidance for other hosts. Register the release MR with
   thread-linking tools when available. Supporting MRs read only as sources are
   background, not separate work items.
3. **Propose macroareas before writing the announcement.** Group the complete
   inventory by product capability or audience benefit, rather than package or
   MR. Present the candidate areas with their concrete changes, practical effect,
   originating MRs, and available screenshots/recordings. Recommend which areas
   lead the post, which fit under smaller improvements, and which belong only in
   the full changelog. Keep the user's stated main features first while surfacing
   other substantial capabilities. Let the user steer these priorities; continue
   evidence and media collection in the meantime. If the user already gave clear
   priorities or requested an end-to-end draft, proceed with the proposed grouping
   without requiring another approval. When asked "c'è altro?", compare the post
   against the complete inventory and report the remaining meaningful changes.
4. **Verify claims.** Read final merged behavior rather than an obsolete proposal
   or early MR description. Check unsupported operations, migration needs, and
   actual provider availability before claiming broad coverage. Explain speed
   claims at their supported boundary: fast code generation does not establish
   that authentication, triggers, and live validation are already configured.
   Merged, published, and deployed are distinct observed states; write the draft
   for the intended release without claiming an unverified rollout.
5. **Collect media and the changelog.** Download and inspect relevant screenshots
   or recordings from originating MRs. Prefer a working product state that
   illustrates the feature. Keep source URLs and any local/demo limitations with
   the artifacts. Caption demonstrations accurately; avoid implying that a
   stand-in provider was a live integration. Link the aggregate changelog for
   this exact release: official release notes if complete, otherwise the release
   MR's all-package notes. Keep earlier-release references distinguishable.
6. **Write the message.** Read `references/style.md`. Deliver a
   reviewable draft with inline screenshots or clearly associated attachments
   and the full changelog link. Incorporate user corrections into the current
   draft; preserve the established scope and destination.
7. **Prepare Discord when requested.** Read
   `references/discord-draft.md`. Default to an unsent draft when
   asked to "preparare" a message. Report the verified destination, attachments,
   and whether the message is drafted or sent.

Completion means the text, media, and changelog are reviewable in the requested
place. A Discord task finishes only after the UI visibly contains the intended
draft and attachments, or after reporting a concrete unresolved blocker.
