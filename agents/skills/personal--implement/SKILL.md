---
name: implement
description: >-
  Implement a piece of work based on a spec or set of tickets, then open a PR/MR
  for it.
disable-model-invocation: true
---
Implement the work described by the user in the spec or tickets.

If the work changes anything visible, take before screenshots before editing code.

Run typechecking regularly, single test files regularly, and the full test suite once at the end.

Once done, use `code-review` to review the work.

Commit your work to the current branch. If the current branch is the default branch, create a branch named after the ticket first.

Open a PR (GitHub) or MR (GitLab) when the work is meant to be reviewed and merged, as with a ticket, or whenever the user mentions a PR/MR. Skip it only if the user says not to.

1. Push the branch.
2. Target the branch the user named; otherwise the repository's default branch.
3. Write the title and description with `pr`, including before/after screenshots for visible changes. Reference the ticket so the tracker links it.
4. Do not merge. Report the PR/MR URL, or the blocker that prevented creating it.

Agent metadata: `agents/openai.yaml`
