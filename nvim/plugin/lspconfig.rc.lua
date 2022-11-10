local nnoremap = require("trapani.keymap").nnoremap

local status, nvim_lsp = pcall(require, 'lspconfig')
if (not status) then return end

local function config(_config)
	return vim.tbl_deep_extend("force", {
		capabilities = require("cmp_nvim_lsp").update_capabilities(vim.lsp.protocol.make_client_capabilities()),
		on_attach = function()
			nnoremap("<leader>d", function() vim.lsp.buf.definition() end)
		end,
	}, _config or {})
end

--

--typesciprt
nvim_lsp.tsserver.setup(config())
--css
nvim_lsp.cssls.setup(config())
--prisma
nvim_lsp.prismals.setup(config())
--css modules
nvim_lsp.cssmodules_ls.setup(config())
--tailwindcss
nvim_lsp.tailwindcss.setup(config())
--eslint
nvim_lsp.eslint.setup(config())
--dart
nvim_lsp.dartls.setup(config())
--fish
nvim_lsp.bashls.setup(config())
--rust
nvim_lsp.rust_analyzer.setup(config({
  cmd = { "rustup", "run", "nightly", "rust-analyzer" },
  --[[
    settings = {
        rust = {
            unstable_features = true,
            build_on_save = false,
            all_features = true,
        },
    }
    --]]
}))

--lua
require("lspconfig").sumneko_lua.setup(config({
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
        version = "LuaJIT",
        -- Setup your lua path
        path = vim.split(package.path, ";"),
      },
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = { "vim" },
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = {
          [vim.fn.expand("$VIMRUNTIME/lua")] = true,
          [vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
        },
      },
    },
  },
}))
--c 
require("lspconfig").sourcekit.setup(config({}))
require("lspconfig").ccls.setup(config({}))
