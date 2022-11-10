vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'

  use 'ful1e5/onedark.nvim'

  use 'nvim-lualine/lualine.nvim'
  use 'kyazdani42/nvim-web-devicons'

  use "glepnir/lspsaga.nvim"
  use 'L3MON4D3/LuaSnip'
  use 'onsails/lspkind-nvim'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/nvim-cmp' -- completion
  use 'neovim/nvim-lspconfig'

  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate'
  }
  use 'nvim-treesitter/nvim-treesitter-context'

  use 'windwp/nvim-autopairs'
  use 'windwp/nvim-ts-autotag'

  use 'nvim-lua/plenary.nvim'

  use 'nvim-telescope/telescope.nvim'
  use 'nvim-telescope/telescope-file-browser.nvim'


  use { 'akinsho/bufferline.nvim', tag = "v2.*" }
  use 'norcalli/nvim-colorizer.lua'

  use 'TimUntersberger/neogit'
  use 'lewis6991/gitsigns.nvim'
  use 'dinhhuy258/git.nvim'

  use 'preservim/nerdcommenter'
  use 'tpope/vim-surround'

  use 'tpope/vim-obsession'

  --format
  use 'sbdchd/neoformat'
end)
