return {
	"nvim-tree/nvim-tree.lua",
	config = function()
		vim.g.loaded_netrw = 1
		vim.g.loaded_netrwPlugin = 1

		require("nvim-tree").setup({
			filters = {
				dotfiles = false,
			},
			git = {
				enable = true,
				ignore = false,
				timeout = 500,
			},
      --put it on the right side
      view = {
        width = 60,
        side = 'right',
      }
		})

		vim.keymap.set("n", "<leader>u", ":NvimTreeFindFileToggle<CR>", { silent = true })
	end,
}
