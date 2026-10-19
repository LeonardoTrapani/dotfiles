---
name: manual-review
description: >-
  Opens the current changes beside the active agent pane in Neovim Diffview,
  with a changed-file list, stacked old/new views, and Tab file navigation. Use
  only when the user explicitly asks for a manual or interactive review. Do not
  use for automated code review.
disable-model-invocation: true
---
# Manual Review

1. Follow `herdr` to verify Herdr and target the caller pane by its stable ID.
2. Choose the Diffview input for the changes just made:
   - Use `DiffviewOpen <fixed-point>` when the task or conversation names a base. This includes later commits and current working-tree changes.
   - Use `DiffviewOpen` when the working tree has changes and no base was named.
   - Use `DiffviewOpen HEAD^..HEAD` when the work was committed and the working tree is clean.
3. Check that Neovim has Diffview before changing the pane layout:

   ```bash
   nvim --headless "+lua assert(vim.fn.exists(':DiffviewOpen') == 2, 'DiffviewOpen is unavailable')" +qa
   ```

4. Inspect the caller pane layout. Split it right when wide and down when narrow, and focus the new pane.
5. Start Neovim in the new pane with Diffview's changed-file panel and vertically stacked old/new views. Replace `<diffview-command>` with the command chosen in Step 2:

   ```bash
   nvim \
     -c "lua require('diffview').setup({ view = { default = { layout = 'diff2_vertical' } } })" \
     -c "<diffview-command>"
   ```

6. Inspect the new pane. Completion means:
   - the foreground process is `nvim`;
   - the left panel lists changed files;
   - the old and new file views are stacked;
   - `<Tab>` and `<S-Tab>` select the next and previous changed files.
7. If Diffview is unavailable or fails to open, fall back to Hunk:
   - Use `hunk diff <fixed-point>` when a base was named.
   - Use `hunk diff` for working-tree changes.
   - Use `hunk show HEAD` for a clean, committed change.
   - For live Hunk session control, follow `hunk-review`.
