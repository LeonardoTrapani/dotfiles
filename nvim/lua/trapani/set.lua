vim.cmd("autocmd!")

vim.opt.title = true

vim.opt.autoindent = true
vim.opt.smartindent = true

vim.wo.nu = true
vim.opt.relativenumber = true

vim.opt.errorbells = false

vim.opt.smarttab = true
vim.opt.breakindent = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.wrap = true

vim.opt.expandtab = true

vim.opt.showcmd = true

vim.opt.title = true

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.backup = false

vim.opt.termguicolors = true

vim.opt.scrolloff = 8

-- Give more space for displaying messages.
vim.opt.cmdheight = 1

vim.o.updatetime = 250
vim.o.timeout = true
vim.o.timeoutlen = 300

vim.opt.ignorecase = true
vim.opt.breakindent = true
vim.opt.ai = true
vim.opt.si = true

vim.opt.path:append({ "**" })

-- underurl
vim.cmd([[let &t_Cs = "\e[4:3m"]])
vim.cmd([[let &t_Ce = "\e[4:0m"]])

--clipboard with system
vim.opt.clipboard:append({ "unnamedplus" })
vim.opt.path:append({ "**" })
vim.opt.wildignore:append({ "*/node_modules/*" })

vim.opt_local.signcolumn = "yes"

vim.g.mapleader = " "

vim.opt.cmdheight = 1
--
-- Disable automatic closing brackets
function disable_auto_close_brackets()
	vim.api.nvim_set_keymap("i", "(", "(", { noremap = true })
	vim.api.nvim_set_keymap("i", "[", "[", { noremap = true })
	vim.api.nvim_set_keymap("i", "{", "{", { noremap = true })
	vim.api.nvim_set_keymap("i", '"', '"', { noremap = true })
	vim.api.nvim_set_keymap("i", "'", "'", { noremap = true })
	-- Add more characters if needed
end

-- Call the function to disable auto closing brackets
-- disable_auto_close_brackets()

vim.opt.laststatus = 3 -- views can only be fully collapsed with the global statusline

-- Set fillchars to avoid tilde on the end of the buffer
vim.opt.fillchars = { eob = " " }
