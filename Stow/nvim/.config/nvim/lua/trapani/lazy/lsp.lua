-- LSP (Language Server Protocol) Configuration Module
-- This module sets up Neovim's LSP capabilities, including:
-- - Language server configurations
-- - Mason for LSP server management
-- - Completion (nvim-cmp)
-- - Diagnostics and formatting
-- - Key mappings for LSP features

return {
	-- Main LSP configuration plugin
	"neovim/nvim-lspconfig",

	-- Dependencies required for LSP functionality
	dependencies = {
		-- Lua LSP configuration for Neovim config and plugins
		{
			"folke/lazydev.nvim",
			ft = "lua",
			opts = {
				library = {
					-- Load luvit types when the `vim.uv` word is found
					{ path = "luvit-meta/library", words = { "vim%.uv" } },
					{ path = "/usr/share/awesome/lib/", words = { "awesome" } },
				},
			},
		},
		{ "Bilal2453/luvit-meta", lazy = true },

		-- Mason and related plugins for LSP server management
		"williamboman/mason.nvim",
		"williamboman/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",

		-- UI enhancements for LSP
		{ "j-hui/fidget.nvim", opts = {} },
		{ "https://git.sr.ht/~whynothugo/lsp_lines.nvim" },

		-- Completion framework and sources
		"hrsh7th/nvim-cmp",
		"hrsh7th/cmp-nvim-lsp",
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-path",
		"hrsh7th/cmp-cmdline",
		"L3MON4D3/LuaSnip",
		"saadparwaiz1/cmp_luasnip",

		-- JSON schema support
		"b0o/schemastore.nvim",

		-- Autoformatting
		"stevearc/conform.nvim",
	},

	config = function()
		-- Setup completion capabilities
		local cmp = require("cmp")

		-- Language Server Configurations
		-- Each entry can be either a boolean (true for default config) or a table with custom settings
		local servers = {
			-- Shell scripting
			bashls = true,

			-- Go language
			gopls = {},

			-- Lua language
			lua_ls = {},

			-- Web development
			svelte = true,

			-- Python
			pyright = {},

			-- ESLint for JavaScript/TypeScript linting
			eslint = {},

			-- TypeScript and JavaScript
			vtsls = {},
			jsonls = {},

			-- YAML
			yamlls = {},

			-- C/C++
			clangd = {},

			-- Tailwind CSS
			tailwindcss = {},
		}

		-- Initialize Fidget for LSP progress
		require("fidget").setup({})

		-- Setup Mason for LSP server management
		require("mason").setup()

		-- Setup mason-lspconfig to bridge Mason and lspconfig
		require("mason-lspconfig").setup({
      -- all server, not just the ones that need to be installed via Mason
			ensure_installed = vim.tbl_keys(servers),
			automatic_installation = true,
		})

		-- Define base tools to ensure are installed (non-LSP tools)
		local ensure_tools_installed = {
			"stylua",
			"prettierd",
		}

		-- Setup mason-tool-installer for non-LSP tools
		require("mason-tool-installer").setup({ ensure_installed = ensure_tools_installed })

		-- Configure completion behavior
		local cmp_select = { behavior = cmp.SelectBehavior.Select }

		-- Setup nvim-cmp
		cmp.setup({
			snippet = {
				expand = function(args)
					require("luasnip").lsp_expand(args.body)
				end,
			},
			mapping = cmp.mapping.preset.insert({
				["<C-Space>"] = cmp.mapping.complete(),
				["<C-k>"] = cmp.mapping.select_prev_item(cmp_select),
				["<C-j>"] = cmp.mapping.select_next_item(cmp_select),
				["<C-y>"] = cmp.mapping.confirm({ select = true }),
			}),
			sources = cmp.config.sources({
				{ name = "nvim_lsp" },
				{ name = "luasnip" },
				{ name = "supermaven" },
			}, {
				{ name = "buffer" },
			}),
		})

		-- Configure diagnostic display
		vim.diagnostic.config({
			float = {
				focusable = false,
				style = "minimal",
				border = "rounded",
				header = "",
				prefix = "",
			},
		})

		-- Setup command-line completion
		cmp.setup.cmdline("/", {
			mapping = cmp.mapping.preset.cmdline(),
			sources = {
				{ name = "buffer" },
			},
		})

		cmp.setup.cmdline(":", {
			mapping = cmp.mapping.preset.cmdline(),
			sources = cmp.config.sources({
				{ name = "path" },
			}, {
				{
					name = "cmdline",
					option = {
						ignore_cmds = { "Man", "!" },
					},
				},
			}),
		})

		-- Configure LSP key mappings and behavior when attaching to a buffer
		vim.api.nvim_create_autocmd("LspAttach", {
			callback = function(args)
				local opts = { buffer = 0 }
				local client = assert(vim.lsp.get_client_by_id(args.data.client_id), "must have valid client")

				local settings = servers[client.name]
				if type(settings) ~= "table" then
					settings = {}
				end

				local builtin = require("telescope.builtin")

				-- Set up LSP key mappings
				vim.opt_local.omnifunc = "v:lua.vim.lsp.omnifunc"
				vim.keymap.set("n", "gd", builtin.lsp_definitions, opts)
				vim.keymap.set("n", "gr", builtin.lsp_references, opts)
				vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
				vim.keymap.set("n", "gT", vim.lsp.buf.type_definition, { buffer = 0 })
				vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)

				vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, opts)
				vim.keymap.set("n", "<leader>.", vim.lsp.buf.code_action, opts)

				vim.keymap.set("n", "<leader>vws", builtin.lsp_workspace_symbols, opts)
				vim.keymap.set("n", "<leader>vd", builtin.diagnostics, opts)
				vim.keymap.set("n", "<Tab>", vim.diagnostic.goto_next, opts)
				vim.keymap.set("n", "<S-Tab>", vim.diagnostic.goto_prev, opts)
				if settings.server_capabilities then
					for k, v in pairs(settings.server_capabilities) do
						if v == vim.NIL then
							v = nil
						end
						client.server_capabilities[k] = v
					end
				end
			end,
		})

		-- Setup LSP lines for inline diagnostics
		require("lsp_lines").setup()
		vim.diagnostic.config({ virtual_text = true, virtual_lines = false })

		-- Toggle between virtual text and virtual lines for diagnostics
		vim.keymap.set("", "<leader>l", function()
			local config = vim.diagnostic.config() or {}
			if config.virtual_text then
				vim.diagnostic.config({ virtual_text = false, virtual_lines = true })
			else
				vim.diagnostic.config({ virtual_text = true, virtual_lines = false })
			end
		end, { desc = "Toggle lsp_lines" })
	end,
}
