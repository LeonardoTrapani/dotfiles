return {
  'supermaven-inc/supermaven-nvim',
  event = 'VimEnter',
  cmd = { 'SupermavenUseFree', 'SupermavenUsePro', 'SupermavenStart', 'SupermavenStop', 'SupermavenStatus' },
  opts = {
    keymaps = {
      accept_suggestion = '<C-y>',
      clear_suggestion = '<C-]>',
      accept_word = '<C-j>',
    },
    ignore_filetypes = { cpp = true },
    log_level = 'info',
    disable_inline_completion = false,
    disable_keymaps = false,
  },
}
