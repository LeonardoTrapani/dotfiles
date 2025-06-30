-- Clear all autocommands
vim.cmd("autocmd!")

-- Enable window title
vim.opt.title = true

-- Indentation settings
vim.opt.autoindent = true  -- Copy indent from current line when starting a new line
vim.opt.smartindent = true  -- Do smart autoindenting when starting a new line

-- Line numbers
vim.wo.nu = true  -- Show absolute line numbers
vim.opt.relativenumber = true  -- Show relative line numbers

-- Disable error bells
vim.opt.errorbells = false

-- Tab and indentation settings
vim.opt.smarttab = true  -- Use shiftwidth when inserting <Tab>
vim.opt.breakindent = true  -- Preserve indentation in wrapped lines
vim.opt.shiftwidth = 2  -- Number of spaces to use for each step of (auto)indent
vim.opt.tabstop = 2  -- Number of spaces that a <Tab> in the file counts for
vim.opt.wrap = true  -- Enable line wrapping

-- Use spaces instead of tabs
vim.opt.expandtab = true

-- Show command in status line
vim.opt.showcmd = true

-- File handling
vim.opt.swapfile = false  -- Don't create swap files
vim.opt.backup = false  -- Don't create backup files
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"  -- Set undo directory
vim.opt.undofile = true  -- Enable persistent undo

-- Search settings
vim.opt.hlsearch = false  -- Don't highlight search matches
vim.opt.incsearch = true  -- Show search matches as you type

-- Enable true color support
vim.opt.termguicolors = true

-- Scrolling
vim.opt.scrolloff = 8  -- Keep 8 lines above/below cursor when scrolling

-- Command line height
vim.opt.cmdheight = 1

-- Timing settings
vim.o.updatetime = 250  -- Faster completion
vim.o.timeout = true  -- Enable timeout
vim.o.timeoutlen = 300  -- Time to wait for a mapped sequence to complete

-- Search and case settings
vim.opt.ignorecase = true  -- Ignore case in search patterns
vim.opt.breakindent = true  -- Preserve indentation in wrapped lines
vim.opt.ai = true  -- Enable auto-indentation
vim.opt.si = true  -- Enable smart indentation

-- Path settings
vim.opt.path:append({ "**" })  -- Search in subdirectories

-- Underline settings for terminal
vim.cmd([[let &t_Cs = "\e[4:3m"]])  -- Start underline
vim.cmd([[let &t_Ce = "\e[4:0m"]])  -- End underline

-- Clipboard integration
vim.opt.clipboard:append({ "unnamedplus" })  -- Use system clipboard

-- Path and ignore settings
vim.opt.path:append({ "**" })  -- Search in subdirectories
vim.opt.wildignore:append({ "*/node_modules/*" })  -- Ignore node_modules

-- Sign column settings
vim.opt_local.signcolumn = "yes"  -- Always show sign column

-- Set leader key
vim.g.mapleader = " "

-- Command line height
vim.opt.cmdheight = 1

-- Function to disable automatic closing brackets
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

-- Status line settings
vim.opt.laststatus = 3  -- Global status line

-- Buffer appearance
vim.opt.fillchars = { eob = " " }  -- Remove tilde characters at end of buffer
