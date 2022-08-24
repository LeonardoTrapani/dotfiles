vim.g.neoformat_try_node_exe = 1
vim.g.neoformat_only_msg_on_error = 1

-- format on save
vim.api.nvim_command [[augroup Format]]
vim.api.nvim_command [[autocmd! * <buffer>]]
vim.api.nvim_command [[au BufWritePre * try | undojoin | Neoformat | catch /^Vim\%((\a\+)\)\=:E790/ | finally | silent Neoformat | endtry]]
vim.api.nvim_command [[augroup END]]
