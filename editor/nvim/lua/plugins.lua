-- 自动安装 Packer.nvim
local fn = vim.fn
local ensure_packer = function()
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

return require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'

  -- nvim-tree
  use {'nvim-tree/nvim-tree.lua', requires = 'nvim-tree/nvim-web-devicons'}
  
  -- bufferline
  use {"akinsho/bufferline.nvim", tag = "v3.*", requires = 'nvim-tree/nvim-web-devicons'}

  -- lualine
  use {'nvim-lualine/lualine.nvim', requires = 'kyazdani42/nvim-web-devicons'}
  use 'arkav/lualine-lsp-progress'

  -- treesitter
  use { 'nvim-treesitter/nvim-treesitter', run = ":TSUpdate"}

  -- theme
  use 'folke/tokyonight.nvim'

  -- JSON
  use "b0o/schemastore.nvim"

  use "windwp/nvim-autopairs"
 
  -- comment
  use {
        "numToStr/Comment.nvim",
        config = function()
            require('Comment').setup()
        end
    }

  -- markdown
  use ({
      "iamcco/markdown-preview.nvim",
      run = function() vim.fn["mkdp#util#install"]() end,
    })

 -- fzf.vim
  use "junegunn/fzf.vim"


  -- telescope
--  use {'nvim-telescope/telescope.nvim', requires = 'nvim-lua/plenary.nvim'}

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if packer_bootstrap then
    require('packer').sync()
  end
end)
