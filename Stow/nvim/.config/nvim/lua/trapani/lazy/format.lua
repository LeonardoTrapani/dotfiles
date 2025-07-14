return {
	"sbdchd/neoformat",
	config = function()
		-- Configure formatter priority - put prettier/prettierd before biome
		-- This ensures prettier is used when available, especially when config files are present
		vim.g.neoformat_enabled_javascript = { "prettierd", "prettier" }
		vim.g.neoformat_enabled_typescript = { "prettierd", "prettier" }
		vim.g.neoformat_enabled_javascriptreact = { "prettierd", "prettier" }
		vim.g.neoformat_enabled_typescriptreact = { "prettierd", "prettier" }
		vim.g.neoformat_enabled_json = { "prettierd", "prettier" }
		vim.g.neoformat_enabled_css = { "prettierd", "prettier" }
		vim.g.neoformat_enabled_scss = { "prettierd", "prettier" }
		vim.g.neoformat_enabled_html = { "prettierd", "prettier" }
		vim.g.neoformat_enabled_markdown = { "prettierd", "prettier" }
		vim.g.neoformat_enabled_yaml = { "prettierd", "prettier" }
		vim.g.neoformat_enabled_vue = { "prettierd", "prettier" }
		vim.g.neoformat_enabled_svelte = { "prettierd", "prettier" }

		-- Additional Neoformat settings to ensure it takes precedence
		vim.g.neoformat_try_node_exe = 1
		vim.g.neoformat_only_msg_on_error = 1

		-- Enable verbose output for debugging (comment out once working)
		-- vim.g.neoformat_verbose = 1

		-- Set up keymaps
		vim.keymap.set("n", "<leader>fo", "<cmd>Neoformat<CR>", { desc = "Format with Neoformat" })

		-- Debug keymap to check which formatter is being used
		vim.keymap.set("n", "<leader>fd", function()
			local filetype = vim.bo.filetype
			local formatters = vim.g["neoformat_enabled_" .. filetype]
			if formatters then
				print("Available formatters for " .. filetype .. ": " .. vim.inspect(formatters))
			else
				print("No custom formatters configured for filetype: " .. filetype)
			end
		end, { desc = "Debug Neoformat settings" })

		-- Enable async formatting on save with a small delay
		-- vim.api.nvim_create_autocmd("BufWritePre", {
		-- 	pattern = "*",
		-- 	callback = function()
		-- 		vim.defer_fn(function()
		-- 			vim.cmd("Neoformat")
		-- 		end, 100) -- 100ms delay
		-- 	end,
		-- })
	end,
}
