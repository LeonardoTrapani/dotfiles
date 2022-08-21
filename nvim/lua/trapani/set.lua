vim.cmd("autocmd!")

vim.opt.title = true

vim.opt.autoindent = true
vim.opt.smartindent = true

vim.wo.nu = true
vim.opt.relativenumber = true

vim.opt.errorbells = false

vim.opt.smarttab = true
vim.opt.breakindent = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.wrap = false -- No Wrap lines

vim.opt.expandtab = true

vim.opt.showcmd = true

vim.opt.title = true

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.backup = false

vim.opt.termguicolors = true

vim.opt.scrolloff = 8

-- Give more space for displaying messages.
vim.opt.cmdheight = 1

vim.opt.updatetime = 50

vim.opt.shell = 'fish'

vim.opt.ignorecase = true
vim.opt.breakindent = true
vim.opt.ai = true
vim.opt.si = true

vim.opt.path:append { '**' }

-- underurl
vim.cmd([[let &t_Cs = "\e[4:3m"]])
vim.cmd([[let &t_Ce = "\e[4:0m"]])

--clipboard with system
vim.opt.clipboard:append { 'unnamedplus' }
vim.opt.path:append { '**' }
vim.opt.wildignore:append { '*/node_modules/*' }

vim.g.mapleader = " "
