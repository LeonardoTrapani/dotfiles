return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    filesystem = {
      filtered_items = {
        visible = true, -- Show hidden files by default
        hide_dotfiles = false, -- Show dotfiles (.env, .gitignore, etc.)
        hide_gitignored = false, -- Optional: show gitignored files too
      },
    },
  },
}
