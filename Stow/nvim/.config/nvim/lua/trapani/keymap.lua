-- Module for key mapping utilities
local M = {}

-- Helper function to create key mappings with default options
-- @param op string: The mode to create the mapping for (n, v, i, etc.)
-- @param outer_opts table: Default options for the mapping
local function bind(op, outer_opts)
	outer_opts = outer_opts or { noremap = true }
	return function(lhs, rhs, opts)
		opts = vim.tbl_extend("force", outer_opts, opts or {})
		vim.keymap.set(op, lhs, rhs, opts)
	end
end

-- Create mapping functions for different modes
M.nmap = bind("n", { noremap = false })  -- Normal mode mapping (allows remapping)
M.nnoremap = bind("n")  -- Normal mode mapping (no remapping)
M.vnoremap = bind("v")  -- Visual mode mapping
M.xnoremap = bind("x")  -- Visual block mode mapping
M.inoremap = bind("i")  -- Insert mode mapping

return M
