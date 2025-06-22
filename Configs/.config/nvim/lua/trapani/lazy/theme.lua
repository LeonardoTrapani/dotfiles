function ColorMyPencils(color)
	color = color or "onedark"
	vim.cmd.colorscheme(color)

	vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
	vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
end

return {
	"navarasu/onedark.nvim",
	name = "onedark",
	config = function()
		require("onedark").setup({
			style = "dark",
		})
		-- Enable theme
		require("onedark").load()
	end,
}
