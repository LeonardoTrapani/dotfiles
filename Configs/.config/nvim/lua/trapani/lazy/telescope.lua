return {
	"nvim-telescope/telescope.nvim",

	dependencies = {
		"nvim-lua/plenary.nvim",
	},

	config = function()
		require("telescope").setup({
			defaults = {
				file_ignore_patterns = {
					"node_modules/.*",
					"pnpm%-lock%.yaml",
					"%.git/.*",
				},
			},
			pickers = {
				find_files = {
					hidden = true,
				},
				live_grep = {
					additional_args = function()
						return { "--hidden" }
					end,
				},
			},
		})

		local builtin = require("telescope.builtin")
		vim.keymap.set("n", "<C-f>", builtin.find_files, {})
		vim.keymap.set("n", "<C-g>", builtin.live_grep, {})
		vim.keymap.set("n", "<C-p>", builtin.git_files, {})

		require("telescope").load_extension("neoclip")

		require("telescope").load_extension("noice")
	end,
}
