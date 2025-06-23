return {
	"nvim-lualine/lualine.nvim",

	config = function()
		local lualine = require("lualine")

		lualine.setup({
			options = {
				theme = "catppuccin",
				icons_enabled = true,
				section_separators = "",
				component_separators = "",
				disabled_filetypes = {
					statusline = { "Avante", "AvanteInput", "AvanteSelectedFiles", "NvimTree" },
					winbar = { "Avante", "AvanteInput", "AvanteSelectedFiles", "NvimTree" },
				},
			},
			sections = {
				lualine_a = { "mode" },
				lualine_b = { "branch", "diff", "diagnostics" },
				lualine_c = { "filename" },
				lualine_x = { "filetype" },
				lualine_y = {},
				lualine_z = { "location" },
			},
			inactive_sections = {
				lualine_a = {},
				lualine_b = {},
				lualine_c = { "filename" },
				lualine_x = { "location" },
				lualine_y = {},
				lualine_z = {},
			},
			tabline = {},
			extensions = {},
			silent = true,
		})
	end,
}
