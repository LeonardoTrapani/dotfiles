-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
  {
    'christoomey/vim-tmux-navigator',
    keys = {
      { '<C-h>', '<cmd>TmuxNavigateLeft<CR>', desc = 'Tmux left' },
      { '<C-j>', '<cmd>TmuxNavigateDown<CR>', desc = 'Tmux down' },
      { '<C-k>', '<cmd>TmuxNavigateUp<CR>', desc = 'Tmux up' },
      { '<C-l>', '<cmd>TmuxNavigateRight<CR>', desc = 'Tmux right' },
    },
  },
}
