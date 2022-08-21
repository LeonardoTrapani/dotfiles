local status, icons = pcall(require, 'nvim-web-devions')
if (not status) then return end

icons.setup {
    override = {},
    default = true
}
