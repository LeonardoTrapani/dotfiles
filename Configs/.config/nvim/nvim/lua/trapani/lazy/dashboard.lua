return {
	"nvimdev/dashboard-nvim",
	event = "VimEnter",
	config = function()
		require("dashboard").setup({
			theme = "doom",
			config = {
				header = (function()
					local cwd = vim.fn.getcwd()
					local dir_name = vim.fn.fnamemodify(cwd, ":t")
					local width = 50 -- Total width of the box
					local padding_width = width - 2 -- Internal width (excluding borders)
					local dir_len = #dir_name
					local left_padding = math.floor((padding_width - dir_len) / 2)
					local right_padding = padding_width - dir_len - left_padding
					local horizontal_line = string.rep("─", padding_width)

					return {
						"",
						"",
						"╭" .. horizontal_line .. "╮",
						"│" .. string.rep(" ", padding_width) .. "│",
						"│" .. string.rep(" ", left_padding) .. dir_name .. string.rep(" ", right_padding) .. "│",
						"│" .. string.rep(" ", padding_width) .. "│",
						"╰" .. horizontal_line .. "╯",
						"",
						"",
					}
				end)(),
				center = {
					{
						icon = "  ",
						icon_hl = "Title",
						desc = "Find File",
						desc_hl = "String",
						key = "f",
						key_hl = "Number",
						action = "Telescope find_files",
					},
					{
						icon = "  ",
						icon_hl = "Title",
						desc = "Recent Files",
						desc_hl = "String",
						key = "r",
						key_hl = "Number",
						action = "Telescope oldfiles",
					},
					{
						icon = "  ",
						icon_hl = "Title",
						desc = "Find Word",
						desc_hl = "String",
						key = "w",
						key_hl = "Number",
						action = "Telescope live_grep",
					},
					{
						icon = "  ",
						icon_hl = "Title",
						desc = "New File",
						desc_hl = "String",
						key = "n",
						key_hl = "Number",
						action = "enew",
					},
					{
						icon = "  ",
						icon_hl = "Title",
						desc = "Config",
						desc_hl = "String",
						key = "c",
						key_hl = "Number",
						action = "e ~/.config/nvim/init.lua",
					},
					{
						icon = "  ",
						icon_hl = "Title",
						desc = "Quit",
						desc_hl = "String",
						key = "q",
						key_hl = "Number",
						action = "qa",
					},
				},
			},
		})
	end,
	dependencies = {
		{ "nvim-tree/nvim-web-devicons" },
		{ "nvim-telescope/telescope.nvim" },
	},
}
