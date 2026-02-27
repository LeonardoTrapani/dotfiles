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
  'christoomey/vim-tmux-navigator',
  keys = {
    { '<C-h>', '<cmd>TmuxNavigateLeft<CR>', desc = 'Tmux left' },
    { '<C-j>', '<cmd>TmuxNavigateDown<CR>', desc = 'Tmux down' },
    { '<C-k>', '<cmd>TmuxNavigateUp<CR>', desc = 'Tmux up' },
    { '<C-l>', '<cmd>TmuxNavigateRight<CR>', desc = 'Tmux right' },
  },
})

return plugins
