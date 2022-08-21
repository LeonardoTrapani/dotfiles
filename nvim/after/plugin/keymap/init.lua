local nnoremap = require("trapani.keymap").nnoremap
local inoremap = require("trapani.keymap").inoremap
local vnoremap = require("trapani.keymap").vnoremap

inoremap("jk", "<ESC>")

-- not yank with x, d and c
nnoremap("x", '"_x')
nnoremap("d", '"_d')
nnoremap("c", '"_c')
vnoremap("d", '"_d')
vnoremap("c", '"_c')

-- cut with <C-x> in selected mode
vnoremap('<C-x>', 'd')

-- disable annoying keys
nnoremap('<Enter>', '<Nop>')
nnoremap('<S-Enter>', '<Nop>')
nnoremap('J', '<Nop>')
vnoremap('J', '<Nop>')
vnoremap('<Enter>', '<Nop>')
-- increment / decrement
nnoremap("+", "<C-a>")
nnoremap("-", "<C-x>")

-- slect all
nnoremap("<C-a>", "gg<S-v>G")
-- split vertical and horizontal
nnoremap("<leader>sv", ":split<Return><C-w>W", { silent = true }) --split vertical
nnoremap("<leader>ss", ":vsplit<Return><C-w>W", { silent = true }) --split
-- move window
nnoremap("<leader><Enter>", "<C-w>w") -- next terminal
nnoremap("<leader>k", "<C-w>k")
nnoremap("<leader>j", "<C-w>j")
nnoremap("<leader>l", "<C-w>l")
nnoremap("<leader>h", "<C-w>h")
--resize window
nnoremap("<leader>+", "10<C-w>>") --bigger horizontally
nnoremap("<leader>-", "10<C-w><") --smaller horizontally
nnoremap("<leader>v+", "10<C-w>+") --bigger vertically
nnoremap("<leader>v-", "10<C-w>-") --smaller vertically
--close buffer
nnoremap("<leader>q", "<cmd>q<CR>")
--save
nnoremap("<leader>w", "<cmd>w<CR>")
--go to previos file
nnoremap("<leader>p", "<C-^>")
