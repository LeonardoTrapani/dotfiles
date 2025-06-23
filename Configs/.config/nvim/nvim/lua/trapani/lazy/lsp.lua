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
		-- Helper function to extend configuration with default values
		local extend = function(name, key, values)
			local mod = require(string.format("lspconfig.configs.%s", name))
			local default = mod.default_config
			local keys = vim.split(key, ".", { plain = true })

			-- Navigate through nested configuration
			while #keys > 0 do
				local item = table.remove(keys, 1)
				default = default[item]
			end

			-- Handle both list and table configurations
			if vim.islist(default) then
				for _, value in ipairs(default) do
					table.insert(values, value)
				end
			else
				for item, value in pairs(default) do
					if not vim.tbl_contains(values, item) then
						values[item] = value
					end
				end
			end
			return values
		end

		-- Setup completion capabilities
		local cmp = require("cmp")
		local capabilities = nil
		if pcall(require, "cmp_nvim_lsp") then
			capabilities = require("cmp_nvim_lsp").default_capabilities()
		end

		local lspconfig = require("lspconfig")

		-- Language Server Configurations
		-- Each entry can be either a boolean (true for default config) or a table with custom settings
		local servers = {
			-- Shell scripting
			bashls = true,

			-- Go language
			gopls = {
				manual_install = true,
				settings = {
					gopls = {
						hints = {
							assignVariableTypes = true,
							compositeLiteralFields = true,
							compositeLiteralTypes = true,
							constantValues = true,
							functionTypeParameters = true,
							parameterNames = true,
							rangeVariableTypes = true,
						},
					},
				},
			},

			-- Graphics and shaders
			glsl_analyzer = true,

			-- Lua language
			lua_ls = {},

			-- Systems programming
			rust_analyzer = true,

			-- Web development
			svelte = true,
			templ = true,
			taplo = true,

			-- PHP
			intelephense = {
				settings = {
					intelephense = {
						format = {
							braces = "k&r",
						},
					},
				},
			},

			-- Python
			pyright = true,
			ruff = { manual_install = true },

			-- Web development and JavaScript ecosystem
			biome = true,
			astro = true,
			-- TypeScript and JavaScript
			vtsls = {
				server_capabilities = {
					documentFormattingProvider = false,
				},
			},
			jsonls = {
				server_capabilities = {
					documentFormattingProvider = false,
				},
				settings = {
					json = {
						schemas = require("schemastore").json.schemas(),
						validate = { enable = true },
					},
				},
			},

			-- YAML
			yamlls = {
				settings = {
					yaml = {
						schemaStore = {
							enable = false,
							url = "",
						},
					},
				},
			},

			-- Other languages
			ols = {},
			racket_langserver = { manual_install = true },
			roc_ls = { manual_install = true },
			gleam = { manual_install = true },

			-- Elixir
			lexical = {
				cmd = { "/home/tjdevries/.local/share/nvim/mason/bin/lexical", "server" },
				root_dir = require("lspconfig.util").root_pattern({ "mix.exs" }),
				server_capabilities = {
					completionProvider = vim.NIL,
					definitionProvider = true,
				},
			},

			-- C/C++
			clangd = {
				init_options = { clangdFileStatus = true },
				filetypes = { "c" },
			},

			-- Tailwind CSS
			tailwindcss = {
				init_options = {
					userLanguages = {
						elixir = "phoenix-heex",
						eruby = "erb",
						heex = "phoenix-heex",
					},
				},
				filetypes = extend("tailwindcss", "filetypes", { "ocaml.mlx" }),
				settings = {
					tailwindCSS = {
						experimental = {
							classRegex = {
								[[class: "([^"]*)]],
								[[className="([^"]*)]],
							},
						},
						includeLanguages = extend("tailwindcss", "settings.tailwindCSS.includeLanguages", {
							["ocaml.mlx"] = "html",
						}),
					},
				},
			},
		}

		-- Initialize Fidget for LSP progress
		require("fidget").setup({})

		-- Filter servers that need to be installed via Mason
		local servers_to_install = vim.tbl_filter(function(key)
			local t = servers[key]
			if type(t) == "table" then
				return not t.manual_install
			else
				return t
			end
		end, vim.tbl_keys(servers))

		-- Setup Mason for LSP server management
		require("mason").setup()

		-- Define base tools to ensure are installed
		local ensure_installed = {
			"stylua",
			"lua_ls",
		}

		-- Add all auto-installable servers to the ensure_installed list
		vim.list_extend(ensure_installed, servers_to_install)
		require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

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
			}, {
				{ name = "buffer" },
			}),
		})

		-- Setup each language server
		for name, config in pairs(servers) do
			if config == true then
				config = {}
			end
			config = vim.tbl_deep_extend("force", {}, {
				capabilities = capabilities,
			}, config)

			lspconfig[name].setup(config)
		end

		-- Configure which filetypes should have semantic tokens disabled
		local disable_semantic_tokens = {
			-- lua = true,
		}

		-- Configure diagnostic display
		vim.diagnostic.config({
			float = {
				focusable = false,
				style = "minimal",
				border = "rounded",
				source = "always",
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
				local bufnr = args.buf
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

				-- Handle semantic tokens
				local filetype = vim.bo[bufnr].filetype
				if disable_semantic_tokens[filetype] then
					client.server_capabilities.semanticTokensProvider = nil
				end

				-- Override server capabilities if specified
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
