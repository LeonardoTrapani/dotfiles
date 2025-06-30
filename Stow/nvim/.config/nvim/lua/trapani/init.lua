-- Load core configuration modules
require("trapani.remap") -- Key remappings
require("trapani.set") -- Vim settings
require("trapani.lazy_init") -- Plugin manager initialization

-- Create an augroup for Trapani-specific autocommands
local augroup = vim.api.nvim_create_augroup

-- Create an augroup for yank highlighting
local autocmd = vim.api.nvim_create_autocmd
local yank_group = augroup("HighlightYank", {})

-- Helper function to reload modules during development
function R(name)
	require("plenary.reload").reload_module(name)
end

-- Add custom filetype detection
vim.filetype.add({
	extension = {
		templ = "templ", -- Support for templ files
	},
})

-- Highlight yanked text briefly
autocmd("TextYankPost", {
	group = yank_group,
	pattern = "*",
	callback = function()
		vim.highlight.on_yank({
			higroup = "IncSearch",
			timeout = 40, -- Highlight duration in milliseconds
		})
	end,
})

-- Netrw (file explorer) settings
vim.g.netrw_browse_split = 0 -- Open files in the same window
vim.g.netrw_banner = 0 -- Hide the banner
vim.g.netrw_winsize = 25 -- Set window size
