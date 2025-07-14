function ColorMyPencils(color)
	vim.cmd.colorscheme(color)

	vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
	vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
end

return {
	"catppuccin/nvim",
	name = "catppuccin",
	config = function()
		require("catppuccin").setup({
			tranparent_backgroun = true,
		})

		ColorMyPencils("catppuccin")
	end,
}

-- return {
--   "navarasu/onedark.nvim",
--   name = "onedark",
--   config = function()
--     require("onedark").setup({
--       style = "dark",
--       transparent = true,
--       term_colors = true,
--       lualine_style = "default",
--       hide_in_width = true,
--       disable_background = true,
--     })
--     ColorMyPencils("onedark")
--   end,
-- }
