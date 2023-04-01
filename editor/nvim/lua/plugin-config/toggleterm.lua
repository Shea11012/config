require("toggleterm").setup({
    size = function(term)
        if term.direction == "horizontal" then
            return 15
        elseif term.direction == "vertical" then
            return vim.o.colums * 0.4
        end
    end,
    on_open = function()
        vim.api.nvim_set_option_value("foldmethod", "manual", {scope = "local"})
        vim.api.nvim_set_option_value("foldexpr", "0", {scope = "local"})
    end,
    highlights = {FloatBorder = {guifg = "#61AFEF"}},
    open_mapping = false,
    hide_numbers = true,
    shade_filetypes = {},
    share_terminals = false,
    shading_factor = "1",
    start_in_insert = true,
    persist_size = true,
    direction = "horizontal",
    close_on_exit = true,
    shell = vim.o.shell
})
