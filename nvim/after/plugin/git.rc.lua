local status, git = pcall(require, 'git')
if (not status) then return end

git.setup {
  keymaps = {
    blame = "<leader>gb",
    -- open in git rep
    browse = "<leader>go"
  }
}
