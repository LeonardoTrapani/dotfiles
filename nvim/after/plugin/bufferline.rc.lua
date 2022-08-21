local nnoremap = require("trapani.keymap").nnoremap

local status, bufferline = pcall(require, 'bufferline')
if (not status) then return end

local dark_color = '#14171a'
local light_color = '#ABB2BF'
local less_light_color = '#677389'

bufferline.setup {
  options = {
    mode = "tabs",
    always_show_bufferline = false,
    show_buffer_close_icons = false,
    show_close_icon = false,
    color_icons = true,
    separator = false
  },
  highlights = {
    separator = {
      fg = dark_color,
      bg = dark_color,
    },
    background = {
      fg = less_light_color,
      bg = dark_color
    },
    buffer_selected = {
      fg = light_color,
      bold = true,
    },
    fill = {
      bg = dark_color
    },
  }
}
nnoremap('<Tab>', '<cmd>BufferLineCycleNext<cr>')
vim.keymap.set('n', '<Tab>', '<Cmd>BufferLineCycleNext<CR>', {})
nnoremap('<S-Tab>', '<cmd>BufferLineCyclePrev<cr>')
nnoremap('<leader>t', '<cmd>tabnew<cr>')
