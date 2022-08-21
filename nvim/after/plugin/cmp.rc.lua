local status, cmp = pcall(require, "cmp")
if (not status) then return end
local lspkind = require 'lspkind'

cmp.setup({
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-j>'] = cmp.mapping(cmp.mapping.select_next_item()),
    ['<C-k>'] = cmp.mapping(cmp.mapping.select_prev_item()),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-q'] = cmp.mapping.close(),
    ['<CR>'] = cmp.mapping.confirm({
      select = true
    })
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'buffer' },
  }),
  formatting = {
    format = lspkind.cmp_format({ wirth_test = false, maxwidth = 50 })
  }
})

vim.cmd [[
    set completeopt=menuone,noinsert,noselect
    highlight! default link CmpItemKind CmpItemMenuDefault
]]
