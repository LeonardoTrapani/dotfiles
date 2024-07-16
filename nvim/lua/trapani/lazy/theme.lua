function ColorMyPencils(color)
	color = color or "onedark"
	vim.cmd.colorscheme(color)

	vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
	vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
end

return {
	"navarasu/onedark.nvim",
	as = "onedark",
	config = function()
		require("onedark").setup()
		require("onedark").load()
		ColorMyPencils("onedark")
	end,
}
