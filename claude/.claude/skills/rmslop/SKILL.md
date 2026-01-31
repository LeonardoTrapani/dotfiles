---
name: rmslop
description: Remove AI code slop. Use when asked to remove AI-generated slop, clean up code, remove unnecessary comments, defensive checks, or inconsistent style introduced by AI. Triggers on: remove slop, clean code, rmslop, remove AI comments, cleanup code.
version: 1.0.0
user-invocable: true
---

Check the git diff on the current branch, and remove all AI generated slop introduced in this branch.

This includes:

- Extra comments that a human wouldn't add or is inconsistent with the rest of the file
- Extra defensive checks or try/catch blocks that are abnormal for that area of the codebase (especially if called by trusted / validated codepaths)
- Casts to any to get around type issues
- Any other style that is inconsistent with the file
- Unnecessary emoji usage

Report at the end with only a 1-3 sentence summary of what you changed
