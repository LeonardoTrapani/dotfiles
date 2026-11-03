---
name: pr
description: Use when creating or updating a pull request or merge request, or writing its title or description.
---

Use this body. If the repository has its own PR or MR template, fill that one instead, keep its required sections, and tick an item only when it is met.

```markdown
## Summary

<one or two sentences: what changes for whom>

<diagram, diff-sketch, tree or table>

- <distinct change>

## Evidence

- **Before:** <screenshot / recording / output / failing test>
  **After:** <screenshot / recording / output / passing test>

## Merge Danger

**Door:** <one-way or two-way>

**Blast Radius:** <one word>
```

Write for a reviewer who has not read the conversation, in the repository's domain language, about the current head: no "now also", "updated" or "fixed review". No preambles, implementation walkthroughs, test-command lists, file inventories or generic caveats. Required migrations or cutover steps get their own section before Merge Danger.

**Summary.** One view, rarely two, holding only what makes the point: pseudocode, a call tree, a component tree, a shallow file tree, a Mermaid diagram, a before/after table, or a `diff` of one of these.

**Evidence.** The change working on its real input, before and after on the same data, backend and CLI too. Screenshots for any visible change; a recording for interactions, flows, streaming or timing ([video reference](../environment/references/video.md)); output, requests or traces when nothing is visible. A mock is not evidence; if a capture is impossible, say so in one line. Upload captures through the host's attachment flow, under their Before/After line; on GitHub keep a video URL alone in its paragraph.

**Merge Danger.** Two-way: cheap to revert. One-way: migrations, deletions, changed public contracts or persisted formats, published packages, external side effects; say what cannot be undone. Blast Radius is one word (`narrow`, `auth`, `billing`…), then the realistic ramifications, and manual steps before or after merge as a numbered list.

**Publish.** Push the reviewed branch and create the request with `gh` or `glab` (`environment` for access), updating an existing one for this branch instead of opening another; pass the body through a file. Link it to the thread, read the published title and body back, open the page when it embeds media, and return the URL.
