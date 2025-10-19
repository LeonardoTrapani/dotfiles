return {
	"supermaven-inc/supermaven-nvim",
	config = function()
		require("supermaven-nvim").setup({
			ignore_filetypes = { cpp = true }, -- or { "cpp", }
			log_level = "info", -- set to "off" to disable logging completely
			accept_suggestion = "<Tab>",
			clear_suggestion = false,
			accept_word = false,
			disable_inline_completion = false, -- disables inline completion for use with cmp
			disable_keymaps = false, -- disables built in keymaps for more manual control
			condition = function()
				return false
			end, -- condition to check for stopping supermaven, `true` means to stop supermaven when the condition is true. })
		})
	end,
}
