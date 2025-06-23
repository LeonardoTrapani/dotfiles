return {
	"rcarriga/nvim-notify",
	keys = {
		{
			"<leader>dn",
			function()
				require("notify").dismiss({ silent = true, pending = true })
			end,
			desc = "Dismiss All Notifications",
		},
		{
			"<leader>n",
			function()
				require("telescope").extensions.notify.notify()
			end,
			desc = "Open Notifications in Telescope",
		},
	},
	opts = {
		render = "minimal",
		stages = "slide",
		timeout = 2000,
		max_height = function()
			return math.floor(vim.o.lines * 0.75)
		end,
		max_width = function()
			return math.floor(vim.o.columns * 0.75)
		end,
		on_open = function(win)
			vim.api.nvim_win_set_config(win, { zindex = 100 })
		end,
	},
	init = function()
		vim.notify = require("notify")
	end,
}
