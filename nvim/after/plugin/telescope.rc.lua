local nnoremap = require("trapani.keymap").nnoremap

local status, telescope = pcall(require, 'telescope')
if (not status) then return end
local actions = require('telescope.actions')

local fb_actions = require "telescope".extensions.file_browser.actions

local function telescope_buffer_dir()
  return vim.fn.expand('%:p:h')
end

telescope.setup {
  defaults = {
    mappings = {
      n = {
        ["q"] = actions.close
      }
    }
  },
  extensions = {
    file_browser = {
      theme = "dropdown",
      -- disables netrw and use telescope-file-browser in its place
      hijack_netrw = true,
      mappings = {
        ["n"] = {
          ["h"] = fb_actions.goto_parent_dir,
          ["e"] = function() end
        },
      },
    },
  },
}

telescope.load_extension("file_browser")

nnoremap('<leader>ff', '<cmd>Telescope find_files<cr>')
nnoremap('<leader>fs', '<cmd>Telescope live_grep<cr>')

nnoremap('<leader>e', function()
  telescope.extensions.file_browser.file_browser({
    path = "%:p:h",
    cwd = telescope_buffer_dir(),
    respect_gitignore = false,
    hidden = true,
    grouped = true,
    previewer = false,
    initial_mode = "normal",
    layout_config = { height = 40 }
  })
end)
