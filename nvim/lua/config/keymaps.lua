-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Visual mode mappings for moving lines up and down
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv") -- Move selected lines down
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv") -- Move selected lines up

-- Normal mode mappings for better navigation
vim.keymap.set("n", "J", "<nope>") -- Disable J in normal mode

-- Improved paste behavior in visual mode
-- https://github.com/neovim/neovim/issues/14586#issuecomment-1034818763
vim.keymap.set("x", "p", [["_dP]]) -- Paste without autoindent and autoformat

vim.keymap.set("x", "<leader>p", [["_dP]]) -- Paste without overwriting register

-- Tmux integration
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>") -- Open tmux sessionizer

-- Word replacement
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]]) -- Replace word under cursor
