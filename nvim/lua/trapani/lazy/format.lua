return {
	"sbdchd/neoformat",

	config = function()
		vim.keymap.set("n", "<leader>fo", "<cmd>Neoformat<CR>") -- neoformat formatting (uses prettier or other formatters)
	end,
}
