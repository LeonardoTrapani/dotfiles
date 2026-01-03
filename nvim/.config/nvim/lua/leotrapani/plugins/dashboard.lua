return {
  'goolord/alpha-nvim',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    local alpha = require 'alpha'
    local startify = require 'alpha.themes.startify'

    startify.section.header.val = {
      '   ███        ▄████████    ▄████████    ▄███████▄    ▄████████ ███▄▄▄▄    ▄█  ',
      '▀█████████▄   ███    ███   ███    ███   ███    ███   ███    ███ ███▀▀▀██▄ ███  ',
      '   ▀███▀▀██   ███    ███   ███    ███   ███    ███   ███    ███ ███   ███ ███▌  ',
      '    ███   ▀  ▄███▄▄▄▄██▀   ███    ███   ███    ███   ███    ███ ███   ███ ███▌  ',
      '    ███     ▀▀███▀▀▀▀▀   ▀███████████ ▀█████████▀  ▀███████████ ███   ███ ███▌  ',
      '    ███     ▀███████████   ███    ███   ███          ███    ███ ███   ███ ███   ',
      '    ███       ███    ███   ███    ███   ███          ███    ███ ███   ███ ███   ',
      '   ▄████▀     ███    ███   ███    █▀   ▄████▀        ███    █▀   ▀█   █▀  █▀   ',
    }
    startify.section.header.opts = { hl = 'Type', position = 'start' }
    startify.section.footer.opts = { position = 'start' }

    alpha.setup(startify.config)
  end,
}
