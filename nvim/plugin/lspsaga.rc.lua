local nnoremap = require("trapani.keymap").nnoremap

local status, saga = pcall(require, 'lspsaga')
if (not status) then return end


saga.init_lsp_saga {
  server_filetype_map = {
  },
  code_action_lightbulb = {
    enable = true,
    sign = true,
    sign_priority = 20,
    virtual_text = true,
  },
}

local opts = { noremap = true, silent = true }

nnoremap('<C-j>', '<cmd>Lspsaga diagnostic_jump_next<CR>', opts)
nnoremap('<leader>r', '<cmd>Lspsaga rename<CR>', opts)
nnoremap('<leader>i', '<cmd>Lspsaga hover_doc<CR>', opts)
nnoremap('<leader>fr', '<cmd>Lspsaga lsp_finder<CR>', opts)
nnoremap('<leader>d', '<cmd>Lspsaga preview_definition<CR>', opts)
nnoremap('<leader>.', '<cmd>Lspsaga code_action<CR>', opts)
nnoremap('<leader>s', '<cmd>Lspsaga signature_help<CR>', opts)
