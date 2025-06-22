-- Path to lazy.nvim plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

-- Install lazy.nvim if it's not already installed
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	-- Clone the repository with minimal history
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	
	-- Handle installation errors
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end

-- Add lazy.nvim to runtime path
vim.opt.rtp:prepend(lazypath)

-- Initialize lazy.nvim with configuration
require("lazy").setup({
	spec = "trapani.lazy",  -- Load plugins from trapani.lazy module
	change_detection = { notify = false },  -- Disable change detection notifications
})
