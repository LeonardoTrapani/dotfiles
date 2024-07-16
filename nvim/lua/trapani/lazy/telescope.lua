return {
	"nvim-telescope/telescope.nvim",

	dependencies = {
		"nvim-lua/plenary.nvim",
	},

	config = function()
		require("telescope").setup({})

		local builtin = require("telescope.builtin")
		vim.keymap.set("n", "<C-f>", builtin.find_files, {})
		vim.keymap.set("n", "<C-g>", builtin.live_grep, {})
		vim.keymap.set("n", "<C-p>", builtin.git_files, {})
	end,
}
