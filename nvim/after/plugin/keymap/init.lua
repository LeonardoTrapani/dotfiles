local nnoremap = require("trapani.keymap").nnoremap
local vnoremap = require("trapani.keymap").vnoremap
-- not yank with x, d and c
nnoremap("x", '"_x')
nnoremap("d", '"_d')
nnoremap("c", '"_c')
vnoremap("d", '"_d')
vnoremap("c", '"_c')

-- cut with <C-x> in selected mode
vnoremap('<C-x>', 'd')

-- disable annoying keys
nnoremap('<S-Enter>', '<Nop>')
vnoremap('J', '<Nop>')
vnoremap('<Enter>', '<Nop>')
vnoremap('q', '<Nop>')
nnoremap('q', '<Nop>')
-- increment / decrement
nnoremap("+", "<C-a>")
nnoremap("-", "<C-x>")

-- slect all
nnoremap("<C-a>", "gg<S-v>G")
-- split vertical and horizontal
nnoremap("<leader>v", ":split<Return><C-w>W", { silent = true }) --split vertical
nnoremap("<leader>s", ":vsplit<Return><C-w>W", { silent = true }) --split
-- move window
nnoremap("<leader><Enter>", "<C-w>w") -- next terminal
nnoremap("<leader>k", "<C-w>k")
nnoremap("<leader>j", "<C-w>j")
nnoremap("<leader>l", "<C-w>l")
nnoremap("<leader>h", "<C-w>h")
--resize window
nnoremap("<leader>+", "10<C-w>>") --bigger horizontally
nnoremap("<leader>-", "10<C-w><") --smaller horizontally
nnoremap("<leader>*", "5<C-w>+") --bigger vertically
nnoremap("<leader>_", "5<C-w>-") --smaller vertically
--close buffer
nnoremap("<leader>q", "<cmd>q<CR>")
--save
nnoremap("<leader>w", "<cmd>w<CR>")
--go to previos file
nnoremap("<leader>p", "<C-^>")

--move up and down
nnoremap("J", "<cmd>m .+1<CR>==")
nnoremap("K", "<cmd>m .-2<CR>==")
vnoremap("J", ":m '>+1<CR>gv=gv")
vnoremap("K", ":m '<-2<CR>gv=gv")

--neogit
nnoremap("<leader>ng", "<cmd>Neogit<CR>")
