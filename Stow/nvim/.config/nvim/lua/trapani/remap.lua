-- Set space as the leader key
vim.g.mapleader = " "
-- vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- Visual mode mappings for moving lines up and down
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv") -- Move selected lines down
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv") -- Move selected lines up

-- Normal mode mappings for better navigation
vim.keymap.set("n", "J", "<nope>") -- Disable J in normal mode
vim.keymap.set("n", "<C-d>", "<C-d>zz") -- Center view after half-page down
vim.keymap.set("n", "<C-u>", "<C-u>zz") -- Center view after half-page up
vim.keymap.set("n", "n", "nzzzv") -- Center view after next search
vim.keymap.set("n", "N", "Nzzzv") -- Center view after previous search

-- Quickfix and location list navigation
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz") -- Next location list item
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz") -- Previous location list item

-- Improved paste behavior in visual mode
vim.keymap.set("x", "<leader>p", [["_dP]]) -- Paste without overwriting register

-- System clipboard integration
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]]) -- Yank to system clipboard
vim.keymap.set("n", "<leader>Y", [["+Y]]) -- Yank line to system clipboard

-- Delete without overwriting register
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])

-- Tmux integration
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>") -- Open tmux sessionizer

-- Code formatting options
vim.keymap.set("n", "<leader>fo", "<cmd>Neoformat<CR>") -- Format using Neoformat (prettier or other formatters)
vim.keymap.set("n", "<leader>fl", vim.lsp.buf.format) -- Format using LSP

-- Quickfix navigation
vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz") -- Next quickfix item
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz") -- Previous quickfix item
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz") -- Next location list item
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz") -- Previous location list item

-- Window resizing controls
vim.keymap.set("n", "<C-s>", "<C-w><") -- Decrease window width
vim.keymap.set("n", "<C-b>", "<C-w>>") -- Increase window width
vim.keymap.set("n", "<C-w>=", "<C-w>+") -- Increase window height
vim.keymap.set("n", "ß", "<C-w>-") -- Decrease window height

-- Word replacement
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]]) -- Replace word under cursor

-- Source current file
vim.keymap.set("n", "<leader><leader>", function()
	vim.cmd("so")
end)

-- Cursor AI integration
vim.keymap.set("n", "<leader>ai", function()
	local current_dir = vim.fn.getcwd()
	vim.cmd("!cursor " .. current_dir .. " &")
	vim.notify("Launched Cursor AI in: " .. current_dir, vim.log.levels.INFO)
end)  -- Open Cursor AI in current directory
