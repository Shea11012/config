return {

    -- nvim-tree
    {
        'nvim-tree/nvim-tree.lua',
        lazy = true,
        dependencies = 'nvim-tree/nvim-web-devicons',
        cmd = {
            "NvimTreeToggle", "NvimTreeOpen", "NvimTreeFindFile",
            "NvimTreeFindFileToggle", "NvimTreeRefresh"
        }
    }, -- bufferline
    {
        "akinsho/bufferline.nvim",
        lazy = true,
        event = {"BufReadPost", "BufAdd", "BufNewFile"},
        dependencies = 'nvim-tree/nvim-web-devicons'
    }, -- lualine
    {
        'nvim-lualine/lualine.nvim',
        lazy = true,
        event = {"BufReadPost", "BufAdd", "BufNewFile"},
        dependencies = 'nvim-tree/nvim-web-devicons'
    }, 'arkav/lualine-lsp-progress', -- treesitter
    {
        'nvim-treesitter/nvim-treesitter',
        lazy = true,
        build = function()
            if #vim.api.nvim_list_uis() ~= 0 then
                vim.api.nvim_command("TSUpdate")
            end
        end,
        event = {"CursorHold", "CursorHoldI"},
        dependencies = {
            {"nvim-treesitter/nvim-treesitter-textobjects"},
            {"mrjones2014/nvim-ts-rainbow"},
            {"JoosepAlviste/nvim-ts-context-commentstring"},
            {"mfussenegger/nvim-treehopper"}, {"andymass/vim-matchup"},
            {"windwp/nvim-ts-autotag"}, {"NvChad/nvim-colorizer.lua"},
            {"abecodes/tabout.nvim"}
        }
    }, -- theme
    {'catppuccin/nvim', name = "catppuccin"},
    {"windwp/nvim-autopairs", lazy = true}, -- comment
    {"numToStr/Comment.nvim", init = function() require("Comment").setup() end},
    -- markdown
    {
        "iamcco/markdown-preview.nvim",
        ft = "markdown",
        lazy = true,
        build = function() vim.fn["mkdp#util#install"]() end
    }, -- fzf.vim
    {"junegunn/fzf.vim"}, -- null-ls.nvim
    {"jose-elias-alvarez/null-ls.nvim"}, -- lsp-zero
    {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v1.x',
        dependencies = {
            {"nvim-lua/plenary.nvim"}, -- LSP Support
            {'neovim/nvim-lspconfig'}, -- Required
            {
                'williamboman/mason.nvim',
                build = function() pcall(vim.cmd, 'MasonUpdate') end
            }, -- Optional
            {'williamboman/mason-lspconfig.nvim'}, -- Optional
            -- Autocompletion
            {'hrsh7th/nvim-cmp'}, -- Required
            {'hrsh7th/cmp-nvim-lsp'}, -- Required
            {'hrsh7th/cmp-buffer'}, -- Optional
            {'hrsh7th/cmp-path'}, -- Optional
            {'hrsh7th/cmp-nvim-lua'}, -- Optional
            -- Snippets
            {'L3MON4D3/LuaSnip'}, -- Required
            {'rafamadriz/friendly-snippets'} -- Optional
        }
    }, -- toggleterm
    {
        "akinsho/toggleterm.nvim",
        cmd = {
            "ToggleTerm", "ToggleTermSetName", "ToggleTermToggleAll",
            "ToggleTermSendVisualLines", "ToggleTermSendCurrentLine",
            "ToggleTermSendVisualSelection"
        }
    }, -- vim-go
    {"fatih/vim-go", lazy = true}, -- telescope
    {
        'nvim-telescope/telescope.nvim',
        dependencies = {
            {'nvim-lua/plenary.nvim'}, {"nvim-tree/nvim-web-devicons"},
            {"nvim-telescope/telescope-fzf-native.nvim", build = "make"},
            {"jvgrootveld/telescope-zoxide"},
            {"nvim-telescope/telescope-live-grep-args.nvim"}
        }
    }, {"ibhagwan/smartyank.nvim", lazy = true, event = "BufReadPost"}

}
