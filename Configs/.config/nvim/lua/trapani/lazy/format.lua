return {
	"sbdchd/neoformat",
	config = function()
		-- Set up keymaps
		vim.keymap.set("n", "<leader>fo", "<cmd>Neoformat<CR>", { desc = "Format with Neoformat" })
		
		-- Enable async formatting on save with a small delay
		vim.api.nvim_create_autocmd("BufWritePre", {
			pattern = "*",
			callback = function()
				local bufnr = vim.api.nvim_get_current_buf()
				vim.defer_fn(function()
					vim.cmd("Neoformat")
				end, 100) -- 100ms delay
			end,
		})
	end,
}
