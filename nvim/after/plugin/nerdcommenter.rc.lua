local nnoremap = require("trapani.keymap").nnoremap
local vnoremap = require("trapani.keymap").vnoremap

nnoremap("<leader>cc", "<Nop>")
nnoremap("", "<cmd>call nerdcommenter#Comment(0, 'Toggle')<CR>") --  because it is like control + 7
vnoremap('', ":call nerdcommenter#Comment(0, 'Toggle')<CR>") --  because it is like control + 7
