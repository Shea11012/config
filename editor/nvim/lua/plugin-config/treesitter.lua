local status, ts = pcall(require, 'nvim-treesitter.configs')
if not status then
    vim.notify("not found treesitter")
    return
end

ts.setup({
    highlight = {enable = true, disable = {}},
    ident = {enable = true, disable = {}},
    ensure_installed = {'go', 'rust', 'json', 'yaml', 'lua'},
    autotag = {enable = true}
})
