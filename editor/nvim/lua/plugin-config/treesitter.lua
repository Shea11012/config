local status, ts = pcall(require, 'nvim-treesitter.configs')
if not status then
    vim.notify("not found treesitter")
    return
end

ts.setup({
    ensure_installed = {
        "bash","go","html","javascript","json","lua","make","rust","yaml","vue","typescript"
    },
    highlight = {
        enable = true, 
        disable = function(lang,buf)
            local ok,is_large_file = pcall(vim.api.nvim_buf_get_var,buf,"bigfile_disable_treesitter")
            return ok and is_large_file
        end
    },
    rainbow = {
        enable = true,
        extended_mode = true,
        max_file_lines = 2000,
    },
    context_commentstring = { enable = true, enable_autocmd = false },
    matchup = { enable = true },
})

require("nvim-ts-autotag").setup({
    filetypes = {
        "html","javascript","javascriptreact","typescriptreact","xml"
    }
})

require("colorizer").setup({})

require("tabout").setup({
    tabkey = "",
    backwards_tabkey = "",
    act_as_tab = true,
    act_as_shift_tab = false,
    enable_backwards = true,
    completion = true,
    tabouts = {
        { open = "'", close = "'" },
        { open = '"', close = '"' },
        { open = "`", close = "`" },
        { open = "(", close = ")" },
        { open = "[", close = "]" },
        { open = "{", close = "}" },
    },
    ignore_beginning = true,
    exclude = {},
})
