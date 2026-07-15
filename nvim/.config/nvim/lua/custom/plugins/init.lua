-- Parse omarchy theme spec to get plugin name and colorscheme
local function load_omarchy_theme()
  local ok, spec = pcall(require, 'omarchy-theme')
  if not ok then return {} end

  local plugins = {}
  local colorscheme = nil

  for _, s in ipairs(spec) do
    if s[1] == 'LazyVim/LazyVim' and s.opts and s.opts.colorscheme then
      colorscheme = s.opts.colorscheme
    elseif s[1] then
      table.insert(plugins, {
        s[1],
        name = s.name,
        lazy = false,
        priority = 1000,
      })
    end
  end

  if colorscheme then
    table.insert(plugins, {
      name = 'omarchy-theme-apply',
      dir = vim.fn.stdpath('config'),
      lazy = false,
      priority = 999,
      config = function()
        vim.cmd.colorscheme(colorscheme)
      end,
    })
  end

  return plugins
end

local plugins = load_omarchy_theme()

table.insert(plugins, {
  'paulbkim-dev/vim-herdr-navigation',
  lazy = false,
  dependencies = { 'christoomey/vim-tmux-navigator' },
  init = function()
    vim.g.tmux_navigator_no_mappings = 1
  end,
  build = 'herdr plugin link .',
  config = function(plugin)
    dofile(plugin.dir .. '/editor/nvim.lua')
  end,
})

table.insert(plugins, {
  'sindrets/diffview.nvim',
  dependencies = { 'nvim-lua/plenary.nvim' },
  cmd = { 'DiffviewOpen', 'DiffviewFileHistory', 'DiffviewClose' },
  keys = {
    { '<leader>gd', '<cmd>DiffviewOpen<CR>', desc = 'Git diff view' },
    { '<leader>gh', '<cmd>DiffviewFileHistory %<CR>', desc = 'Git file history' },
    { '<leader>gH', '<cmd>DiffviewFileHistory<CR>', desc = 'Git repo history' },
    { '<leader>gq', '<cmd>DiffviewClose<CR>', desc = 'Git close diff view' },
  },
})

return plugins
