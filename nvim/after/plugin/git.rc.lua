local status, git = pcall(require, 'git')
if (not status) then return end

git.setup {
  keymaps = {
    blame = "<leader>gb",
    -- open in git rep
    browse = "<leader>go"
  }
}

local status2, gitsigns = pcall(require, 'gitsigns')
if (not status2) then return end

gitsigns.setup {}

local status3, diff_view = pcall(require, 'diffview')
if (not status3) then return end

diff_view.setup({
  use_icons = true,
})

